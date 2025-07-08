import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_sizes.dart';
import '../../../../app/theme/app_text_style.dart';
import '../../../../app/utilities/date_formatter.dart';
import '../../../widgets/app_button.dart';

class PeriodFilterButton extends ConsumerWidget {
  final DateTime selectedPeriod;
  final Function(DateTime) onSelectDate;
  final bool showTitle;

  const PeriodFilterButton({
    super.key,
    required this.selectedPeriod,
    required this.onSelectDate,
    this.showTitle = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppButton(
      buttonColor: AppColors.blackLv6,
      borderRadius: BorderRadius.circular(0),
      showBorder: false,
      child: Row(
        mainAxisAlignment: showTitle
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showTitle)
                Text(
                  'Period',
                  style: AppTextStyle.bold(size: 8),
                ),
              if (showTitle) SizedBox(height: 2),
              Text(
                DateFormatter.onlyMonthAndYear(
                  selectedPeriod.toIso8601String(),
                ),
                style: AppTextStyle.bold(size: 12),
              ),
            ],
          ),
          SizedBox(width: AppSizes.padding / 4),
          Icon(
            showTitle
                ? Icons.calendar_today_outlined
                : Icons.keyboard_arrow_down_rounded,
            color: AppColors.blackLv1,
            size: showTitle ? 16 : 22,
          ),
        ],
      ),
      onTap: () async {
        final initialDate = selectedPeriod;
        final firstDate = initialDate.subtract(const Duration(days: 365 * 100));
        final lastDate = firstDate.add(const Duration(days: 365 * 200));

        final selectedDate = await showMonthPicker(
          context: context,
          initialDate: initialDate,
          firstDate: firstDate,
          lastDate: lastDate,
          monthPickerDialogSettings: MonthPickerDialogSettings(
            headerSettings: PickerHeaderSettings(
              headerBackgroundColor: AppColors.white,
            ),
            dialogSettings: PickerDialogSettings(
              dismissible: true,
              dialogRoundedCornersRadius: AppSizes.radius,
              insetPadding: EdgeInsets.all(AppSizes.padding),
            ),
            dateButtonsSettings: PickerDateButtonsSettings(
              currentMonthTextColor: AppColors.blackLv1,
              selectedMonthTextColor: AppColors.blackLv1,
              unselectedMonthsTextColor: AppColors.blackLv1,
              selectedMonthBackgroundColor: AppColors.tangerineLv1,
            ),
            actionBarSettings: PickerActionBarSettings(
              actionBarPadding: EdgeInsets.all(AppSizes.padding),
            ),
          ),
        );

        if (selectedDate == null) return null;

        onSelectDate(selectedDate);
      },
    );
  }
}
