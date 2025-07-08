import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/category_model.dart';

class CategoryDatasource {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<List<CategoryModel>?> getAllCategory(String userId) async {
    var res = await _firebaseFirestore
        .collection('users')
        .doc(userId)
        .collection('categories')
        .orderBy('name')
        .get();

    if (res.docs.isEmpty) return null;

    return res.docs.map((e) => CategoryModel.fromJson(e.data())).toList();
  }

  Future<CategoryModel?> getCategoryById(
    String userId,
    String categoryId,
  ) async {
    var res = await _firebaseFirestore
        .collection('users')
        .doc(userId)
        .collection('categories')
        .where('id', isEqualTo: categoryId)
        .get();

    if (res.docs.isEmpty) return null;

    return CategoryModel.fromJson(res.docs.first.data());
  }

  Future<String?> createOrUpdateCategory(
    String userId,
    CategoryModel category,
  ) async {
    await _firebaseFirestore
        .collection('users')
        .doc(userId)
        .collection('categories')
        .doc(category.id)
        .set(category.toJson());

    return category.id;
  }

  Future<void> deleteCategory(String userId, String categoryId) async {
    return await _firebaseFirestore
        .collection('users')
        .doc(userId)
        .collection('categories')
        .doc(categoryId)
        .delete();
  }
}
