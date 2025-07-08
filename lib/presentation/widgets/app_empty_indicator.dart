import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_sizes.dart';
import '../../app/theme/app_text_style.dart';

class AppEmptyIndicator extends StatelessWidget {
  const AppEmptyIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.topic_outlined,
              color: AppColors.blackLv3,
              size: 32,
            ),
            SizedBox(height: AppSizes.padding / 4),
            Text(
              'Empty',
              style: AppTextStyle.bold(
                size: 14,
                color: AppColors.blackLv3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
