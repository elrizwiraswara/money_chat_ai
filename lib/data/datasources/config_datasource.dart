import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/config_model.dart';

class ConfigDatasource {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<ConfigModel?> getConfig() async {
    var res = await _firebaseFirestore.collection('config').doc('gpt').get();

    if (res.data() == null) return null;

    return ConfigModel.fromJson(res.data()!);
  }
}
