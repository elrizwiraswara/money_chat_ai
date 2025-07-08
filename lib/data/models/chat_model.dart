import 'transaction_model.dart';

class ChatModel {
  String id;
  String createdById;
  String role;
  String? content;
  String? imageUrl;
  String? ocrText;
  String type;
  String createdAt;
  bool isLoading;
  TransactionModel? transaction;

  ChatModel({
    required this.id,
    required this.createdById,
    required this.role,
    this.content,
    this.imageUrl,
    this.ocrText,
    required this.type,
    required this.createdAt,
    this.isLoading = false,
    this.transaction,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'],
      createdById: json['createdById'],
      role: json['role'],
      content: json['content'],
      imageUrl: json['imageUrl'],
      ocrText: json['ocrText'],
      type: json['type'],
      transaction: json['transaction'] != null
          ? TransactionModel.fromJson(json['transaction'])
          : null,
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdById': createdById,
      'role': role,
      'content': content,
      'imageUrl': imageUrl,
      'ocrText': ocrText,
      'type': type,
      'transaction': transaction?.toJson(),
      'createdAt': createdAt,
    };
  }

  Map<String, dynamic> toGptJson() {
    return {
      'role': role,
      'content': content ?? '',
    };
  }
}
