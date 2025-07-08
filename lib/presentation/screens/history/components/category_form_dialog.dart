import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_chat_ai/core/extensions/string_casing_extension.dart';

import '../../../../app/enum/category_type.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_sizes.dart';
import '../../../../app/theme/app_text_style.dart';
import '../../../../data/models/category_model.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_dialog.dart';
import '../../../widgets/app_drop_down.dart';
import '../../../widgets/app_text_field.dart';
import '../controller/history_controller.dart';

class CategoryFormDialog extends ConsumerStatefulWidget {
  final CategoryModel? category;

  const CategoryFormDialog({
    super.key,
    this.category,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ManualEntryFormState();
}

class _ManualEntryFormState extends ConsumerState<CategoryFormDialog> {
  final idController = TextEditingController();
  final nameController = TextEditingController();

  CategoryType? selectedType;
  Color? selectedColor;

  String toHex(Color color, {bool leadingHashSign = true}) {
    final r = (color.r * 255).round() & 0xff;
    final g = (color.g * 255).round() & 0xff;
    final b = (color.b * 255).round() & 0xff;
    return '${leadingHashSign ? '#' : ''}'
        '${r.toRadixString(16).padLeft(2, '0')}'
        '${g.toRadixString(16).padLeft(2, '0')}'
        '${b.toRadixString(16).padLeft(2, '0')}';
  }

  @override
  void initState() {
    if (widget.category != null) {
      idController.text = widget.category?.id ?? '';
      nameController.text = widget.category?.name ?? '';
      selectedType = CategoryType.fromValue(widget.category?.type);
      selectedColor = Color(
        widget.category?.color ?? AppColors.tangerineLv1.toARGB32(),
      );
    }
    super.initState();
  }

  @override
  void dispose() {
    idController.dispose();
    nameController.dispose();
    super.dispose();
  }

  bool isValid() {
    final validator = [
      idController.text.isNotEmpty,
      nameController.text.isNotEmpty,
      selectedType != null,
      selectedColor != null,
    ];

    return !validator.contains(false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        idField(),
        SizedBox(height: AppSizes.padding),
        nameField(),
        SizedBox(height: AppSizes.padding),
        typeField(),
        SizedBox(height: AppSizes.padding),
        colorField(),
        SizedBox(height: AppSizes.padding),
        buttons(),
      ],
    );
  }

  Widget idField() {
    return AppTextField(
      controller: idController,
      enabled: widget.category == null,
      labelText: 'ID',
      hintText: 'e.g. food',
      fillColor: AppColors.blackLv5,
      showBorder: true,
      maxLength: 10,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
      ],
    );
  }

  Widget nameField() {
    return AppTextField(
      controller: nameController,
      labelText: 'Name',
      hintText: 'e.g. Food & Beverages',
      fillColor: AppColors.blackLv5,
      showBorder: true,
      maxLength: 20,
    );
  }

  Widget typeField() {
    final types = CategoryType.values;

    return AppDropDown(
      labelText: 'Type',
      hintText: 'Choose category type',
      fillColor: AppColors.blackLv5,
      selectedValue: selectedType?.name,
      dropdownItems: List.generate(
        types.length,
        (i) => DropdownMenuItem<String>(
          value: types[i].name,
          child: Text(types[i].name.toTitleCase()),
        ),
      ),
      onChanged: (val) {
        if (val == null) return;
        selectedType = types.where((e) => e.name == val).firstOrNull;
        setState(() {});
      },
    );
  }

  Widget colorField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Color',
            style: AppTextStyle.bold(size: 12),
          ),
        ),
        AppButton(
          buttonColor: AppColors.blackLv5,
          showBorder: false,
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                margin: EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selectedColor ?? AppColors.blackLv4,
                ),
              ),
              Text(
                selectedColor != null
                    ? toHex(selectedColor!).toUpperCase()
                    : 'Choose color',
                style: AppTextStyle.semibold(size: 12),
              ),
            ],
          ),
          onTap: () {
            AppDialog.show(
              title: 'Choose Color',
              maxWidth: 400,
              child: MaterialColorPicker(
                selectedColor: selectedColor,
                onColorChange: (Color color) {
                  selectedColor = color;
                  setState(() {});
                },
              ),
              rightButtonText: 'OK',
            );
          },
        ),
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
            enabled: isValid(),
            showBorder: false,
            onTap: () async {
              final controller = ref.read(historyController);

              AppDialog.showDialogProgress();

              final category = CategoryModel(
                id: idController.text,
                name: nameController.text,
                type: selectedType!.name,
                color: selectedColor?.toARGB32(),
              );

              await controller.createOrUpdateCategory(category);

              AppDialog.closeDialog();
              AppDialog.closeDialog();
            },
          ),
        ),
      ],
    );
  }
}
