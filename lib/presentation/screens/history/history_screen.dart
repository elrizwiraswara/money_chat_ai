import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/enum/category_type.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_sizes.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../app/utilities/currency_formatter.dart';
import '../../../app/utilities/date_formatter.dart';
import '../../../app/utilities/emoji_splitter.dart';
import '../../../data/models/transaction_model.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_empty_indicator.dart';
import '../../widgets/app_progress_indicator.dart';
import '../main/controller/main_controller.dart';
import 'components/category_dialog.dart';
import 'components/floating_action_button.dart';
import 'components/period_filter_button.dart';
import 'components/transaction_detail_dialog.dart';
import 'components/transaction_form_dialog.dart';
import 'controller/history_controller.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? param;

  const HistoryScreen({super.key, this.param});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(historyController);

      if (widget.param != null) {
        if (widget.param!['category'] != null) {
          controller.selectedCategoryFilter = widget.param!['category'];
        }

        if (widget.param!['date'] != null) {
          controller.selectedPeriodFilter = widget.param!['date'];
        }

        controller.getTransactions();
      } else {
        controller.getTransactions();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          filter(),
          historyList(),
        ],
      ),
      floatingActionButton: HistoryFloatingActionButton(),
    );
  }

  Widget filter() {
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
          Expanded(
            child: categoryFilterButton(),
          ),
          Container(
            width: 1,
            color: AppColors.blackLv5,
          ),
          Expanded(
            child: periodFilterButton(),
          ),
        ],
      ),
    );
  }

  Widget categoryFilterButton() {
    final selectedCategoryFilter = ref
        .watch(historyController)
        .selectedCategoryFilter;

    return AppButton(
      buttonColor: AppColors.blackLv6,
      borderRadius: BorderRadius.circular(0),
      showBorder: false,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Category',
                style: AppTextStyle.bold(size: 8),
              ),
              SizedBox(height: 2),
              Text(
                selectedCategoryFilter?.name ?? 'All',
                style: AppTextStyle.bold(size: 12),
              ),
            ],
          ),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.blackLv1,
            size: 26,
          ),
        ],
      ),
      onTap: () async {
        final category = await AppDialog.show(
          title: 'Choose Category',
          child: CategoryDialog(
            currentCategory: selectedCategoryFilter,
          ),
          showButtons: false,
        );

        ref.read(historyController).onChangedCategoryFilter(category);
      },
    );
  }

  Widget periodFilterButton() {
    final selectedPeriod = ref.watch(historyController).selectedPeriodFilter;

    return PeriodFilterButton(
      selectedPeriod: selectedPeriod,
      onSelectDate: (val) {
        ref.read(historyController).onChangedPeriodFilter(val);
      },
    );
  }

  Widget historyList() {
    final history = ref.watch(historyController).transactionHistory;

    if (history == null) {
      return Expanded(child: AppProgressIndicator());
    }

    if (history.isEmpty) {
      return Expanded(child: AppEmptyIndicator());
    }

    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.all(AppSizes.padding),
        itemCount: history.length,
        itemBuilder: (context, i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.padding),
            child: historyItem(history[i]),
          );
        },
      ),
    );
  }

  Widget historyItem(TransactionModel item) {
    final category = ref
        .read(mainController)
        .categories
        .where((e) => e.id == item.categoryId)
        .firstOrNull;

    final isIncome = ref.read(mainController).isIncomeCategory(category?.id);

    return AppButton(
      buttonColor: AppColors.blackLv5,
      padding: EdgeInsets.fromLTRB(
        AppSizes.padding,
        AppSizes.padding,
        AppSizes.padding / 4,
        AppSizes.padding,
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(minWidth: 32),
                  child: Text(
                    category?.id != null
                        ? splitEmoji(category?.name).emoji
                        : '❓',
                    style: AppTextStyle.bold(size: 26),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(width: AppSizes.padding),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.id ?? '-',
                        style: AppTextStyle.semibold(
                          size: 10,
                          color: AppColors.blackLv2,
                        ),
                      ),
                      Text(
                        '${item.merchant} ${(item.items?.isNotEmpty ?? false) ? '(${item.items!.length} Items)' : ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.semibold(size: 14),
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
                  size: 16,
                  color: isIncome ? AppColors.greenLv1 : AppColors.redLv1,
                ),
              ),
            ],
          ),
          PopupMenuButton(
            color: Colors.white,
            menuPadding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(AppSizes.radius),
            iconSize: 24,
            offset: Offset(0, 42),
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  height: 40,
                  child: Text(
                    '✏️ Edit',
                    style: AppTextStyle.semibold(size: 12),
                  ),
                  onTap: () {
                    AppDialog.show(
                      title: 'Edit Record',
                      child: TransactionFormDialog(
                        transaction: item,
                        type: CategoryType.fromValue(item.type),
                      ),
                    );
                  },
                ),
                PopupMenuItem(
                  height: 40,
                  child: Text(
                    '🗑 Delete',
                    style: AppTextStyle.semibold(size: 12),
                  ),
                  onTap: () async {
                    final confirm = await AppDialog.show(
                      title: 'Confirm',
                      text: 'Are you sure want to delete this record?',
                      leftButtonText: 'Cancel',
                      rightButtonText: 'Delete',
                      onTapRightButton: () => context.pop(true),
                    );

                    if (confirm == null) return;

                    AppDialog.showDialogProgress();

                    await ref
                        .read(historyController)
                        .deleteTransaction(id: item.id!);

                    AppDialog.closeDialog();
                  },
                ),
              ];
            },
          ),
        ],
      ),
      onTap: () async {
        showDialog(
          context: context,
          builder: (context) {
            return TransactionDetailDialog(transaction: item);
          },
        );
      },
    );
  }
}
