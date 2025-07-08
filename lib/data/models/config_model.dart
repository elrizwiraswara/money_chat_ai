class ConfigModel {
  String model;
  String mainPrompt;
  String extractImagePrompt;
  String extractReceiptPrompt;
  int maxTokens;

  ConfigModel({
    required this.model,
    required this.mainPrompt,
    required this.extractImagePrompt,
    required this.extractReceiptPrompt,
    required this.maxTokens,
  });

  factory ConfigModel.fromJson(Map<String, dynamic> json) {
    return ConfigModel(
      model: json['model'],
      mainPrompt: json['mainPrompt'],
      extractImagePrompt: json['extractImagePrompt'],
      extractReceiptPrompt: json['extractReceiptPrompt'],
      maxTokens: json['maxTokens'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'mainPrompt': mainPrompt,
      'extractImagePrompt': extractImagePrompt,
      'extractReceiptPrompt': extractReceiptPrompt,
      'maxTokens': maxTokens,
    };
  }
}
