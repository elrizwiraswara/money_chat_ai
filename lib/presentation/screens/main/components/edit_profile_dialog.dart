import 'package:app_image/app_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_sizes.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_dialog.dart';
import '../../../widgets/app_image_picker_dialog.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/app_toast.dart';
import '../controller/main_controller.dart';

class EditProfileDialog extends ConsumerStatefulWidget {
  const EditProfileDialog({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      EditProfileDialogState();
}

class EditProfileDialogState extends ConsumerState<EditProfileDialog> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  XFile? photoFile;
  String? photoURL;

  @override
  void initState() {
    final user = ref.read(mainController).user;
    photoURL = user?.photoURL;
    nameController.text = user?.name ?? '';
    emailController.text = user?.email ?? '';
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            AppImage(
              image: photoFile?.path ?? photoURL,
              borderRadius: BorderRadius.circular(100),
              width: 80,
              height: 80,
              backgroundColor: AppColors.blackLv5,
              placeHolderWidget: Icon(
                Icons.person_2_outlined,
                color: AppColors.blackLv1,
              ),
            ),
            SizedBox(width: AppSizes.padding / 2),
            AppButton(
              text: 'Edit Photo',
              buttonColor: AppColors.white,
              alignment: null,
              onTap: () async {
                final XFile? file = await AppDialog.show(
                  child: AppImagePickerDialog(),
                );

                if (file == null) return;

                photoFile = file;
                setState(() {});
              },
            ),
          ],
        ),
        SizedBox(height: AppSizes.padding),
        AppTextField(
          controller: nameController,
          labelText: 'Nama',
          hintText: 'Nama',
          fillColor: AppColors.blackLv5,
          showBorder: true,
        ),
        SizedBox(height: AppSizes.padding),
        AppTextField(
          enabled: false,
          controller: emailController,
          labelText: 'Email',
          hintText: 'Email',
          fillColor: AppColors.blackLv5,
          showBorder: true,
        ),
        SizedBox(height: AppSizes.padding),
        buttons(),
      ],
    );
  }

  Widget buttons() {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            text: 'Cancel',
            buttonColor: Colors.white,
            borderColor: Colors.transparent,
            textColor: AppColors.blackLv1,
            onTap: () => context.pop(),
          ),
        ),
        SizedBox(width: AppSizes.padding / 2),
        Expanded(
          child: AppButton(
            text: 'Save',
            buttonColor: Colors.white,
            borderColor: Colors.transparent,
            textColor: AppColors.blackLv1,
            onTap: () async {
              final controller = ref.read(mainController);

              AppDialog.showDialogProgress();

              final err = await controller.updateUser(
                name: nameController.text,
                photoData: await photoFile?.readAsBytes(),
              );

              AppDialog.closeDialog();
              AppDialog.closeDialog();

              if (err != null) {
                AppToast.show(message: err, success: false);
              } else {
                AppToast.show(message: 'Profile updated');
              }
            },
          ),
        ),
      ],
    );
  }
}
