import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/currency_provider.dart';
import '../../../data/providers/transaction_provider_hive.dart';
import '../../../data/models/account.dart';
import 'add_account_screen.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<CurrencyProvider, TransactionProviderHive>(
      builder: (context, currencyProvider, transactionProvider, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            title: const Text('Accounts'),
            backgroundColor: Theme.of(context).colorScheme.surface,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            elevation: 0,
            actions: [
              // Fix negative balances button (only show if there are negative balances)
              if (transactionProvider.accounts.any((account) => account.balance < 0))
                IconButton(
                  icon: const Icon(Icons.warning_amber),
                  tooltip: 'Fix Negative Balances',
                  onPressed: () => _fixNegativeBalances(context, transactionProvider),
                ),
            ],
          ),
          body: transactionProvider.accounts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No Accounts Yet',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Add your first account to start tracking your finances',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Summary Section
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.surfaceContainer,
                            Theme.of(context).colorScheme.surfaceContainerHighest,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                          BoxShadow(
                            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSummaryItem(context, 'Total Assets', currencyProvider.formatAmount(
                            transactionProvider.accounts.fold(0.0, (sum, account) => sum + account.balance)
                          )),
                          _buildSummaryItem(context, 'Accounts', transactionProvider.accounts.length.toString()),
                        ],
                      ),
                    ),
                    // Accounts List
                    Expanded(
                      child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: transactionProvider.accounts.length,
                  itemBuilder: (context, index) {
                    final account = transactionProvider.accounts[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.surface,
                            Theme.of(context).colorScheme.surfaceContainer,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                          BoxShadow(
                            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        leading: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            _getAccountIcon(account.type),
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        title: Text(
                          account.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getAccountTypeName(account.type),
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                            if (account.description != null && account.description!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                account.description!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  currencyProvider.formatAmount(account.balance),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: account.balance >= 0 
                                        ? const Color(0xFF22C55E) 
                                        : const Color(0xFFEF4444),
                                  ),
                                ),
                                Text(
                                  account.balance >= 0 ? 'Available' : 'Overdraft',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            PopupMenuButton<String>(
                              icon: Icon(
                                Icons.more_vert,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
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
                    ),
                  ],
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
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _fixNegativeBalances(BuildContext context, TransactionProviderHive transactionProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fix Negative Balances'),
        content: const Text(
          'Asset accounts (Cash and Bank) cannot have negative balances. This will set all negative balances to ₹0.00. Continue?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await transactionProvider.fixNegativeBalances();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Negative balances fixed successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error fixing balances: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Fix'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  IconData _getAccountIcon(accountType) {
    switch (accountType.toString()) {
      case 'AccountType.bank':
        return Icons.account_balance;
      case 'AccountType.cash':
        return Icons.money;
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
              context.read<TransactionProviderHive>().deleteAccount(account.id);
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
