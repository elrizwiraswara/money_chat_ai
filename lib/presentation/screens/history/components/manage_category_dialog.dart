import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_chat_ai/presentation/screens/history/components/category_form_dialog.dart';
import 'package:money_chat_ai/presentation/screens/history/controller/history_controller.dart';
import 'package:money_chat_ai/presentation/widgets/app_dialog.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_sizes.dart';
import '../../../../app/theme/app_text_style.dart';
import '../../../widgets/app_button.dart';
import '../../main/controller/main_controller.dart';

class ManageCategoryDialog extends ConsumerStatefulWidget {
  const ManageCategoryDialog({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ManualEntryFormState();
}

class _ManualEntryFormState extends ConsumerState<ManageCategoryDialog> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mainController).getCategories();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref
        .watch(mainController)
        .categories
        .where((e) => e.id != null)
        .toList();

    return Column(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: AppSizes.screenHeight(context) - 300,
          ),
          child: ListView.builder(
            itemCount: categories.length,
            shrinkWrap: true,
            itemBuilder: (context, i) {
              return Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        context.pop();
                        AppDialog.show(
                          showButtons: false,
                          title: 'Edit Category',
                          child: CategoryFormDialog(
                            category: categories[i],
                          ),
                        );
                      },
                      child: Ink(
                        color: AppColors.white,
                        padding: EdgeInsets.all(AppSizes.padding),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                categories[i].name ?? '-',
                                style: AppTextStyle.semibold(size: 14),
                              ),
                            ),
                            if (categories[i].id != null)
                              Text(
                                '${categories[i].id}',
                                style: AppTextStyle.medium(
                                  size: 12,
                                  color: AppColors.blackLv3,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      final confirm = await AppDialog.show(
                        title: 'Confirm',
                        text: 'Are you sure want to delete this category?',
                        rightButtonText: 'Delete',
                        leftButtonText: 'Cancel',
                        onTapRightButton: () => context.pop(true),
                      );

                      if (confirm == null) return;

                      final controller = ref.read(historyController);

                      AppDialog.showDialogProgress();

                      await controller.deleteCategory(categories[i]);

                      AppDialog.closeDialog();
                      AppDialog.closeDialog();
                    },
                    child: Ink(
                      color: AppColors.white,
                      padding: EdgeInsets.all(AppSizes.padding),
                      child: Text(
                        '🗑️',
                        style: AppTextStyle.medium(
                          size: 12,
                          color: AppColors.blackLv3,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
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
            text: 'Close',
            buttonColor: Colors.white,
            borderColor: Colors.transparent,
            textColor: AppColors.blackLv1,
            onTap: () => context.pop(),
          ),
        ),
        SizedBox(width: AppSizes.padding / 2),
        Expanded(
          child: AppButton(
            text: '+ New Category',
            buttonColor: Colors.white,
            borderColor: Colors.transparent,
            textColor: AppColors.blackLv1,
            disabledButtonColor: AppColors.white,
            onTap: () {
              context.pop();
              AppDialog.show(
                showButtons: false,
                title: 'Add New Category',
                child: CategoryFormDialog(),
              );
            },
          ),
        ),
      ],
    );
  }
}
