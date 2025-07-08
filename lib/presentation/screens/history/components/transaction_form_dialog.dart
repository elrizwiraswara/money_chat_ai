import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/enum/category_type.dart';
import '../../../../app/enum/input_source.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_sizes.dart';
import '../../../../app/theme/app_text_style.dart';
import '../../../../app/utilities/date_formatter.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_dialog.dart';
import '../../../widgets/app_drop_down.dart';
import '../../../widgets/app_text_field.dart';
import '../../main/controller/main_controller.dart';
import '../controller/history_controller.dart';

class TransactionFormDialog extends ConsumerStatefulWidget {
  final TransactionModel? transaction;
  final CategoryType type;

  const TransactionFormDialog({
    super.key,
    this.transaction,
    this.type = CategoryType.expenses,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ManualEntryFormState();
}

class _ManualEntryFormState extends ConsumerState<TransactionFormDialog> {
  final amountController = TextEditingController();
  final descController = TextEditingController();

  TransactionModel transaction = TransactionModel();
  CategoryModel? selectedCategory;

  @override
  void initState() {
    final categories = ref.read(mainController).categories;
    final incomeCategories = ref.read(mainController).incomeCategories;

    if (widget.transaction != null) {
      transaction = widget.transaction!;
      selectedCategory = categories
          .where((e) => e.id == widget.transaction?.categoryId)
          .firstOrNull;

      amountController.text = '${widget.transaction!.amount ?? 0}';
      descController.text = widget.transaction?.merchant ?? '';
    }

    if (widget.type == CategoryType.income) {
      selectedCategory = incomeCategories.firstOrNull;
      transaction.categoryId = selectedCategory?.id;
    }
    super.initState();
  }

  @override
  void dispose() {
    amountController.dispose();
    descController.dispose();
    super.dispose();
  }

  bool isValid() {
    final validator = [
      transaction.categoryId != null,
      transaction.amount != null,
      transaction.merchant != null,
      transaction.date != null,
    ];

    return !validator.contains(false);
  }

  Future<DateTime?> showDateTimePicker({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    initialDate ??= DateTime.now();
    firstDate ??= initialDate.subtract(const Duration(days: 365 * 100));
    lastDate ??= firstDate.add(const Duration(days: 365 * 200));

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDatePickerMode: DatePickerMode.day,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );

    if (selectedDate == null) return null;

    if (!context.mounted) return selectedDate;

    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
      initialEntryMode: TimePickerEntryMode.dialOnly,
    );

    return selectedTime == null
        ? selectedDate
        : DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        amountField(),
        SizedBox(height: AppSizes.padding),
        descField(),
        SizedBox(height: AppSizes.padding),
        categoryField(),
        SizedBox(height: AppSizes.padding),
        dateField(),
        SizedBox(height: AppSizes.padding),
        buttons(),
      ],
    );
  }

  Widget amountField() {
    return AppTextField(
      controller: amountController,
      labelText: 'Amount',
      hintText: 'e.g. 10.000',
      fillColor: AppColors.blackLv5,
      showBorder: true,
      type: AppTextFieldType.currency,
      onChanged: (val) {
        transaction.amount = double.tryParse(amountController.text);
        setState(() {});
      },
    );
  }

  Widget descField() {
    return AppTextField(
      controller: descController,
      labelText: 'Description',
      hintText: 'e.g. FamilyMart',
      fillColor: AppColors.blackLv5,
      showBorder: true,
      maxLength: 30,
      onChanged: (val) {
        transaction.merchant = descController.text;
        setState(() {});
      },
    );
  }

  Widget categoryField() {
    final expensesCategories = ref.watch(mainController).expensesCategories;
    final incomeCategories = ref.watch(mainController).incomeCategories;

    final showingCategories = widget.type == CategoryType.expenses
        ? expensesCategories
        : incomeCategories;

    return AppDropDown(
      labelText: 'Category',
      hintText: 'Choose category',
      fillColor: AppColors.blackLv5,
      selectedValue: selectedCategory?.id,
      dropdownItems: List.generate(
        showingCategories.length,
        (i) => DropdownMenuItem<String>(
          value: showingCategories[i].id,
          child: Text(showingCategories[i].name ?? ''),
        ),
      ),
      onChanged: (val) {
        if (val == null) return;

        selectedCategory = showingCategories
            .where((e) => e.id == val)
            .firstOrNull;

        transaction.categoryId = val;
        setState(() {});
      },
    );
  }

  Widget dateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Date & Time',
            style: AppTextStyle.bold(size: 14),
          ),
        ),
        AppButton(
          alignment: Alignment.centerLeft,
          buttonColor: AppColors.blackLv5,
          showBorder: false,
          padding: EdgeInsets.all(AppSizes.padding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                transaction.date != null
                    ? DateFormatter.normalWithClock(transaction.date!)
                    : 'Choose date & time',
                style: transaction.date != null
                    ? AppTextStyle.semibold(size: 12)
                    : AppTextStyle.medium(
                        size: 12,
                        color: AppColors.blackLv3,
                      ),
              ),
              Icon(
                Icons.calendar_today_outlined,
                color: AppColors.blackLv3,
                size: 14,
              ),
            ],
          ),
          onTap: () async {
            final date = await showDateTimePicker(context: context);
            transaction.date = date?.toUtc().toIso8601String();
            setState(() {});
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

              await controller.createTransaction(
                trx: transaction,
                type: widget.type,
                source: InputSource.manual,
              );

              AppDialog.closeDialog();
              AppDialog.closeDialog();
            },
          ),
        ),
      ],
    );
  }
}
