import 'package:app_image/app_image.dart';
import 'package:flutter/material.dart';

import '../../app/assets/app_assets.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_sizes.dart';
import '../../app/theme/app_text_style.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: body()));
  }

  Widget body() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 270),
      padding: const EdgeInsets.all(AppSizes.padding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppImage(
            image: AppAssets.logo,
            imgProvider: ImgProvider.assetImage,
            width: 150,
          ),
          const SizedBox(height: AppSizes.padding),
          Text('MoneyChat.ai', style: AppTextStyle.bold(size: 32)),
          const SizedBox(height: AppSizes.padding / 2),
          Text(
            'Loading...',
            style: AppTextStyle.bold(size: 12, color: AppColors.blackLv4),
          ),
        ],
      ),
    );
  }
}
