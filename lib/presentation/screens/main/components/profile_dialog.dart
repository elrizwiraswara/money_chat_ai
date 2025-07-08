import 'package:app_image/app_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_sizes.dart';
import '../../../../app/theme/app_text_style.dart';
import '../controller/main_controller.dart';

class ProfileDialog extends ConsumerWidget {
  const ProfileDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(mainController).user;

    return Column(
      children: [
        SizedBox(height: AppSizes.padding),
        AppImage(
          image: user?.photoURL,
          borderRadius: BorderRadius.circular(100),
          width: 112,
          height: 112,
          backgroundColor: AppColors.blackLv5,
          placeHolderWidget: Icon(
            Icons.person_2_outlined,
            color: AppColors.blackLv1,
          ),
        ),
        SizedBox(height: AppSizes.padding),
        Text(
          user?.name ?? '',
          style: AppTextStyle.extraBold(size: 18),
        ),
        SizedBox(height: AppSizes.padding / 6),
        Text(
          user?.email ?? '',
          style: AppTextStyle.semibold(size: 12),
        ),
      ],
    );
  }
}
