import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  final FirebaseStorage firebaseStorage;

  FirebaseStorageService({FirebaseStorage? firebaseStorage})
    : firebaseStorage = firebaseStorage ?? FirebaseStorage.instance;

  Future<String> uploadUserPhoto(Uint8List data) async {
    final ref = firebaseStorage
        .ref()
        .child('user-photos')
        .child(
          'user-photo-${DateTime.now().millisecondsSinceEpoch}.jpg',
        );

    final metadata = SettableMetadata(contentType: 'image/jpeg');

    final taskSnapshot = await ref.putData(data, metadata);

    return await taskSnapshot.ref.getDownloadURL();
  }

  Future<String> uploadChatImages(Uint8List data) async {
    final ref = firebaseStorage
        .ref()
        .child('chat-images')
        .child(
          'chat-image-${DateTime.now().millisecondsSinceEpoch}.jpg',
        );

    final metadata = SettableMetadata(contentType: 'image/jpeg');

    final taskSnapshot = await ref.putData(data, metadata);

    return await taskSnapshot.ref.getDownloadURL();
  }
}
