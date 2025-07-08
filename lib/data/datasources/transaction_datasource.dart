import 'package:cloud_firestore/cloud_firestore.dart';

import '../../app/enum/category_type.dart';
import '../../app/utilities/date_formatter.dart';
import '../models/transaction_model.dart';

class TransactionDatasource {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<String?> getLastTransactionId({
    required String createdById,
    required CategoryType type,
  }) async {
    var res = await _firebaseFirestore
        .collection('transactions')
        .where('createdById', isEqualTo: createdById)
        .where('type', isEqualTo: type.name)
        .orderBy(FieldPath.documentId)
        .get();

    if (res.docs.isEmpty) return null;

    return res.docs.last.id;
  }

  Future<TransactionModel?> getTransaction(String id) async {
    var res = await _firebaseFirestore
        .collection('transactions')
        .where('id', isEqualTo: id)
        .get();

    if (res.docs.isEmpty) return null;

    return TransactionModel.fromJson(res.docs.first.data());
  }

  Future<List<TransactionModel>> getAllTransaction({
    required String createdById,
    String? categoryId,
    DateTime? date,
  }) async {
    var query = _firebaseFirestore
        .collection('transactions')
        .where('createdById', isEqualTo: createdById);

    if (categoryId != null) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }

    if (date != null) {
      final start = DateTime(date.year, date.month);
      final end = DateFormatter.addMonths(start, 1);

      query = query
          .where(
            'date',
            isGreaterThanOrEqualTo: start.toUtc().toIso8601String(),
          )
          .where('date', isLessThan: end.toUtc().toIso8601String());
    }

    final res = await query.orderBy('date', descending: true).get();

    return res.docs.map((e) => TransactionModel.fromJson(e.data())).toList();
  }

  Future<String> createTransaction(TransactionModel transaction) async {
    await _firebaseFirestore
        .collection('transactions')
        .doc(transaction.id)
        .set(transaction.toJson());
    return transaction.id!;
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await _firebaseFirestore
        .collection('transactions')
        .doc(transaction.id)
        .set(
          transaction.toJson(),
          SetOptions(merge: true),
        );
  }

  Future<void> deleteTransaction(String id) async {
    return await _firebaseFirestore.collection('transactions').doc(id).delete();
  }
}
