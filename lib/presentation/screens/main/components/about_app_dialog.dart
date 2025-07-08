import 'package:app_image/app_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_chat_ai/app/assets/app_assets.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_sizes.dart';
import '../../../../app/theme/app_text_style.dart';

class AboutAppDialog extends ConsumerWidget {
  const AboutAppDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.padding * 2),
      child: Column(
        children: [
          AppImage(
            image: AppAssets.logo,
            width: 112,
            height: 112,
            backgroundColor: AppColors.blackLv5,
            placeHolderWidget: Icon(
              Icons.person_2_outlined,
              color: AppColors.blackLv1,
            ),
          ),
          SizedBox(height: AppSizes.padding * 2),
          Text(
            'MoneyChat.ai',
            style: AppTextStyle.extraBold(size: 18),
          ),
          SizedBox(height: AppSizes.padding),
          Text(
            'An intelligent, chat-based personal finance tracker designed to help you stay on top of your money effortlessly.',
            style: AppTextStyle.medium(size: 12),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSizes.padding),
          Text(
            'Made with Flutter ❤️',
            style: AppTextStyle.bold(size: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
