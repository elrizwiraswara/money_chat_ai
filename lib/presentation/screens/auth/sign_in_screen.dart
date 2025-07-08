import 'package:app_image/app_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/assets/app_assets.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_sizes.dart';
import '../../../app/theme/app_text_style.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import 'controller/auth_controller.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: AppSizes.maxWidth),
          padding: const EdgeInsets.all(AppSizes.padding * 2),
          child: Container(
            padding: const EdgeInsets.all(AppSizes.padding * 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radius),
              border: Border.all(width: 1, color: AppColors.blackLv5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                welcomeMessage(),
                signInButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget welcomeMessage() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppImage(
          image: AppAssets.logo,
          imgProvider: ImgProvider.assetImage,
          width: 132,
        ),
        const SizedBox(height: AppSizes.padding * 2),
        Text('MoneyChat.ai', style: AppTextStyle.bold(size: 26)),
        const SizedBox(height: AppSizes.padding / 2),
        Text(
          'An intelligent, chat-based personal finance tracker designed to help you stay on top of your money effortlessly',
          textAlign: TextAlign.center,
          style: AppTextStyle.medium(size: 12),
        ),
        const SizedBox(height: AppSizes.padding * 2),
      ],
    );
  }

  Widget signInButton() {
    return AppButton(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppImage(
            image: AppAssets.googleLogoBlack,
            height: 14,
          ),
          SizedBox(width: AppSizes.padding / 2),
          Text(
            'Sign In With Google',
            style: AppTextStyle.extraBold(size: 12, color: AppColors.blackLv1),
          ),
        ],
      ),
      onTap: () async {
        AppDialog.showDialogProgress();

        var res = await ref.read(authController).signIn();

        AppDialog.closeDialog();

        if (res.isSuccess) {
          context.go('/chat');
        } else {
          AppDialog.showErrorDialog(error: res.error?.message);
        }
      },
    );
  }
}
