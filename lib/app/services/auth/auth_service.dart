import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/auth/auth_base.dart';
import '../../../core/usecase/error.dart';
import '../../../core/usecase/result.dart';
import '../../const/const.dart';

class AuthService implements AuthBase {
  AuthService({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _googleSignIn =
          googleSignIn ?? GoogleSignIn(clientId: Constant.googleSignInClientId);

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  @override
  Future<bool> isAuthenticated() async {
    return _firebaseAuth.currentUser != null;
  }

  @override
  User? getAuthData() {
    return _firebaseAuth.currentUser;
  }

  @override
  Future<Result<UserCredential>> signIn() async {
    try {
      final googleUser = await _googleSignIn.signIn();

      // Handle user cancellation
      if (googleUser == null) {
        return Result.error(
          ServiceError(message: 'Sign in was cancelled by user'),
        );
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _firebaseAuth.signInWithCredential(credential);

      return Result.success(result);
    } on FirebaseAuthException catch (e) {
      return Result.error(
        ServiceError(message: 'Authentication failed: ${e.message}'),
      );
    } on PlatformException catch (e) {
      return Result.error(
        ServiceError(message: 'Platform error: ${e.message}'),
      );
    } catch (e) {
      return Result.error(
        ServiceError(message: 'Unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  @override
  Future<bool> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
      return true;
    } catch (e) {
      return false;
    }
  }
}
