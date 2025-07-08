import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/const/const.dart';
import '../../../../app/enum/category_type.dart';
import '../../../../app/utilities/currency_formatter.dart';
import '../../../../app/utilities/date_formatter.dart';
import '../../../../core/notifier/base_change_notifier.dart';
import '../../../../data/datasources/transaction_datasource.dart';
import '../../../../data/models/transaction_model.dart';
import '../../chat/controller/chat_controller.dart';
import '../../main/controller/main_controller.dart';

final recapController = ChangeNotifierProvider<RecapController>(
  (ref) => RecapController(ref),
);

class RecapController extends BaseChangeNotifier {
  late Ref ref;

  RecapController(this.ref);

  final _transactionDatasource = TransactionDatasource();

  List<TransactionModel> transactions = [];

  DateTime selectedPeriod = DateTime.now();

  double totalExpenses = 0;
  double totalIncome = 0;
  double balance = 0;

  void getRecap() async {
    final mainCtrl = ref.read(mainController);
    final user = mainCtrl.user;

    if (user == null) return;

    transactions = await _transactionDatasource.getAllTransaction(
      createdById: user.id,
      date: selectedPeriod,
    );

    final expenses = transactions
        .where((e) => e.type == CategoryType.expenses.name)
        .map((e) => e.amount)
        .toList();
    final income = transactions
        .where((e) => e.type == CategoryType.income.name)
        .map((e) => e.amount)
        .toList();

    totalExpenses = expenses.fold(0.0, (a, b) => (a ?? 0) + (b ?? 0)) ?? 0;
    totalIncome = income.fold(0.0, (a, b) => (a ?? 0) + (b ?? 0)) ?? 0;
    balance = totalIncome - totalExpenses;
    notifyListeners();
  }

  Future<void> getShortRecap(int? month, int? year) async {
    final mainCtrl = ref.read(mainController);
    final chatCtrl = ref.read(chatController);

    final user = mainCtrl.user;

    if (user == null) return;

    final parsedDate = DateTime(
      year ?? DateTime.now().year,
      month ?? DateTime.now().month,
    );

    var trx = await _transactionDatasource.getAllTransaction(
      createdById: user.id,
      date: parsedDate,
    );

    final expenses = trx
        .where((e) => e.type == CategoryType.expenses.name)
        .map((e) => e.amount)
        .toList();
    final income = trx
        .where((e) => e.type == CategoryType.income.name)
        .map((e) => e.amount)
        .toList();

    totalExpenses = expenses.fold(0.0, (a, b) => (a ?? 0) + (b ?? 0)) ?? 0;
    totalIncome = income.fold(0.0, (a, b) => (a ?? 0) + (b ?? 0)) ?? 0;
    balance = totalIncome - totalExpenses;

    final Map<String, double> categoryTotals = {};
    final Map<String, int> categoryCounts = {};

    for (final transaction in trx) {
      final categoryName = transaction.categoryName ?? 'Uncategorized';
      final amount = transaction.amount ?? 0.0;
      categoryTotals[categoryName] =
          (categoryTotals[categoryName] ?? 0.0) + amount;
      categoryCounts[categoryName] = (categoryCounts[categoryName] ?? 0) + 1;
    }

    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final top3Categories = sortedCategories.take(3).toList();

    String topCategoriesText = '';

    if (top3Categories.isNotEmpty && totalExpenses > 0) {
      topCategoriesText = top3Categories
          .asMap()
          .entries
          .map((entry) {
            final category = entry.value;
            final percentage = (category.value / totalExpenses * 100)
                .toStringAsFixed(0);
            final count = categoryCounts[category.key] ?? 0;
            return '${category.key} ($count): ${CurrencyFormatter.format(category.value)} ($percentage%)';
          })
          .join('\n');
    } else {
      topCategoriesText = '-';
    }

    chatCtrl.addSystemChat(
      message:
          '📊 Monthly Recap (${DateFormatter.onlyMonthAndYear(parsedDate.toIso8601String())}) \nExpenses: -${CurrencyFormatter.format(totalExpenses)}\nIncome: +${CurrencyFormatter.format(totalIncome)}\nBalance: ${balance.isNegative ? '' : '+'}${CurrencyFormatter.format(balance)}\n\nTop Categories:\n$topCategoriesText',
      createdById: Constant.systemChatId,
    );
  }

  void onChangedPeriodFilter(DateTime date) {
    selectedPeriod = date;
    notifyListeners();
    getRecap();
  }

  void onTapPrevMonth() {
    final newDate = DateTime(
      selectedPeriod.year,
      selectedPeriod.month - 1,
      selectedPeriod.day,
    );

    selectedPeriod = newDate;
    notifyListeners();
    getRecap();
  }

  void onTapNextMonth() {
    final newDate = DateTime(
      selectedPeriod.year,
      selectedPeriod.month + 1,
      selectedPeriod.day,
    );

    selectedPeriod = newDate;
    notifyListeners();
    getRecap();
  }

  (double, double, int) getRecapByCategory(String categoryId) {
    final trx = transactions.where((e) => e.categoryId == categoryId).toList();

    final totalAmount = trx
        .map((e) => e.amount)
        .fold(0.0, (a, b) => a + (b ?? 0));

    final percent = totalAmount / (totalExpenses + totalIncome) * 100;

    return (percent.isNaN ? 0 : percent, totalAmount, trx.length);
  }
}
