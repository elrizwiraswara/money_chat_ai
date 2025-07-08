const { onRequest } = require('firebase-functions/v2/https');
const { getFirestore } = require('firebase-admin/firestore');
const { initializeApp } = require('firebase-admin/app');
const cors = require('cors')({ origin: true });

// Initialize Firebase Admin
initializeApp();
const db = getFirestore();

// Constants
const COLLECTIONS = {
  CONFIG: 'config',
  USERS: 'users'
};

const CONFIG_DOCS = {
  GPT: 'gpt'
};

const HTTP_STATUS = {
  OK: 200,
  BAD_REQUEST: 400,
  METHOD_NOT_ALLOWED: 405,
  TOO_MANY_REQUESTS: 429,
  INTERNAL_SERVER_ERROR: 500
};

const DEFAULTS = {
  MODEL: 'gpt-4o-mini',
  MAX_TOKENS: 1000,
  IMAGE_TIMEOUT: 30000
};

// Utility functions
const getTodayDateString = () => {
  const today = new Date();
  return today.getFullYear() + '-' + 
         String(today.getMonth() + 1).padStart(2, '0') + '-' + 
         String(today.getDate()).padStart(2, '0');
};

const validateRequest = (body) => {
  const { prompt, role, userId } = body;
  if (!prompt || !role || !userId) {
    return { isValid: false, error: 'Missing required fields: prompt, role, and userId' };
  }
  return { isValid: true };
};

// Configuration service
class ConfigService {
  static async getUserMaxRequests() {
    try {
      const configDoc = await db.collection(COLLECTIONS.CONFIG).doc(CONFIG_DOCS.GPT).get();
      
      if (!configDoc.exists) {
        throw new Error('Configuration not found');
      }
      
      const userMaxRequests = configDoc.data().userMaxRequests;
      
      if (typeof userMaxRequests !== 'number') {
        throw new Error('Invalid userMaxRequests configuration');
      }
      
      return userMaxRequests;
    } catch (error) {
      throw new Error(`Configuration error: ${error.message}`);
    }
  }
}

// User service
class UserService {
  static async getUserRequestData(userId) {
    try {
      const userDoc = await db.collection(COLLECTIONS.USERS).doc(userId).get();
      const todayDateString = getTodayDateString();
      
      if (!userDoc.exists) {
        return { currentDailyRequests: 0, userDoc: null };
      }
      
      const userData = userDoc.data();
      const lastRequestDate = userData.lastRequestDate;
      const dailyRequestCount = userData.dailyRequestCount || 0;
      
      // Reset counter if it's a new day
      const currentDailyRequests = lastRequestDate === todayDateString ? dailyRequestCount : 0;
      
      return { currentDailyRequests, userDoc };
    } catch (error) {
      throw new Error(`Database error while checking request limits: ${error.message}`);
    }
  }
  
  static async updateUserRequestCount(userId, currentDailyRequests, userDoc) {
    try {
      const todayDateString = getTodayDateString();
      const newDailyCount = (currentDailyRequests || 0) + 1;
      const totalRequest = userDoc?.exists ? (userDoc.data().totalRequest || 0) + 1 : 1;
      
      await db.collection(COLLECTIONS.USERS).doc(userId).set({
        dailyRequestCount: newDailyCount,
        lastRequestDate: todayDateString,
        totalRequest
      }, { merge: true });
      
      return newDailyCount;
    } catch (error) {
      console.error('Failed to update user request count:', error);
      // Don't throw - this shouldn't fail the whole request
      return (currentDailyRequests || 0) + 1;
    }
  }
}

// Rate limiting service
class RateLimitService {
  static checkRateLimit(currentDailyRequests, userMaxRequests) {
    if (currentDailyRequests >= userMaxRequests) {
      return {
        isLimited: true,
        response: {
          content: 'Daily request limit reached! Please try again tomorrow.',
          error: 'Daily request limit reached! Please try again tomorrow.',
          currentRequests: currentDailyRequests,
          maxRequests: userMaxRequests,
          resetDate: getTodayDateString()
        }
      };
    }
    return { isLimited: false };
  }
}

// Image processing service
class ImageService {
  static async processImage(imageUrl, prompt) {
    try {
      const imageResponse = await fetch(imageUrl, {
        headers: { 'User-Agent': 'Mozilla/5.0' },
        signal: AbortSignal.timeout(DEFAULTS.IMAGE_TIMEOUT)
      });

      if (!imageResponse.ok) {
        throw new Error(`Failed to download image: ${imageResponse.status}`);
      }

      const imageBuffer = await imageResponse.arrayBuffer();
      const base64Image = Buffer.from(imageBuffer).toString('base64');
      const base64DataUrl = `data:image/jpeg;base64,${base64Image}`;

      return [
        { type: 'text', text: prompt },
        { type: 'image_url', image_url: { url: base64DataUrl } }
      ];
    } catch (error) {
      throw new Error(`Image processing failed: ${error.message}`);
    }
  }
}

// OpenAI service
class OpenAIService {
  static buildMessages(chatHistory, role, content) {
    const messages = Array.isArray(chatHistory) && chatHistory.length > 0 ? [...chatHistory] : [];
    messages.push({ role, content });
    return messages;
  }
  
  static async callOpenAI(messages, model, maxTokens) {
    const apiKey = process.env.OPENAI_API_KEY;
    if (!apiKey) {
      throw new Error('OpenAI API key not configured');
    }

    const response = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${apiKey}`,
      },
      body: JSON.stringify({
        model,
        messages,
        max_tokens: maxTokens,
      }),
    });

    const responseData = await response.json();

    if (!response.ok) {
      const errorMessage = responseData.error?.message || 'Unknown API error';
      throw new Error(errorMessage);
    }

    return responseData;
  }
}

// Response builder
class ResponseBuilder {
  static success(responseData, userMaxRequests, currentDailyRequests, model) {
    const responseContent = responseData.choices?.[0]?.message?.content || '';
    const usage = responseData.usage || {};

    return {
      success: true,
      content: responseContent.trim() || 'No response generated',
      usage,
      model: responseData.model || model,
      remainingRequests: userMaxRequests - (currentDailyRequests + 1),
      dailyResetDate: getTodayDateString()
    };
  }
  
  static error(message, statusCode = HTTP_STATUS.INTERNAL_SERVER_ERROR) {
    return {
      success: false,
      error: message,
      statusCode
    };
  }
}

// Main handler
exports.chatWithOpenAI = onRequest(
  { cors: true },
  (req, res) => {
    return cors(req, res, async () => {
      try {
        // Method validation
        if (req.method !== 'POST') {
          return res.status(HTTP_STATUS.METHOD_NOT_ALLOWED).json(
            ResponseBuilder.error('Method not allowed', HTTP_STATUS.METHOD_NOT_ALLOWED)
          );
        }

        // Request validation
        const validation = validateRequest(req.body);
        if (!validation.isValid) {
          return res.status(HTTP_STATUS.BAD_REQUEST).json(
            ResponseBuilder.error(validation.error, HTTP_STATUS.BAD_REQUEST)
          );
        }

        const { 
          prompt, 
          role, 
          imageUrl, 
          model = DEFAULTS.MODEL, 
          maxTokens = DEFAULTS.MAX_TOKENS, 
          chatHistory, 
          userId 
        } = req.body;

        // Get configuration and user data
        const [userMaxRequests, { currentDailyRequests, userDoc }] = await Promise.all([
          ConfigService.getUserMaxRequests(),
          UserService.getUserRequestData(userId)
        ]);

        // Check rate limits
        const rateLimitCheck = RateLimitService.checkRateLimit(currentDailyRequests, userMaxRequests);
        if (rateLimitCheck.isLimited) {
          return res.status(HTTP_STATUS.TOO_MANY_REQUESTS).json(rateLimitCheck.response);
        }

        // Process content (text or image)
        const content = imageUrl 
          ? await ImageService.processImage(imageUrl, prompt)
          : prompt;

        // Build messages and call OpenAI
        const messages = OpenAIService.buildMessages(chatHistory, role, content);
        const responseData = await OpenAIService.callOpenAI(messages, model, maxTokens);

        // Update user request count
        const newDailyCount = await UserService.updateUserRequestCount(userId, currentDailyRequests, userDoc);

        // Return success response
        const successResponse = ResponseBuilder.success(responseData, userMaxRequests, newDailyCount - 1, model);
        return res.status(HTTP_STATUS.OK).json(successResponse);

      } catch (error) {
        console.error('Cloud function error:', error);
        
        // Handle specific error types
        if (error.message.includes('Configuration')) {
          return res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json(
            ResponseBuilder.error(error.message)
          );
        }
        
        if (error.message.includes('Image processing')) {
          return res.status(HTTP_STATUS.BAD_REQUEST).json(
            ResponseBuilder.error(error.message, HTTP_STATUS.BAD_REQUEST)
          );
        }
        
        if (error.message.includes('OpenAI API key')) {
          return res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json(
            ResponseBuilder.error(error.message)
          );
        }

        return res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json(
          ResponseBuilder.error(`Internal server error: ${error.message}`)
        );
      }
    });
  }
);