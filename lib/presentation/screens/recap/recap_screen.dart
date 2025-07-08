import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_sizes.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../app/utilities/currency_formatter.dart';
import '../../../app/utilities/emoji_splitter.dart';
import '../../../data/models/category_model.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_empty_indicator.dart';
import '../../widgets/app_icon_button.dart';
import '../history/components/period_filter_button.dart';
import '../main/controller/main_controller.dart';
import 'components/recap_detail_dialog.dart';
import 'controller/recap_controller.dart';

class RecapScreen extends ConsumerStatefulWidget {
  const RecapScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<RecapScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recapController).getRecap();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          periodFilter(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSizes.padding),
              child: Column(
                children: [
                  summaries(),
                  SizedBox(height: AppSizes.padding),
                  recapByCategoryList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget periodFilter() {
    final selectedPeriod = ref.watch(recapController).selectedPeriod;

    return Container(
      constraints: BoxConstraints(maxHeight: 60),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: AppColors.blackLv5,
        ),
      ),
      child: Row(
        children: [
          AppIconButton(
            icon: Icons.keyboard_arrow_left_rounded,
            showBorder: false,
            borderRadius: 0,
            height: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: AppSizes.padding),
            onTap: () {
              ref.read(recapController).onTapPrevMonth();
            },
          ),
          Expanded(
            child: PeriodFilterButton(
              showTitle: false,
              selectedPeriod: selectedPeriod,
              onSelectDate: (val) {
                ref.read(recapController).onChangedPeriodFilter(val);
              },
            ),
          ),
          AppIconButton(
            icon: Icons.keyboard_arrow_right_rounded,
            showBorder: false,
            borderRadius: 0,
            height: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: AppSizes.padding),
            onTap: () {
              ref.read(recapController).onTapNextMonth();
            },
          ),
        ],
      ),
    );
  }

  Widget summaries() {
    final totalIncome = ref.watch(recapController).totalIncome;
    final totalExpenses = ref.watch(recapController).totalExpenses;
    final balance = ref.watch(recapController).balance;

    return Row(
      spacing: AppSizes.padding,
      children: [
        summaryCard(
          title: 'Income',
          amount: totalIncome,
          isPositive: true,
        ),
        summaryCard(
          title: 'Expenses',
          amount: totalExpenses,
          isPositive: false,
        ),
        summaryCard(
          title: 'Balance',
          amount: balance,
          isPositive: !balance.isNegative,
        ),
      ],
    );
  }

  Widget summaryCard({
    required String title,
    required double amount,
    required bool isPositive,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(AppSizes.padding),
        decoration: BoxDecoration(
          color: AppColors.blackLv5,
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyle.bold(size: 12),
            ),
            SizedBox(height: AppSizes.padding / 6),
            Text(
              '${amount != 0
                  ? isPositive
                        ? '+'
                        : amount.isNegative
                        ? ''
                        : '-'
                  : ''}${CurrencyFormatter.compact(amount)}',
              style: AppTextStyle.bold(
                size: 14,
                color: amount != 0
                    ? isPositive
                          ? AppColors.greenLv1
                          : AppColors.redLv1
                    : AppColors.blackLv1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget recapByCategoryList() {
    final categories = ref
        .watch(mainController)
        .categories
        .where((e) => e.id != null)
        .toList();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.padding),
      decoration: BoxDecoration(
        color: AppColors.blackLv5,
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category Ranking',
            style: AppTextStyle.bold(size: 12),
          ),
          SizedBox(height: AppSizes.padding),
          if (categories.isNotEmpty)
            ...(categories.map((category) {
                  final controller = ref.read(recapController);
                  final data = controller.getRecapByCategory(category.id!);
                  return (category, data);
                }).toList()..sort((a, b) => b.$2.$1.compareTo(a.$2.$1)))
                .asMap()
                .entries
                .map((entry) {
                  final category = entry.value.$1;
                  final data = entry.value.$2;

                  return categoryPercentBar(
                    index: entry.key,
                    category: category,
                    percentage: data.$1,
                    amount: data.$2,
                    trxCount: data.$3,
                  );
                })
          else
            SizedBox(
              height: AppSizes.screenHeight(context) / 1.65,
              child: Center(child: AppEmptyIndicator()),
            ),
        ],
      ),
    );
  }

  Widget categoryPercentBar({
    required int index,
    required CategoryModel category,
    required double percentage,
    required double amount,
    required int trxCount,
  }) {
    final isIncome = ref.read(mainController).isIncomeCategory(category.id);

    return Padding(
      padding: EdgeInsets.only(top: index == 0 ? 0 : AppSizes.padding),
      child: LayoutBuilder(
        builder: (context, constraint) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radius),
            child: AppButton(
              buttonColor: AppColors.white,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(AppSizes.padding),
              showBorder: false,
              child: Row(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(minWidth: 32),
                    child: Text(
                      category.id != null
                          ? splitEmoji(category.name).emoji
                          : '❓',
                      style: AppTextStyle.bold(size: 26),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: AppSizes.padding),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              splitEmoji(category.name).name,
                              style: AppTextStyle.bold(size: 12),
                            ),
                            Text(
                              '${amount != 0
                                  ? isIncome
                                        ? '+'
                                        : '-'
                                  : ''}${CurrencyFormatter.format(amount)}',
                              style: AppTextStyle.bold(
                                size: 12,
                                color: amount != 0
                                    ? isIncome
                                          ? AppColors.greenLv1
                                          : AppColors.redLv1
                                    : AppColors.blackLv1,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${percentage.toStringAsFixed(0)}%',
                              style: AppTextStyle.bold(size: 9),
                            ),
                            Text(
                              '$trxCount record',
                              style: AppTextStyle.semibold(
                                size: 9,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSizes.padding / 2),
                        Container(
                          width: constraint.maxWidth,
                          decoration: BoxDecoration(
                            color: AppColors.blackLv5,
                            borderRadius: BorderRadius.circular(
                              AppSizes.radius,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: constraint.maxWidth * (percentage / 100),
                                height: 6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radius,
                                  ),
                                  color: category.color != null
                                      ? Color(category.color!)
                                      : AppColors.blackLv4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              onTap: () {
                final transaction = ref
                    .read(recapController)
                    .transactions
                    .where((e) => e.categoryId == category.id)
                    .toList();

                AppDialog.show(
                  child: RecapDetailDialog(
                    category: category,
                    total: amount,
                    transactions: transaction,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
