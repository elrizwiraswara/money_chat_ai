import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_sizes.dart';
import '../../../../app/theme/app_text_style.dart';
import '../../../../app/utilities/currency_formatter.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_toast.dart';
import '../../main/controller/main_controller.dart';

class TransactionDetailDialog extends ConsumerStatefulWidget {
  final TransactionModel transaction;

  const TransactionDetailDialog({
    super.key,
    required this.transaction,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ManualEntryFormState();
}

class _ManualEntryFormState extends ConsumerState<TransactionDetailDialog> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context.pop(),
        child: Center(
          child: Container(
            alignment: Alignment.center,
            constraints: BoxConstraints(
              maxWidth: 512 + (AppSizes.padding * 2),
            ),
            child: Container(
              margin: EdgeInsets.all(AppSizes.padding * 2),
              padding: EdgeInsets.all(AppSizes.padding),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSizes.radius),
              ),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    title(),
                    SizedBox(height: AppSizes.padding / 1.5),
                    transactionId(),
                    SizedBox(height: AppSizes.padding),
                    transactionCategory(),
                    SizedBox(height: AppSizes.padding),
                    transactionDesc(),
                    SizedBox(height: AppSizes.padding),
                    if (widget.transaction.items?.isNotEmpty ?? false)
                      transactionItems(),
                    if (widget.transaction.items?.isNotEmpty ?? false)
                      SizedBox(height: AppSizes.padding),
                    if (widget.transaction.items?.isNotEmpty ?? false)
                      subtotal(),
                    if (widget.transaction.items?.isNotEmpty ?? false)
                      SizedBox(height: AppSizes.padding),
                    if ((widget.transaction.discount ?? 0) > 0) discount(),
                    if ((widget.transaction.discount ?? 0) > 0)
                      SizedBox(height: AppSizes.padding),
                    transactionTotal(),
                    SizedBox(height: AppSizes.padding),
                    closeButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget title() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.padding,
          AppSizes.padding,
          AppSizes.padding,
          0,
        ),
        child: Text(
          'Record Detail',
          textAlign: TextAlign.center,
          style: AppTextStyle.extraBold(size: 14),
        ),
      ),
    );
  }

  Widget transactionId() {
    return Center(
      child: AppButton(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.padding / 2,
          vertical: AppSizes.padding / 4,
        ),
        buttonColor: AppColors.white,
        alignment: null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${widget.transaction.id}',
              style: AppTextStyle.semibold(size: 12, color: AppColors.blackLv3),
            ),
            SizedBox(width: 2),
            Icon(
              Icons.content_copy_rounded,
              color: AppColors.blackLv3,
              size: 14,
            ),
          ],
        ),
        onTap: () async {
          await Clipboard.setData(
            ClipboardData(text: '${widget.transaction.id}'),
          );

          AppToast.show(message: 'ID copied to clipboard');
        },
      ),
    );
  }

  Widget transactionCategory() {
    final category = ref
        .read(mainController)
        .getCategory(widget.transaction.categoryId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: AppTextStyle.semibold(size: 10, color: AppColors.blackLv3),
        ),
        SizedBox(height: 2),
        Text(
          category?.id != null ? category?.name ?? '-' : '-',
          style: AppTextStyle.semibold(size: 14),
        ),
      ],
    );
  }

  Widget transactionDesc() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: AppTextStyle.semibold(size: 10, color: AppColors.blackLv3),
        ),
        SizedBox(height: 2),
        Text(
          '${widget.transaction.merchant}',
          style: AppTextStyle.semibold(size: 14),
        ),
      ],
    );
  }

  Widget transactionItems() {
    final isIncome = ref
        .read(mainController)
        .isIncomeCategory(widget.transaction.categoryId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Items',
          style: AppTextStyle.semibold(size: 10, color: AppColors.blackLv3),
        ),
        SizedBox(height: 2),
        ...List.generate(widget.transaction.items!.length, (i) {
          return Text(
            'x${widget.transaction.items![i].qty} ${widget.transaction.items![i].name} ${isIncome ? '+' : '-'}${CurrencyFormatter.format(widget.transaction.items![i].price ?? 0)}',
            style: AppTextStyle.semibold(size: 14),
          );
        }),
      ],
    );
  }

  Widget subtotal() {
    final subtotal =
        widget.transaction.items?.fold<double>(
          0,
          (sum, item) => sum + ((item.price ?? 0) * (item.qty ?? 0)),
        ) ??
        widget.transaction.amount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subtotal',
          style: AppTextStyle.semibold(size: 10, color: AppColors.blackLv3),
        ),
        SizedBox(height: 2),
        Text(
          CurrencyFormatter.format(subtotal ?? 0),
          style: AppTextStyle.semibold(size: 14),
        ),
      ],
    );
  }

  Widget discount() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Discount',
          style: AppTextStyle.semibold(size: 10, color: AppColors.blackLv3),
        ),
        SizedBox(height: 2),
        Text(
          CurrencyFormatter.format(widget.transaction.discount ?? 0),
          style: AppTextStyle.semibold(size: 14),
        ),
      ],
    );
  }

  Widget transactionTotal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total',
          style: AppTextStyle.semibold(size: 10, color: AppColors.blackLv3),
        ),
        SizedBox(height: 2),
        Text(
          CurrencyFormatter.format(widget.transaction.amount ?? 0),
          style: AppTextStyle.semibold(size: 14),
        ),
      ],
    );
  }

  Widget closeButton() {
    return Center(
      child: AppButton(
        text: 'Close',
        buttonColor: Colors.white,
        borderColor: Colors.transparent,
        textColor: AppColors.blackLv1,
        onTap: () async {
          context.pop();
        },
      ),
    );
  }
}
