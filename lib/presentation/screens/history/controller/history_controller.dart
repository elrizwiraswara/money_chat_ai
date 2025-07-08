import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/const/const.dart';
import '../../../../app/enum/category_type.dart';
import '../../../../app/enum/input_source.dart';
import '../../../../app/services/auth/auth_service.dart';
import '../../../../app/utilities/console_log.dart';
import '../../../../app/utilities/currency_formatter.dart';
import '../../../../app/utilities/date_formatter.dart';
import '../../../../core/extensions/string_casing_extension.dart';
import '../../../../core/notifier/base_change_notifier.dart';
import '../../../../data/datasources/category_datasource.dart';
import '../../../../data/datasources/transaction_datasource.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../widgets/app_toast.dart';
import '../../chat/controller/chat_controller.dart';
import '../../main/controller/main_controller.dart';

final historyController = ChangeNotifierProvider<HistoryController>(
  (ref) => HistoryController(ref),
);

class HistoryController extends BaseChangeNotifier {
  late Ref ref;

  HistoryController(this.ref);

  final _transactionDatasource = TransactionDatasource();
  final _categoryDatasource = CategoryDatasource();

  CategoryModel? selectedCategoryFilter;
  DateTime selectedPeriodFilter = DateTime.now();

  List<TransactionModel>? transactionHistory = [];

  @override
  void initState() {
    getTransactions();
    super.initState();
  }

  void getTransactions() async {
    final mainCtrl = ref.read(mainController);
    final user = mainCtrl.user;

    if (user == null) return;

    transactionHistory = await _transactionDatasource.getAllTransaction(
      createdById: user.id,
      categoryId: selectedCategoryFilter?.id,
      date: selectedPeriodFilter,
    );

    notifyListeners();
  }

  Future<TransactionModel?> getTransactionById(String id) async {
    return await _transactionDatasource.getTransaction(id);
  }

  void onChangedCategoryFilter(CategoryModel? category) {
    selectedCategoryFilter = category;
    notifyListeners();
    getTransactions();
  }

  void onChangedPeriodFilter(DateTime date) {
    selectedPeriodFilter = date;
    notifyListeners();
    getTransactions();
  }

  Future<void> createTransaction({
    required TransactionModel trx,
    required CategoryType type,
    required InputSource source,
    bool showToast = true,
  }) async {
    final mainCtrl = ref.read(mainController);
    final chatCtrl = ref.read(chatController);

    final user = mainCtrl.user;
    if (user == null) return;

    try {
      trx.id ??= await generateTrxNumber(type);
      trx.type = type.name;
      trx.source = source.name;
      trx.createdById = user.id;
      trx.createdByName = user.name;
      trx.date ??= DateTime.now().toUtc().toIso8601String();
      trx.createdAt ??= DateTime.now().toUtc().toIso8601String();
      trx.updatedAt = DateTime.now().toUtc().toIso8601String();

      if (trx.items?.isNotEmpty ?? false) {
        for (int i = 0; i < trx.items!.length; i++) {
          trx.items![i].transactionId = trx.id;
          trx.items![i].id = "${trx.id}$i";
        }
      }

      await _transactionDatasource.createTransaction(trx);

      getTransactions();

      chatCtrl.addSystemChat(
        message:
            '✅ ${type.name.toTitleCase()} (${trx.categoryId}) ${trx.type == CategoryType.expenses.name ? '-' : '+'}${CurrencyFormatter.format(trx.amount ?? 0)} saved!\nID: ${trx.id?.toUpperCase()}, Date: ${DateFormatter.slashDateWithClock(trx.date!)}',
        createdById: Constant.systemChatId,
      );

      if (showToast) AppToast.show(message: 'Record saved');
    } catch (e) {
      cl(e);

      chatCtrl.addSystemChat(
        message: e.toString(),
        createdById: Constant.systemChatId,
      );

      if (showToast) AppToast.show(message: e.toString(), success: false);
    }
  }

  Future<void> updateTransaction({
    required TransactionModel trx,
    bool showToast = true,
  }) async {
    final chatCtrl = ref.read(chatController);

    try {
      trx.updatedAt = DateTime.now().toUtc().toIso8601String();

      await _transactionDatasource.updateTransaction(trx);

      getTransactions();

      chatCtrl.addSystemChat(
        message:
            '✅ ${trx.type?.toTitleCase()} (${trx.categoryId}) ${trx.type == CategoryType.expenses.name ? '-' : '+'}${CurrencyFormatter.format(trx.amount ?? 0)} saved!\nID: ${trx.id?.toUpperCase()}, Date: ${DateFormatter.slashDateWithClock(trx.date!)}',
        createdById: Constant.systemChatId,
      );

      if (showToast) AppToast.show(message: 'Record updated');
    } catch (e) {
      cl(e);

      chatCtrl.addSystemChat(
        message: e.toString(),
        createdById: Constant.systemChatId,
      );

      if (showToast) AppToast.show(message: e.toString());
    }
  }

  Future<void> deleteTransaction({
    required String id,
    bool showToast = true,
  }) async {
    final chatCtrl = ref.read(chatController);

    try {
      await _transactionDatasource.deleteTransaction(id);

      getTransactions();

      chatCtrl.addSystemChat(
        message: '🗑️ $id deleted!',
        createdById: Constant.systemChatId,
      );

      if (showToast) AppToast.show(message: 'Record deleted');
    } catch (e) {
      cl(e);

      chatCtrl.addSystemChat(
        message: e.toString(),
        createdById: Constant.systemChatId,
      );

      if (showToast) AppToast.show(message: e.toString(), success: false);
    }
  }

  Future<String> generateTrxNumber(CategoryType type, {int? num}) async {
    final prefix = type == CategoryType.expenses ? 'EX' : 'IN';

    int number = 0;

    if (num == null) {
      final lastId = await _transactionDatasource.getLastTransactionId(
        createdById: AuthService().getAuthData()!.uid,
        type: type,
      );

      number = int.tryParse(lastId?.substring(2) ?? '') ?? 0;
      number += 1;
    } else {
      number = num + 1;
    }

    final newId = '$prefix${number.toString().padLeft(6, '0')}';

    final trx = await _transactionDatasource.getTransaction(newId);

    if (trx != null) return generateTrxNumber(type, num: number);

    return newId;
  }

  Future<void> createOrUpdateCategory(CategoryModel category) async {
    try {
      final mainCtrl = ref.read(mainController);

      final user = mainCtrl.user;
      if (user == null) return;

      final current = await _categoryDatasource.getCategoryById(
        user.id,
        category.id!,
      );

      await _categoryDatasource.createOrUpdateCategory(user.id, category);

      await mainCtrl.getCategories();

      AppToast.show(
        message:
            "Category ${category.name} (${category.id}) successfully ${current != null ? 'Updated' : 'Created'}!",
      );
    } catch (e) {
      cl(e);
      AppToast.show(message: e.toString(), success: false);
    }
  }

  Future<void> deleteCategory(CategoryModel category) async {
    try {
      final mainCtrl = ref.read(mainController);

      final user = mainCtrl.user;
      if (user == null) return;

      await _categoryDatasource.deleteCategory(
        user.id,
        category.id!,
      );

      await mainCtrl.getCategories();

      AppToast.show(
        message: "Category ${category.name} (${category.id}) deleted!",
      );
    } catch (e) {
      cl(e);
      AppToast.show(message: e.toString(), success: false);
    }
  }
}
