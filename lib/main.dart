import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/locale/app_locale.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';
import 'firebase_options.dart';
import 'presentation/screens/error_handler_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: "env");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  initializeDateFormatting();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = AppTheme().init();

    return MaterialApp.router(
      title: 'MoneyChat.ai',
      theme: theme,
      debugShowCheckedModeBanner: kDebugMode,
      routerConfig: AppRoutes.router,
      locale: AppLocale.defaultLocale,
      supportedLocales: AppLocale.supportedLocales,
      localizationsDelegates: AppLocale.localizationsDelegates,
      builder: (context, child) => ErrorHandlerBuilder(child: child),
    );
  }
}
