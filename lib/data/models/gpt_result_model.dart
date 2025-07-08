/// Simplified result wrapper for GPT API responses
class GptResult {
  final bool isSuccess;
  final String? content;
  final String? errorMessage;
  final Duration processingTime;
  final GptUsage? usage;
  final String? model;
  final DateTime timestamp;

  GptResult._({
    required this.isSuccess,
    this.content,
    this.errorMessage,
    required this.processingTime,
    this.usage,
    this.model,
    required this.timestamp,
  });

  /// Create a successful result
  factory GptResult.success({
    required String content,
    required Duration processingTime,
    required GptUsage usage,
    required String model,
  }) {
    return GptResult._(
      isSuccess: true,
      content: content,
      processingTime: processingTime,
      usage: usage,
      model: model,
      timestamp: DateTime.now(),
    );
  }

  /// Create an error result
  factory GptResult.error({
    required String errorMessage,
    required Duration processingTime,
  }) {
    return GptResult._(
      isSuccess: false,
      errorMessage: errorMessage,
      processingTime: processingTime,
      timestamp: DateTime.now(),
    );
  }

  /// Get processing time in seconds
  double get processingTimeSeconds => processingTime.inMilliseconds / 1000.0;

  /// Get estimated cost (only available for successful responses)
  double get estimatedCost => usage?.estimatedCost ?? 0.0;

  @override
  String toString() {
    if (isSuccess) {
      return 'GptResult.success(content: ${content?.length ?? 0} chars, time: ${processingTimeSeconds}s)';
    } else {
      return 'GptResult.error(message: $errorMessage, time: ${processingTimeSeconds}s)';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'isSuccess': isSuccess,
      'content': content,
      'errorMessage': errorMessage,
      'processingTime': processingTime.inMilliseconds,
      'usage': usage?.toJson(),
      'model': model,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Model for token usage information
class GptUsage {
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;

  GptUsage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  factory GptUsage.fromJson(Map<String, dynamic> json) {
    return GptUsage(
      promptTokens: json['prompt_tokens'] ?? 0,
      completionTokens: json['completion_tokens'] ?? 0,
      totalTokens: json['total_tokens'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prompt_tokens': promptTokens,
      'completion_tokens': completionTokens,
      'total_tokens': totalTokens,
    };
  }

  /// Calculate estimated cost (approximate values for GPT-4o-mini)
  double get estimatedCost {
    const double inputCostPer1K = 0.00015; // $0.150 per 1K input tokens
    const double outputCostPer1K = 0.0006; // $0.600 per 1K output tokens

    final inputCost = (promptTokens / 1000) * inputCostPer1K;
    final outputCost = (completionTokens / 1000) * outputCostPer1K;

    return inputCost + outputCost;
  }
}
