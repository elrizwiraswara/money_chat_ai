import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class UserDatasource {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<String> createUser(UserModel user) async {
    await _firebaseFirestore
        .collection('users')
        .doc(user.id)
        .set(user.toJson());

    // The id is uid from GoogleSignIn credential
    return user.id;
  }

  Future<void> updateUser(UserModel user) async {
    return await _firebaseFirestore
        .collection('users')
        .doc(user.id)
        .set(
          user.toJson(),
          SetOptions(merge: true),
        );
  }

  Future<UserModel?> getUser(String id) async {
    var res = await _firebaseFirestore
        .collection('users')
        .where('id', isEqualTo: id)
        .get();

    if (res.docs.isEmpty) return null;

    return UserModel.fromJson(res.docs.first.data());
  }
}
