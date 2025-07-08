import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_sizes.dart';
import '../../app/theme/app_text_style.dart';

// App Progress Indicator
class AppProgressIndicator extends StatelessWidget {
  final double fontSize;
  final bool showMessage;
  final String message;

  const AppProgressIndicator({
    super.key,
    this.fontSize = 10,
    this.showMessage = true,
    this.message = 'Please wait',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(AppSizes.padding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSizes.padding / 4),
            CircularProgressIndicator(color: AppColors.blackLv1),
            if (showMessage)
              Padding(
                padding: const EdgeInsets.only(top: AppSizes.padding),
                child: Text(
                  message,
                  style: AppTextStyle.semibold(size: fontSize),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget small() {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.padding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.blackLv1),
        ],
      ),
    );
  }
}
