import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/screens/auth/sign_in_screen.dart';
import '../../presentation/screens/chat/chat_screen.dart';
import '../../presentation/screens/error_handler_screen.dart';
import '../../presentation/screens/history/history_screen.dart';
import '../../presentation/screens/main/main_screen.dart';
import '../../presentation/screens/recap/recap_screen.dart';
import '../services/auth/auth_service.dart';

class AppRoutes {
  AppRoutes._();

  static final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  static final navNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'nav');

  static final router = GoRouter(
    initialLocation: '/chat',
    navigatorKey: rootNavigatorKey,
    // errorBuilder: (context, state) => ErrorScreen(
    //   errorMessage: state.error?.message,
    // ),
    redirect: (context, state) async {
      // if isAuthenticated = false, go to sign-in screen
      // else continue to current intended route screen
      if (!await AuthService().isAuthenticated()) {
        return '/auth/sign-in';
      } else {
        return null;
      }
    },
    routes: [
      _main,
      _auth,
      _error,
    ],
  );

  static final _error = GoRoute(
    path: '/error',
    builder: (context, state) {
      return ErrorScreen(errorDetails: state.extra as FlutterErrorDetails?);
    },
  );

  static final _auth = GoRoute(
    path: '/auth',
    redirect: (context, state) async {
      // if isAuthenticated = false, go to intended route screen
      // else back to main screen
      if (!await AuthService().isAuthenticated()) {
        return '/auth/sign-in';
      } else {
        return '/chat';
      }
    },
    routes: [_signIn],
  );

  static final _signIn = GoRoute(
    path: 'sign-in',
    builder: (context, state) {
      return const SignInScreen();
    },
  );

  static final _main = ShellRoute(
    navigatorKey: navNavigatorKey,
    builder: (BuildContext context, GoRouterState state, Widget child) {
      return MainScreen(child: child);
    },
    redirect: (context, state) async {
      // if isAuthenticated = true, go to intended route screen
      // else return to auth screen
      if (!await AuthService().isAuthenticated()) {
        return '/auth';
      } else {
        return null;
      }
    },
    routes: [
      _chat,
      _history,
      _recap,
    ],
  );

  static final _chat = GoRoute(
    path: '/chat',
    pageBuilder: (context, state) {
      return const NoTransitionPage<void>(child: ChatScreen());
    },
  );

  static final _history = GoRoute(
    path: '/history',
    pageBuilder: (context, state) {
      return NoTransitionPage<void>(
        child: HistoryScreen(
          param: state.extra as Map<String, dynamic>?,
        ),
      );
    },
  );

  static final _recap = GoRoute(
    path: '/recap',
    pageBuilder: (context, state) {
      return const NoTransitionPage<void>(child: RecapScreen());
    },
  );
}
