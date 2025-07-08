import 'package:flutter/material.dart';

import '../../../../app/enum/category_type.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_sizes.dart';
import '../../../widgets/app_dialog.dart';
import 'manage_category_dialog.dart';
import 'transaction_form_dialog.dart';

class HistoryFloatingActionButton extends StatefulWidget {
  const HistoryFloatingActionButton({super.key});

  @override
  State<HistoryFloatingActionButton> createState() =>
      _HistoryFloatingActionButtonState();
}

class _HistoryFloatingActionButtonState
    extends State<HistoryFloatingActionButton>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  void _toggleFAB() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        if (_isExpanded) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 170),
            child: _miniFab(
              label: "+ Expenses",
              onTap: () {
                AppDialog.show(
                  title: 'Add Expenses Record',
                  child: TransactionFormDialog(),
                  showButtons: false,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 120),
            child: _miniFab(
              label: "+ Income",
              onTap: () {
                AppDialog.show(
                  title: 'Add Income Record',
                  showButtons: false,
                  child: TransactionFormDialog(
                    type: CategoryType.income,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 70),
            child: _miniFab(
              label: "Manage Category",
              onTap: () {
                AppDialog.show(
                  title: 'Manage Category',
                  showButtons: false,
                  child: ManageCategoryDialog(),
                );
              },
            ),
          ),
        ],
        FloatingActionButton(
          onPressed: _toggleFAB,
          backgroundColor: AppColors.white,
          shape: const CircleBorder(),
          child: Icon(
            _isExpanded ? Icons.close : Icons.add,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _miniFab({required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: () {
        onTap();
        _toggleFAB();
      },
      borderRadius: BorderRadius.circular(AppSizes.radius),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.padding,
          vertical: AppSizes.padding / 1.5,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radius),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 4),
              blurRadius: 4,
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
