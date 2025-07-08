import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocale {
  AppLocale._();

  static Locale defaultLocale = const Locale('en', 'EN');
  static String defaultPhoneCode = '+62';
  static String defaultCurrencyCode = '\$';

  static const List<Locale> supportedLocales = [
    Locale('en', 'EN'),
    Locale('id', 'ID'),
  ];

  static const List<LocalizationsDelegate> localizationsDelegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];
}
