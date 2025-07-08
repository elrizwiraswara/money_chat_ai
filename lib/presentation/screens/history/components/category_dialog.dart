import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_sizes.dart';
import '../../../../app/theme/app_text_style.dart';
import '../../../../data/models/category_model.dart';
import '../../../widgets/app_button.dart';
import '../../main/controller/main_controller.dart';

class CategoryDialog extends ConsumerStatefulWidget {
  final CategoryModel? currentCategory;

  const CategoryDialog({
    super.key,
    this.currentCategory,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ManualEntryFormState();
}

class _ManualEntryFormState extends ConsumerState<CategoryDialog> {
  CategoryModel? selectedCategory;

  @override
  void initState() {
    if (widget.currentCategory != null) {
      selectedCategory = widget.currentCategory;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.read(mainController).categories;

    return Column(
      children: [
        ListView.builder(
          itemCount: categories.length,
          shrinkWrap: true,
          itemBuilder: (context, i) {
            return InkWell(
              onTap: () {
                selectedCategory = categories[i];
                setState(() {});
              },
              child: Ink(
                color: selectedCategory?.id == categories[i].id
                    ? AppColors.blackLv5
                    : AppColors.white,
                padding: EdgeInsets.all(AppSizes.padding),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        categories[i].name ?? '-',
                        style: selectedCategory?.id == categories[i].id
                            ? AppTextStyle.bold(size: 14)
                            : AppTextStyle.semibold(size: 14),
                      ),
                    ),
                    if (categories[i].id != null)
                      Text(
                        '${categories[i].id}',
                        style: selectedCategory?.id == categories[i].id
                            ? AppTextStyle.semibold(
                                size: 12,
                                color: AppColors.blackLv3,
                              )
                            : AppTextStyle.medium(
                                size: 12,
                                color: AppColors.blackLv3,
                              ),
                      ),
                  ],
                ),
              ),
            );
          },
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
            enabled: selectedCategory != null,
            text: 'Confirm',
            buttonColor: Colors.white,
            borderColor: Colors.transparent,
            textColor: AppColors.blackLv1,
            disabledButtonColor: AppColors.white,
            onTap: () => context.pop(
              selectedCategory?.id == null ? null : selectedCategory,
            ),
          ),
        ),
      ],
    );
  }
}
