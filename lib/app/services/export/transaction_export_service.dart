import 'dart:convert';
// ignore: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:flutter/foundation.dart';

import '../../../data/models/transaction_model.dart';

class TransactionExportService {
  static Future<String> exportTransactionsToCsv(
    List<TransactionModel> transactions, {
    bool includeItems = false,
    String? filename,
  }) async {
    if (transactions.isEmpty) {
      throw Exception('No transactions to export');
    }

    final csvContent = includeItems
        ? _generateCsvWithItems(transactions)
        : _generateBasicCsv(transactions);

    return csvContent;
  }

  static Future<String> saveAndShareCsv(
    List<TransactionModel> transactions, {
    bool includeItems = false,
    String? filename,
    bool autoShare = false,
  }) async {
    try {
      final csvContent = await exportTransactionsToCsv(
        transactions,
        includeItems: includeItems,
        filename: filename,
      );

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = filename ?? 'transactions_export_$timestamp.csv';

      if (kIsWeb) {
        _downloadCsvForWeb(csvContent, fileName);
        return 'Downloaded: $fileName';
      } else {
        throw UnsupportedError(
          'Non-web platforms not supported in this version',
        );
      }
    } catch (e) {
      throw Exception('Failed to save CSV: $e');
    }
  }

  static void _downloadCsvForWeb(String csvContent, String fileName) {
    final bytes = utf8.encode(csvContent);
    final blob = html.Blob([bytes], 'text/csv');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  static void openCsvInNewTab(String csvContent) {
    final bytes = utf8.encode(csvContent);
    final blob = html.Blob([bytes], 'text/csv');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.window.open(url, '_blank');
    html.Url.revokeObjectUrl(url);
  }

  static String _generateBasicCsv(List<TransactionModel> transactions) {
    final buffer = StringBuffer();

    buffer.writeln(
      _escapeAndJoinCsvRow([
        'ID',
        'Category ID',
        'Category Name',
        'Created By ID',
        'Created By Name',
        'Merchant',
        'Date',
        'Source',
        'Type',
        'Items Count',
        'Subtotal',
        'Discount',
        'Total',
        'Created At',
        'Updated At',
      ]),
    );

    for (final transaction in transactions) {
      final itemsCount = transaction.items?.length ?? 0;
      final subtotal =
          transaction.items?.fold<double>(
            0,
            (sum, item) => sum + ((item.price ?? 0) * (item.qty ?? 0)),
          ) ??
          transaction.amount;

      buffer.writeln(
        _escapeAndJoinCsvRow([
          transaction.id ?? '',
          transaction.categoryId ?? '',
          transaction.categoryName ?? '',
          transaction.createdById ?? '',
          transaction.createdByName ?? '',
          transaction.merchant ?? '',
          transaction.date ?? '',
          transaction.source ?? '',
          transaction.type ?? '',
          itemsCount.toString(),
          (subtotal ?? 0).toStringAsFixed(2),
          (transaction.discount ?? 0).toString(),
          (transaction.amount ?? 0).toString(),
          transaction.createdAt ?? '',
          transaction.updatedAt ?? '',
        ]),
      );
    }

    return buffer.toString();
  }

  static String _generateCsvWithItems(List<TransactionModel> transactions) {
    final buffer = StringBuffer();

    buffer.writeln(
      _escapeAndJoinCsvRow([
        'Transaction ID',
        'Category ID',
        'Category Name',
        'Created By ID',
        'Created By Name',
        'Merchant',
        'Date',
        'Source',
        'Type',
        'Subtotal',
        'Discount',
        'Total',
        'Created At',
        'Updated At',
        'Item ID',
        'Item Name',
        'Item Quantity',
        'Item Price',
        'Item Total',
      ]),
    );

    for (final transaction in transactions) {
      final subtotal =
          transaction.items?.fold<double>(
            0,
            (sum, item) => sum + ((item.price ?? 0) * (item.qty ?? 0)),
          ) ??
          transaction.amount;

      if (transaction.items == null || transaction.items!.isEmpty) {
        buffer.writeln(
          _escapeAndJoinCsvRow([
            transaction.id ?? '',
            transaction.categoryId ?? '',
            transaction.categoryName ?? '',
            transaction.createdById ?? '',
            transaction.createdByName ?? '',
            transaction.merchant ?? '',
            transaction.date ?? '',
            transaction.source ?? '',
            transaction.type ?? '',
            (subtotal ?? 0).toString(),
            (transaction.discount ?? 0).toString(),
            (transaction.amount ?? 0).toString(),
            transaction.createdAt ?? '',
            transaction.updatedAt ?? '',
            '',
            '',
            '',
            '',
            '',
          ]),
        );
      } else {
        for (final item in transaction.items!) {
          final itemTotal = (item.price ?? 0) * (item.qty ?? 0);

          buffer.writeln(
            _escapeAndJoinCsvRow([
              transaction.id ?? '',
              transaction.categoryId ?? '',
              transaction.categoryName ?? '',
              transaction.createdById ?? '',
              transaction.createdByName ?? '',
              transaction.merchant ?? '',
              transaction.date ?? '',
              transaction.source ?? '',
              transaction.type ?? '',
              (subtotal ?? 0).toString(),
              (transaction.discount ?? 0).toString(),
              (transaction.amount ?? 0).toString(),
              transaction.createdAt ?? '',
              transaction.updatedAt ?? '',
              (item.id ?? 0).toString(),
              item.name ?? '',
              (item.qty ?? 0).toString(),
              (item.price ?? 0).toString(),
              itemTotal.toStringAsFixed(2),
            ]),
          );
        }
      }
    }

    return buffer.toString();
  }

  static String _escapeAndJoinCsvRow(List<String> fields) {
    return fields.map(_escapeCsvField).join(',');
  }

  static String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }
}
