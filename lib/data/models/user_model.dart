class UserModel {
  String id;
  String? email;
  String? name;
  String? photoURL;
  int totalRequest;
  String? createdAt;
  String? updatedAt;

  UserModel({
    required this.id,
    this.email,
    this.name,
    this.photoURL,
    this.totalRequest = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      photoURL: json['photoURL'],
      totalRequest: json['totalRequest'] ?? 0,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoURL': photoURL,
      'totalRequest': totalRequest,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
