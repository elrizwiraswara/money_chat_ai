import 'package:flutter/material.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_sizes.dart';
import '../../app/theme/app_text_style.dart';

class AppToast {
  static void show({
    required String message,
    Widget? icon,
    bool success = true,
    Alignment alignment = Alignment.bottomCenter,
  }) {
    final context = AppRoutes.rootNavigatorKey.currentState!.context;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        width: AppSizes.maxWidth,
        showCloseIcon: false,
        content: Container(
          width: AppSizes.maxWidth,
          margin: EdgeInsets.only(bottom: AppSizes.margin * 4),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.padding / 1.5,
            vertical: AppSizes.padding / 4,
          ),
          decoration: BoxDecoration(
            color: success ? AppColors.greenLv3 : AppColors.redLv3,
            borderRadius: BorderRadius.circular(AppSizes.radius),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  children: [
                    if (icon != null) icon,
                    Flexible(
                      child: Text(
                        message,
                        style: AppTextStyle.bold(size: 12),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  final ctx = AppRoutes.rootNavigatorKey.currentState!.context;
                  ScaffoldMessenger.of(ctx).hideCurrentSnackBar();
                },
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppColors.blackLv1,
                ),
              ),
            ],
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}
