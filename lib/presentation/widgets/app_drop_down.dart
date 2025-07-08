import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_sizes.dart';
import '../../app/theme/app_text_style.dart';

class AppDropDown<T> extends StatelessWidget {
  final T? selectedValue;
  final List<DropdownMenuItem<T>> dropdownItems;
  final Function(T?) onChanged;
  final bool enabled;
  final String? labelText;
  final String? hintText;
  final double fontSize;
  final EdgeInsets contentPadding;
  final Color fillColor;

  const AppDropDown({
    super.key,
    this.selectedValue,
    required this.dropdownItems,
    required this.onChanged,
    this.enabled = true,
    this.labelText,
    this.hintText,
    this.fontSize = 12,
    this.contentPadding = const EdgeInsets.all(AppSizes.padding),
    this.fillColor = AppColors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (labelText != null && labelText != '')
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                labelText!,
                style: AppTextStyle.bold(size: fontSize),
              ),
            ),
          DropdownButtonFormField<T>(
            value: selectedValue,
            onChanged: enabled ? onChanged : null,
            items: dropdownItems,
            style: AppTextStyle.semibold(size: 12),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.blackLv3,
              size: 22,
            ),
            dropdownColor: Colors.white,
            borderRadius: const BorderRadius.all(
              Radius.circular(AppSizes.radius),
            ),
            decoration: InputDecoration(
              enabled: enabled,
              isDense: true,
              filled: true,
              fillColor: enabled ? fillColor : AppColors.blackLv5,
              hintText: hintText,
              hintStyle: AppTextStyle.medium(
                size: 12,
                color: AppColors.blackLv3,
              ),
              contentPadding: contentPadding,
              focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  Radius.circular(AppSizes.radius),
                ),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  Radius.circular(AppSizes.radius),
                ),
                borderSide: BorderSide.none,
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  Radius.circular(AppSizes.radius),
                ),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
