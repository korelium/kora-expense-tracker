import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/currency_provider.dart';
import '../../../data/providers/transaction_provider_hive.dart';
import '../../../data/providers/credit_card_provider.dart';
import '../../../data/models/account.dart';
import '../../../data/models/credit_card.dart';
import '../../../core/theme/app_theme.dart';
import 'add_account_screen.dart';
import '../credit_cards/add_credit_card_screen.dart';
import '../credit_cards/credit_card_details_screen.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Refresh credit card provider when screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CreditCardProvider>().refresh();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh credit card provider when app becomes active
      context.read<CreditCardProvider>().refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<CurrencyProvider, TransactionProviderHive, CreditCardProvider>(
      builder: (context, currencyProvider, transactionProvider, creditCardProvider, child) {
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
                            transactionProvider.accounts.fold(0.0, (sum, account) => 
                              account.isAsset ? sum + account.balance : sum - account.balance.abs()
                            )
                          )),
                          _buildSummaryItem(context, 'Accounts', transactionProvider.accounts.length.toString()),
                        ],
                      ),
                    ),
                    // Accounts List
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          // Sort accounts: assets first, then liabilities (alphabetical within each group)
                          final sortedAccounts = List<Account>.from(transactionProvider.accounts);
                          sortedAccounts.sort((a, b) {
                            // First sort by type: assets first, then liabilities
                            if (a.isAsset && !b.isAsset) return -1;
                            if (!a.isAsset && b.isAsset) return 1;
                            
                            // Then sort alphabetically by name within each group
                            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
                          });
                          
                          return ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: sortedAccounts.length,
                            itemBuilder: (context, index) {
                              final account = sortedAccounts[index];
                    
                              // Show credit cards in card format
                              if (account.type == AccountType.creditCard) {
                                return _buildCreditCardAccountItem(context, account, currencyProvider);
                              }
                    
                              // Show regular accounts in normal format
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
                          );
                        },
                      ),
                    ),
                  ],
                ),
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Credit Card FAB
              FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddCreditCardScreen(),
                    ),
                  );
                },
                backgroundColor: Colors.orange[600],
                foregroundColor: Colors.white,
                heroTag: "credit_card_fab",
                child: const Icon(Icons.credit_card),
              ),
              const SizedBox(height: 16),
              // Regular Add Account FAB
              FloatingActionButton(
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
                heroTag: "add_account_fab",
                child: const Icon(Icons.add),
              ),
            ],
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

  Widget _buildCreditCardAccountItem(BuildContext context, Account account, CurrencyProvider currencyProvider) {
    // Get credit card details from CreditCardProvider
    return Consumer<CreditCardProvider>(
      builder: (context, creditCardProvider, child) {
        // Find the credit card associated with this account
        CreditCard? creditCard;
        try {
          creditCard = creditCardProvider.creditCards.firstWhere(
            (card) => card.accountId == account.id,
          );
        } catch (e) {
          creditCard = null;
        }
        
        if (creditCard == null) {
          // Fallback to basic account display if credit card not found
          return _buildBasicAccountItem(context, account, currencyProvider);
        }
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.lightBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: () {
              if (creditCard != null) {
                _navigateToCreditCardDetails(context, creditCard);
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.credit_card,
                          color: AppTheme.primaryBlue,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              creditCard.displayName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.lightText,
                              ),
                            ),
                            Text(
                              creditCard.bankName,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.lightText.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (creditCard.isPaymentDueSoon || creditCard.isOverdue)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: creditCard.isOverdue ? Colors.red : Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            creditCard.isOverdue ? 'Overdue' : 'Due Soon',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      // Delete button for credit card
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'delete' && creditCard != null) {
                            _confirmDeleteCreditCard(context, creditCard, account);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete Credit Card'),
                              ],
                            ),
                          ),
                        ],
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.more_vert,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildBalanceInfo(
                          'Balance',
                          creditCard.formattedCurrentBalance(currencyProvider.currencySymbol),
                          Colors.red,
                        ),
                      ),
                      Expanded(
                        child: _buildBalanceInfo(
                          'Available',
                          creditCard.formattedAvailableCredit(currencyProvider.currencySymbol),
                          Colors.green,
                        ),
                      ),
                      Expanded(
                        child: _buildBalanceInfo(
                          'Utilization',
                          creditCard.formattedCreditUtilization,
                          creditCard.creditUtilization > 30 ? Colors.orange : Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBasicAccountItem(BuildContext context, Account account, CurrencyProvider currencyProvider) {
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
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              currencyProvider.formatAmount(account.balance),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: account.balance >= 0 
                    ? Theme.of(context).colorScheme.primary
                    : Colors.red,
              ),
            ),
            Text(
              account.balance >= 0 ? 'Available' : 'Overdrawn',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        onTap: () {
          // Handle account tap
        },
      ),
    );
  }

  Widget _buildBalanceInfo(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.lightText.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  void _navigateToCreditCardDetails(BuildContext context, CreditCard creditCard) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreditCardDetailsScreen(creditCard: creditCard),
      ),
    );
  }

  void _confirmDeleteCreditCard(BuildContext context, CreditCard creditCard, Account account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Credit Card'),
        content: Text('Are you sure you want to delete "${creditCard.displayName}"? This will also delete the associated account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteCreditCard(context, creditCard, account);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCreditCard(BuildContext context, CreditCard creditCard, Account account) async {
    try {
      final creditCardProvider = Provider.of<CreditCardProvider>(context, listen: false);
      final transactionProvider = Provider.of<TransactionProviderHive>(context, listen: false);
      
      // Delete credit card
      await creditCardProvider.deleteCreditCard(creditCard.id);
      
      // Delete associated account
      await transactionProvider.deleteAccount(account.id);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Credit card deleted successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting credit card: $e')),
        );
      }
    }
  }
}
