import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_sizes.dart';
import '../../app/theme/app_text_style.dart';
import 'app_button.dart';

class AppImagePickerDialog extends ConsumerWidget {
  const AppImagePickerDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            buttonColor: AppColors.blackLv5,
            padding: EdgeInsets.symmetric(vertical: AppSizes.padding * 5),
            child: Column(
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  size: 32,
                ),
                SizedBox(height: AppSizes.padding / 2),
                Text(
                  'Camera',
                  style: AppTextStyle.bold(
                    size: 16,
                    color: AppColors.blackLv2,
                  ),
                ),
              ],
            ),
            onTap: () async {
              final pickedFile = await ImagePicker().pickImage(
                source: ImageSource.camera,
                imageQuality: 50,
              );

              if (pickedFile == null) return;

              // ignore: use_build_context_synchronously
              context.pop(pickedFile);
            },
          ),
        ),
        SizedBox(width: AppSizes.padding),
        Expanded(
          child: AppButton(
            buttonColor: AppColors.blackLv5,
            padding: EdgeInsets.symmetric(vertical: AppSizes.padding * 5),
            child: Column(
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 32,
                ),
                SizedBox(height: AppSizes.padding / 2),
                Text(
                  'Gallery',
                  style: AppTextStyle.bold(
                    size: 16,
                    color: AppColors.blackLv2,
                  ),
                ),
              ],
            ),
            onTap: () async {
              final pickedFile = await ImagePicker().pickImage(
                source: ImageSource.gallery,
                imageQuality: 50,
              );

              if (pickedFile == null) return;

              // ignore: use_build_context_synchronously
              context.pop(pickedFile);
            },
          ),
        ),
      ],
    );
  }
}
