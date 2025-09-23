import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/account.dart';
import '../../../../data/providers/currency_provider.dart';

/// Account Selector Widget
/// Provides account selection with balance display
/// Author: Pown Kumar - Founder of Korelium
/// Date: September 18, 2025

class AccountSelector extends StatelessWidget {
  final String? selectedAccountId;
  final List<Account> accounts;
  final ValueChanged<String?> onAccountChanged;

  const AccountSelector({
    super.key,
    required this.selectedAccountId,
    required this.accounts,
    required this.onAccountChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        // Validate that the selected account exists in the list
        Builder(
          builder: (context) {
            final validAccountId = selectedAccountId != null && 
                accounts.any((a) => a.id == selectedAccountId) 
                ? selectedAccountId 
                : null;
            
            return DropdownButtonFormField<String>(
              value: validAccountId,
              isExpanded: true,
              menuMaxHeight: 300,
              decoration: InputDecoration(
                labelText: 'Select Account',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.account_balance_wallet),
              ),
              items: accounts.map<DropdownMenuItem<String>>((account) {
                return DropdownMenuItem(
                  value: account.id,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        account.type.toString() == 'AccountType.bank'
                            ? Icons.account_balance
                            : Icons.money,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '${account.name} - ${context.read<CurrencyProvider>().currencySymbol}${account.balance.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: account.balance >= 0 ? Colors.black87 : Colors.red,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onAccountChanged,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select an account';
                }
                return null;
              },
            );
          },
        ),
      ],
    );
  }
}
