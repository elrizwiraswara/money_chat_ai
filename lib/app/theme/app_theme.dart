import 'app_text_style.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_sizes.dart';

class AppTheme {
  /// Make [AppTheme] to be singleton
  static final AppTheme _instance = AppTheme._();

  factory AppTheme() => _instance;

  AppTheme._();

  Color _primaryColor = AppColors.tangerineLv1;
  Color? _secondaryColor = AppColors.greenLv1;
  Color? _tertiaryColor = AppColors.redLv1;
  Brightness _brightness = Brightness.light;

  ThemeData init({
    Color? primaryColor,
    Color? secondaryColor,
    Color? tertiaryColor,
    Color? neutralColor,
    Brightness? brightness,
    TextTheme? primaryTextTheme,
    TextTheme? secondaryTextTheme,
  }) {
    _primaryColor = primaryColor ?? _primaryColor;
    _secondaryColor = secondaryColor ?? _secondaryColor;
    _tertiaryColor = tertiaryColor ?? _tertiaryColor;
    _brightness = brightness ?? _brightness;

    return _base(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        brightness: _brightness,
        primary: _primaryColor,
        secondary: _secondaryColor,
        tertiary: _tertiaryColor,
      ),
      brightness: _brightness,
    );
  }

  ThemeData _base({
    required ColorScheme colorScheme,
    required Brightness brightness,
  }) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: brightness,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      scaffoldBackgroundColor: colorScheme.surfaceContainerLowest,
      fontFamily: 'Montserrat',
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surfaceContainerLowest,
        shadowColor: colorScheme.surfaceContainerHighest,
        elevation: 0.5,
        scrolledUnderElevation: 0.5,
        titleSpacing: AppSizes.padding,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: colorScheme.onSurface,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.onSurface,
        unselectedLabelColor: colorScheme.onSurface,
        indicator: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: colorScheme.primary, width: 2),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.secondaryContainer,
        foregroundColor: colorScheme.onSecondaryContainer,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surface,
        selectedIconTheme: IconThemeData(
          color: colorScheme.onSecondaryContainer,
        ),
        indicatorColor: colorScheme.secondaryContainer,
      ),
      chipTheme: ChipThemeData(backgroundColor: colorScheme.surface),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainerLowest,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.outline,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.surfaceDim,
        thickness: 0.5,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.primary,
        contentTextStyle: TextStyle(
          color: colorScheme.surface,
          fontWeight: FontWeight.w600,
        ),
        showCloseIcon: true,
        elevation: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainerLowest,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: Colors.white,
        rangePickerBackgroundColor: Colors.white,
        dividerColor: AppColors.blackLv4,
        confirmButtonStyle: ButtonStyle(
          textStyle: WidgetStateTextStyle.resolveWith(
            (s) => AppTextStyle.bold(size: 16),
          ),
          foregroundColor: WidgetStateColor.resolveWith(
            (s) => AppColors.blackLv1,
          ),
          overlayColor: WidgetStateColor.resolveWith(
            (s) => AppColors.blackLv5,
          ),
        ),
        cancelButtonStyle: ButtonStyle(
          textStyle: WidgetStateTextStyle.resolveWith(
            (s) => AppTextStyle.bold(size: 16),
          ),
          foregroundColor: WidgetStateColor.resolveWith(
            (s) => AppColors.blackLv1,
          ),
          overlayColor: WidgetStateColor.resolveWith(
            (s) => AppColors.blackLv5,
          ),
        ),
        todayForegroundColor: WidgetStateColor.resolveWith(
          (s) => AppColors.blackLv1,
        ),
        dayForegroundColor: WidgetStateColor.resolveWith(
          (s) => AppColors.blackLv1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(AppSizes.radius),
        ),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: Colors.white,
        padding: EdgeInsets.all(AppSizes.padding),
        confirmButtonStyle: ButtonStyle(
          textStyle: WidgetStateTextStyle.resolveWith(
            (s) => AppTextStyle.bold(size: 16),
          ),
          foregroundColor: WidgetStateColor.resolveWith(
            (s) => AppColors.blackLv1,
          ),
          overlayColor: WidgetStateColor.resolveWith(
            (s) => AppColors.blackLv5,
          ),
        ),
        cancelButtonStyle: ButtonStyle(
          textStyle: WidgetStateTextStyle.resolveWith(
            (s) => AppTextStyle.bold(size: 16),
          ),
          foregroundColor: WidgetStateColor.resolveWith(
            (s) => AppColors.blackLv1,
          ),
          overlayColor: WidgetStateColor.resolveWith(
            (s) => AppColors.blackLv5,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(AppSizes.radius),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateColor.resolveWith(
            (s) => AppColors.blackLv1,
          ),
          textStyle: WidgetStateProperty.resolveWith(
            (s) => AppTextStyle.semibold(size: 12),
          ),
        ),
      ),
    );
  }
}
