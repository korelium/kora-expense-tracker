import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';
import '../providers/transaction_provider.dart';

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
                        trailing: Text(
                          currencyProvider.formatAmount(account.balance),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add account feature coming soon!')),
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
        return 'Credit Card';
      case 'AccountType.investment':
        return 'Investment';
      default:
        return 'Account';
    }
  }
}
