import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../app/enum/category_type.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/services/auth/auth_service.dart';
import '../../../../app/services/export/transaction_export_service.dart';
import '../../../../app/services/firebase_storage/firebase_storage_service.dart';
import '../../../../app/utilities/console_log.dart';
import '../../../../core/notifier/base_change_notifier.dart';
import '../../../../data/datasources/category_datasource.dart';
import '../../../../data/datasources/config_datasource.dart';
import '../../../../data/datasources/transaction_datasource.dart';
import '../../../../data/datasources/user_datasource.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/models/config_model.dart';
import '../../../../data/models/user_model.dart';
import '../../../widgets/app_toast.dart';

final mainController = ChangeNotifierProvider<MainController>(
  (ref) => MainController(ref),
);

class MainController extends BaseChangeNotifier {
  late Ref ref;

  MainController(this.ref);

  final _configDatasource = ConfigDatasource();
  final _userDatasource = UserDatasource();
  final _categoryDatasource = CategoryDatasource();
  final _transactionDatasource = TransactionDatasource();

  bool isDebug = false;
  bool isLoaded = false;

  ConfigModel? config;
  UserModel? user;
  String? appVersion;

  List<CategoryModel> categories = [];

  List<CategoryModel> get expensesCategories =>
      categories.where((e) => e.type == CategoryType.expenses.name).toList();

  List<CategoryModel> get incomeCategories =>
      categories.where((e) => e.type == CategoryType.income.name).toList();

  bool isIncomeCategory(String? categoryId) =>
      incomeCategories.where((e) => e.id == categoryId).isNotEmpty;

  CategoryModel? getCategory(String? categoryId) =>
      categories.where((e) => e.id == categoryId).firstOrNull;

  @override
  void initState() {
    initMain();
    super.initState();
  }

  Future<void> initMain() async {
    isLoaded = false;
    notifyListeners();

    await getConfig();
    await getUser();
    await getCategories();
    await getAppVersion();

    isLoaded = true;
    notifyListeners();
  }

  Future<void> getConfig() async {
    config = await _configDatasource.getConfig();
    notifyListeners();

    if (config == null) await onSignOut();
  }

  Future<void> getUser() async {
    if (config == null) return;

    final uid = AuthService().getAuthData()?.uid;

    if (uid == null) return;

    user = await _userDatasource.getUser(uid);
    notifyListeners();

    if (user == null) await onSignOut();
  }

  Future<void> getCategories() async {
    if (user == null) return;
    categories = await _categoryDatasource.getAllCategory(user!.id) ?? [];
    categories.insert(0, CategoryModel(id: null, name: 'All'));
    notifyListeners();
  }

  Future<void> getAppVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appVersion = packageInfo.version;
    notifyListeners();
  }

  Future<void> onSignOut() async {
    await AuthService().signOut();
    user = null;
    AppRoutes.router.refresh();
  }

  Future<String?> updateUser({
    required String name,
    Uint8List? photoData,
  }) async {
    if (user == null) return 'user null';

    try {
      user!.name = name;

      if (photoData != null) {
        user!.photoURL = await FirebaseStorageService().uploadUserPhoto(
          photoData,
        );
      }

      await _userDatasource.updateUser(user!);

      await getUser();

      return null;
    } catch (e) {
      cl(e, type: LogType.error);
      return e.toString();
    }
  }

  Future<void> exportCsv() async {
    try {
      if (user == null) return;

      final transactions = await _transactionDatasource.getAllTransaction(
        createdById: user!.id,
      );

      for (var e in transactions) {
        final category = await _categoryDatasource.getCategoryById(
          user!.id,
          e.categoryId!,
        );

        e.categoryName = category?.name?.split(' ').skip(1).join();
        e.createdByName = user?.name;
      }

      if (transactions.isEmpty) {
        return AppToast.show(
          message: 'Nothing to export (empty)',
          success: false,
        );
      }

      final path = await TransactionExportService.saveAndShareCsv(
        transactions,
        includeItems: true,
        filename: '${user?.name} Exported Data.csv',
        autoShare: true,
      );

      AppToast.show(message: 'Records exported successfully: $path');
    } catch (e) {
      AppToast.show(message: e.toString(), success: false);
    }
  }
}
