import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_chat_ai/presentation/screens/main/controller/main_controller.dart';

import '../../../../app/const/const.dart';
import '../../../../app/services/auth/auth_service.dart';
import '../../../../core/notifier/base_change_notifier.dart';
import '../../../../core/usecase/result.dart';
import '../../../../data/datasources/category_datasource.dart';
import '../../../../data/datasources/user_datasource.dart';
import '../../../../data/models/user_model.dart';

final authController = ChangeNotifierProvider<AuthController>(
  (ref) => AuthController(ref),
);

class AuthController extends BaseChangeNotifier {
  late Ref ref;

  AuthController(this.ref);

  final _userDatasource = UserDatasource();
  final _categoryDatasource = CategoryDatasource();

  Future<Result<UserCredential?>> signIn() async {
    var res = await AuthService().signIn();

    final user = res.data?.user;

    if (res.isHasError || user == null) {
      return Result.error(res.error);
    }

    final currUser = await _userDatasource.getUser(res.data!.user!.uid);

    if (currUser == null) {
      await _userDatasource.createUser(
        UserModel(
          id: user.uid,
          email: user.email,
          name: user.displayName,
          photoURL: user.photoURL,
          totalRequest: 0,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
      );

      await ref.read(mainController).getUser();

      // Seed categories
      for (final category in Constant.categorySeed) {
        await _categoryDatasource.createOrUpdateCategory(user.uid, category);
      }

      await ref.read(mainController).initMain();
    }

    return Result.success(res.data);
  }
}
