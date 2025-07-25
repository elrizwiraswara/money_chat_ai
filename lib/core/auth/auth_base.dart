import '../usecase/result.dart';

abstract class AuthBase {
  Future<bool> isAuthenticated();
  dynamic getAuthData();
  Future<Result> signIn();
  Future<bool> signOut();
}
