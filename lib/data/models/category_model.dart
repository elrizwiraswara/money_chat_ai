class CategoryModel {
  String? id;
  String? type;
  String? name;
  int? color;

  CategoryModel({
    this.id,
    this.type,
    this.name,
    this.color,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      type: json['type'],
      name: json['name'],
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'color': color,
    };
  }
}
