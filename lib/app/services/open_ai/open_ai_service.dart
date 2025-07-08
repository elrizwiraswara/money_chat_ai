import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../data/models/chat_model.dart';
import '../../../data/models/gpt_result_model.dart';
import '../../const/const.dart';
import '../../enum/chat_role.dart';

class OpenAIService {
  static final String _cloudFunctionUrl = Constant.cloudFunctionBaseUrl;

  OpenAIService();

  Future<GptResult> sendPrompt({
    required String model,
    required int maxTokens,
    required String prompt,
    required String userId,
    required ChatRole role,
    String? imageUrl,
    List<ChatModel>? chatHistory,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      // Prepare chat history for the cloud function
      List<Map<String, dynamic>>? historyJson;
      if (chatHistory != null && chatHistory.isNotEmpty) {
        historyJson = chatHistory.map((msg) => msg.toGptJson()).toList();
      }

      final requestBody = {
        'prompt': prompt,
        'userId': userId,
        'role': role.name,
        'model': model,
        'maxTokens': maxTokens,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (historyJson != null) 'chatHistory': historyJson,
      };

      final response = await http
          .post(
            Uri.parse(_cloudFunctionUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: 60));

      stopwatch.stop();

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        final usage = GptUsage.fromJson(responseData['usage'] ?? {});

        return GptResult.success(
          content: responseData['content'] ?? 'No response generated',
          processingTime: stopwatch.elapsed,
          usage: usage,
          model: responseData['model'] ?? model,
        );
      } else {
        final errorMessage =
            responseData['error'] ?? 'Unknown cloud function error';

        return GptResult.error(
          errorMessage: errorMessage,
          processingTime: stopwatch.elapsed,
        );
      }
    } catch (e) {
      stopwatch.stop();
      return GptResult.error(
        errorMessage: 'Failed to send prompt via cloud function: $e',
        processingTime: stopwatch.elapsed,
      );
    }
  }
}
