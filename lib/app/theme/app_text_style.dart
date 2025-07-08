import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyle {
  AppTextStyle._();

  // Montserrat TextStyle
  static String defaultFontFamily = "Montserrat";
  static Color defaultTextColor = AppColors.blackLv1;

  static TextStyle regular({
    required double size,
    Color? color,
    String? fontFamily,
    TextDecoration? textDecoration,
  }) {
    return _textStyle(size, color, fontFamily, textDecoration, FontWeight.w400);
  }

  static TextStyle medium({
    required double size,
    Color? color,
    String? fontFamily,
    TextDecoration? textDecoration,
  }) {
    return _textStyle(size, color, fontFamily, textDecoration, FontWeight.w500);
  }

  static TextStyle semibold({
    required double size,
    Color? color,
    String? fontFamily,
    TextDecoration? textDecoration,
  }) {
    return _textStyle(size, color, fontFamily, textDecoration, FontWeight.w600);
  }

  static TextStyle bold({
    required double size,
    Color? color,
    String? fontFamily,
    TextDecoration? textDecoration,
  }) {
    return _textStyle(size, color, fontFamily, textDecoration, FontWeight.w700);
  }

  static TextStyle extraBold({
    required double size,
    Color? color,
    String? fontFamily,
    TextDecoration? textDecoration,
  }) {
    return _textStyle(size, color, fontFamily, textDecoration, FontWeight.w900);
  }

  static TextStyle _textStyle(
    double size,
    Color? color,
    String? fontFamily,
    TextDecoration? textDecoration,
    FontWeight fontWeight,
  ) {
    return TextStyle(
      fontFamily: fontFamily ?? defaultFontFamily,
      color: color ?? defaultTextColor,
      fontSize: size,
      fontWeight: fontWeight,
      decoration: textDecoration,
    );
  }
}
