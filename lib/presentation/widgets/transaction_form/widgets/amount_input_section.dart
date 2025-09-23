import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/providers/currency_provider.dart';
import '../../../../core/theme/app_theme.dart';

/// Amount Input Section Widget
/// Provides amount input with quick amount buttons
/// Author: Pown Kumar - Founder of Korelium
/// Date: September 18, 2025

class AmountInputSection extends StatelessWidget {
  final TextEditingController amountController;
  final VoidCallback onAmountChanged;
  final List<double> quickAmounts;

  const AmountInputSection({
    super.key,
    required this.amountController,
    required this.onAmountChanged,
    this.quickAmounts = const [100, 500, 1000, 2000, 5000],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        // Amount Input
        TextFormField(
          controller: amountController,
          style: TextStyle(
            color: AppTheme.lightText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: '0.00',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.currency_rupee),
            suffixText: 'INR',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => onAmountChanged(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter amount';
            }
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return 'Please enter a valid amount';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 12),
        
        // Quick Amount Buttons
        Text(
          'Quick Amounts',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: quickAmounts.length,
            itemBuilder: (context, index) {
              final amount = quickAmounts[index];
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    amountController.text = amount.toString();
                    onAmountChanged();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      '${context.read<CurrencyProvider>().currencySymbol}${amount.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
