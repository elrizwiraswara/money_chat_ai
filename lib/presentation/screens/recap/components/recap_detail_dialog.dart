import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_sizes.dart';
import '../../../../app/theme/app_text_style.dart';
import '../../../../app/utilities/currency_formatter.dart';
import '../../../../app/utilities/date_formatter.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_empty_indicator.dart';
import '../../main/controller/main_controller.dart';
import '../controller/recap_controller.dart';

class RecapDetailDialog extends ConsumerWidget {
  final double total;
  final CategoryModel category;
  final List<TransactionModel> transactions;

  const RecapDetailDialog({
    super.key,
    required this.total,
    required this.category,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isIncome = ref.read(mainController).isIncomeCategory(category.id);

    return Column(
      children: [
        SizedBox(height: AppSizes.padding),
        Text(
          category.name ?? '',
          textAlign: TextAlign.center,
          style: AppTextStyle.extraBold(size: 14),
        ),
        SizedBox(height: AppSizes.padding / 2),
        Text(
          '${total != 0
              ? isIncome
                    ? '+'
                    : '-'
              : ''}${CurrencyFormatter.format(total)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyle.bold(
            size: 16,
            color: total != 0
                ? isIncome
                      ? AppColors.greenLv1
                      : AppColors.redLv1
                : AppColors.blackLv1,
          ),
        ),
        SizedBox(height: AppSizes.padding),
        if (transactions.isNotEmpty)
          ...List.generate(math.min(transactions.length, 5), (i) {
            return Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : AppSizes.padding / 2),
              child: historyItem(ref, transactions[i]),
            );
          })
        else
          AppEmptyIndicator(),
        SizedBox(height: AppSizes.padding),
        Row(
          children: [
            Expanded(child: closeButton()),
            if (transactions.isNotEmpty) SizedBox(width: AppSizes.padding / 2),
            if (transactions.isNotEmpty)
              Expanded(child: seeAllButton(ref, transactions.length)),
          ],
        ),
      ],
    );
  }

  Widget historyItem(WidgetRef ref, TransactionModel item) {
    final isIncome = ref.read(mainController).isIncomeCategory(category.id);

    return AppButton(
      buttonColor: AppColors.blackLv5,
      padding: EdgeInsets.all(AppSizes.padding / 1.5),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  category.name?.split(' ').first ?? '❓',
                  style: AppTextStyle.bold(size: 22),
                ),
                SizedBox(width: AppSizes.padding / 2),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.id ?? '-',
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.semibold(
                          size: 10,
                          color: AppColors.blackLv2,
                        ),
                      ),
                      Text(
                        '${item.merchant} ${(item.items?.isNotEmpty ?? false) ? '(${item.items!.length} Items)' : ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.semibold(size: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.date != null
                    ? DateFormatter.normalWithClock(item.date!)
                    : '-',
                style: AppTextStyle.semibold(
                  size: 11,
                  color: AppColors.blackLv2,
                ),
              ),
              Text(
                '${isIncome ? '+' : '-'}${CurrencyFormatter.compact(item.amount ?? 0)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.bold(
                  size: 12,
                  color: isIncome ? AppColors.greenLv1 : AppColors.redLv1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget seeAllButton(WidgetRef ref, int length) {
    final date = ref.read(recapController).selectedPeriod;

    return AppButton(
      text: 'See All ($length)',
      buttonColor: AppColors.white,
      onTap: () {
        AppRoutes.router.pop();
        AppRoutes.router.go(
          '/history',
          extra: {'category': category, 'date': date},
        );
      },
    );
  }

  Widget closeButton() {
    return AppButton(
      text: 'Close',
      buttonColor: AppColors.white,
      onTap: () {
        AppRoutes.router.pop();
      },
    );
  }
}
