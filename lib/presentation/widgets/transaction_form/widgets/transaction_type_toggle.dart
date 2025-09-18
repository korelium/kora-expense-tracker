import 'package:flutter/material.dart';
import '../../../../data/models/transaction.dart';

/// Transaction Type Toggle Widget
/// Provides a modern toggle between Income and Expense
/// Author: Pown Kumar - Founder of Korelium
/// Date: September 18, 2025

class TransactionTypeToggle extends StatelessWidget {
  final TransactionType selectedType;
  final ValueChanged<TransactionType> onTypeChanged;

  const TransactionTypeToggle({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transaction Type',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildTypeButton(
                  context: context,
                  type: TransactionType.expense,
                  icon: Icons.trending_down,
                  label: 'Expense',
                  color: Colors.red,
                  isLeft: true,
                ),
              ),
              Expanded(
                child: _buildTypeButton(
                  context: context,
                  type: TransactionType.income,
                  icon: Icons.trending_up,
                  label: 'Income',
                  color: Colors.green,
                  isLeft: false,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeButton({
    required BuildContext context,
    required TransactionType type,
    required IconData icon,
    required String label,
    required Color color,
    required bool isLeft,
  }) {
    final isSelected = selectedType == type;
    
    return GestureDetector(
      onTap: () => onTypeChanged(type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isLeft ? 16 : 0),
            bottomLeft: Radius.circular(isLeft ? 16 : 0),
            topRight: Radius.circular(isLeft ? 0 : 16),
            bottomRight: Radius.circular(isLeft ? 0 : 16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
