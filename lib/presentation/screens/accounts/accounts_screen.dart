import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/currency_provider.dart';
import '../../../data/providers/transaction_provider.dart';
import '../../../data/models/account.dart';
import 'add_account_screen.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<CurrencyProvider, TransactionProvider>(
      builder: (context, currencyProvider, transactionProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Accounts'),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          body: transactionProvider.accounts.isEmpty
              ? const Center(
                  child: Text('No accounts found. Add your first account!'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: transactionProvider.accounts.length,
                  itemBuilder: (context, index) {
                    final account = transactionProvider.accounts[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Icon(
                            _getAccountIcon(account.type),
                            color: Colors.white,
                          ),
                        ),
                        title: Text(account.name),
                        subtitle: Text(_getAccountTypeName(account.type)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              currencyProvider.formatAmount(account.balance),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddAccountScreen(account: account),
                                    ),
                                  );
                                } else if (value == 'delete') {
                                  _confirmDeleteAccount(context, account);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Delete', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddAccountScreen(),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  IconData _getAccountIcon(accountType) {
    switch (accountType.toString()) {
      case 'AccountType.bank':
        return Icons.account_balance;
      case 'AccountType.cash':
        return Icons.money;
      case 'AccountType.creditCard':
        return Icons.credit_card;
      case 'AccountType.investment':
        return Icons.trending_up;
      default:
        return Icons.account_balance_wallet;
    }
  }

  String _getAccountTypeName(accountType) {
    switch (accountType.toString()) {
      case 'AccountType.bank':
        return 'Bank Account';
      case 'AccountType.cash':
        return 'Cash';
      case 'AccountType.creditCard':
        return 'Credit Card (Liability)';
      case 'AccountType.investment':
        return 'Investment';
      case 'AccountType.liability':
        return 'Liability';
      default:
        return 'Account';
    }
  }

  void _confirmDeleteAccount(BuildContext context, Account account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Text('Are you sure you want to delete "${account.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<TransactionProvider>().deleteAccount(account.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deleted successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
