import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat_model.dart';

class ChatDatasource {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<String> createChat(String userId, ChatModel chat) async {
    await _firebaseFirestore
        .collection('users')
        .doc(userId)
        .collection('chats')
        .doc(chat.id)
        .set(chat.toJson());

    return chat.id;
  }

  Future<void> deleteChat(String userId, ChatModel chat) async {
    return await _firebaseFirestore
        .collection('users')
        .doc(userId)
        .collection('chats')
        .doc(chat.id)
        .delete();
  }

  Future<List<ChatModel>> getAllChats(String userId) async {
    var res = await _firebaseFirestore
        .collection('users')
        .doc(userId)
        .collection('chats')
        .orderBy('createdAt', descending: true)
        .get();

    final data = res.docs.map((e) => ChatModel.fromJson(e.data())).toList();
    data.reversed;

    return data;
  }

  Future<void> clearChats(String userId) async {
    final batch = _firebaseFirestore.batch();

    final snapshot = await _firebaseFirestore
        .collection('users')
        .doc(userId)
        .collection('chats')
        .get();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
