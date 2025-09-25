import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../data/models/credit_card.dart';
import '../../../data/providers/credit_card_provider.dart';
import '../../../data/providers/transaction_provider_hive.dart';
import '../../../core/services/currency_service.dart';
import '../../widgets/transaction_form/widgets/compact_transaction_form.dart';
import 'credit_card_statement_screen.dart';

class CreditCardDetailsEnhancedScreen extends StatefulWidget {
  final CreditCard creditCard;

  const CreditCardDetailsEnhancedScreen({
    Key? key,
    required this.creditCard,
  }) : super(key: key);

  @override
  State<CreditCardDetailsEnhancedScreen> createState() => _CreditCardDetailsEnhancedScreenState();
}

class _CreditCardDetailsEnhancedScreenState extends State<CreditCardDetailsEnhancedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late CreditCard _creditCard;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _creditCard = widget.creditCard;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CreditCardProvider, TransactionProviderHive>(
      builder: (context, creditCardProvider, transactionProvider, child) {
        // Get the latest credit card data from the provider
        final currentCreditCard = creditCardProvider.getCreditCardById(_creditCard.id) ?? _creditCard;
        
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            title: Text(currentCreditCard.cardName),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            elevation: 0,
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _showEditCardDialog();
                      break;
                    case 'statement':
                      _generateStatement();
                      break;
                    case 'settings':
                      _showCardSettings();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Edit Card'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'statement',
                    child: Row(
                      children: [
                        Icon(Icons.description),
                        SizedBox(width: 8),
                        Text('Generate Statement'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings),
                        SizedBox(width: 8),
                        Text('Card Settings'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
                Tab(icon: Icon(Icons.receipt), text: 'Transactions'),
                Tab(icon: Icon(Icons.description), text: 'Statements'),
                Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
              ],
              labelColor: Theme.of(context).colorScheme.onPrimary,
              unselectedLabelColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
              indicatorColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(),
              _buildTransactionsTab(),
              _buildStatementsTab(),
              _buildAnalyticsTab(),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _addTransaction,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }


  Widget _buildOverviewTab() {
    return Consumer2<CreditCardProvider, TransactionProviderHive>(
      builder: (context, creditCardProvider, transactionProvider, child) {
        // Get the latest credit card data from the provider
        final currentCreditCard = creditCardProvider.getCreditCardById(_creditCard.id) ?? _creditCard;
        final availableCredit = creditCardProvider.getAvailableCreditForCard(_creditCard.id);
        final utilization = currentCreditCard.creditUtilization;
        final isHighUtilization = creditCardProvider.isCardUtilizationHigh(_creditCard.id);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardOverview(currentCreditCard, availableCredit, utilization, isHighUtilization),
              const SizedBox(height: 24),
              _buildQuickActions(),
              const SizedBox(height: 24),
              _buildRecentTransactions(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCardOverview(CreditCard creditCard, double availableCredit, double utilization, bool isHighUtilization) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    creditCard.cardName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '****${creditCard.lastFourDigits}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              Icon(
                _getCardTypeIcon('visa'), // Default to visa for now
                size: 40,
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildOverviewItem(
                'Credit Limit',
                CurrencyService.formatAmount(creditCard.creditLimit),
                Colors.white,
              ),
              _buildOverviewItem(
                'Available',
                CurrencyService.formatAmount(availableCredit),
                Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildOverviewItem(
                'Current Balance',
                CurrencyService.formatAmount(creditCard.currentBalance),
                Colors.white,
              ),
              _buildOverviewItem(
                'Utilization',
                '${utilization.toStringAsFixed(1)}%',
                isHighUtilization ? Colors.red[300]! : Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildUtilizationBar(utilization, isHighUtilization),
        ],
      ),
    );
  }

  Widget _buildOverviewItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildUtilizationBar(double utilization, bool isHighUtilization) {
    Color barColor;
    if (utilization <= 30) {
      barColor = Colors.green;
    } else if (utilization <= 70) {
      barColor = Colors.orange;
    } else {
      barColor = Colors.red;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: utilization / 100,
          backgroundColor: Colors.white.withOpacity(0.3),
          valueColor: AlwaysStoppedAnimation<Color>(barColor),
          minHeight: 8,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Safe Zone (0-30%)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            Text(
              'Warning (30-70%)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            Text(
              'Danger (70%+)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.payment,
                title: 'Make Payment',
                onTap: _makePayment,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.description,
                title: 'Generate Statement',
                onTap: _generateStatement,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.add,
                title: 'Add Transaction',
                onTap: _addTransaction,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.history,
                title: 'View History',
                onTap: _viewHistory,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    final transactionProvider = context.read<TransactionProviderHive>();
    final creditCardProvider = context.read<CreditCardProvider>();
    final currentCreditCard = creditCardProvider.getCreditCardById(_creditCard.id) ?? _creditCard;
    final transactions = transactionProvider.transactions
        .where((t) => t.accountId == currentCreditCard.accountId)
        .take(5)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => _tabController.animateTo(1),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return _buildTransactionItem(transaction);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(dynamic transaction) {
    final isExpense = transaction.type.toString().contains('expense');
    final isIncome = transaction.type.toString().contains('income');
    final amountColor = isExpense ? Colors.red : (isIncome ? Colors.green : Colors.blue);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: () => _editTransaction(transaction),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: amountColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                isExpense ? Icons.shopping_cart : (isIncome ? Icons.payment : Icons.swap_horiz),
                color: amountColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('MMM dd, yyyy').format(transaction.date),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${isExpense ? '-' : (isIncome ? '+' : '')}${CurrencyService.formatAmount(transaction.amount.abs())}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: amountColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _editTransaction(transaction);
                        break;
                      case 'delete':
                        _showDeleteConfirmation(transaction);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsTab() {
    return Consumer2<CreditCardProvider, TransactionProviderHive>(
      builder: (context, creditCardProvider, transactionProvider, child) {
        // Get the latest credit card data from the provider
        final currentCreditCard = creditCardProvider.getCreditCardById(_creditCard.id) ?? _creditCard;
        final transactions = transactionProvider.transactions
            .where((t) => t.accountId == currentCreditCard.accountId)
            .toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            final isExpense = transaction.type.toString().contains('expense');
            final isIncome = transaction.type.toString().contains('income');
            final amountColor = isExpense ? Colors.red : (isIncome ? Colors.green : Colors.blue);
            
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: amountColor.withOpacity(0.1),
                  child: Icon(
                    isExpense ? Icons.shopping_cart : (isIncome ? Icons.payment : Icons.swap_horiz),
                    color: amountColor,
                  ),
                ),
                title: Text(transaction.description),
                subtitle: Text(DateFormat('MMM dd, yyyy').format(transaction.date)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${isExpense ? '-' : (isIncome ? '+' : '')}${CurrencyService.formatAmount(transaction.amount.abs())}',
                      style: TextStyle(
                        color: amountColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            _editTransaction(transaction);
                            break;
                          case 'delete':
                            _showDeleteConfirmation(transaction);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                onTap: () => _editTransaction(transaction),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatementsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Statements Generated',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Generate your first statement to view it here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _generateStatement,
            icon: const Icon(Icons.add),
            label: const Text('Generate Statement'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Analytics Coming Soon',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Detailed spending analytics will be available here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCardTypeIcon(String cardType) {
    switch (cardType.toLowerCase()) {
      case 'visa':
        return Icons.credit_card;
      case 'mastercard':
        return Icons.credit_card;
      case 'amex':
        return Icons.credit_card;
      default:
        return Icons.credit_card;
    }
  }

  void _addTransaction() async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: CompactTransactionForm(),
        ),
      ),
    );
    
    // Refresh data if transaction was added
    if (result == true && mounted) {
      await context.read<CreditCardProvider>().refreshBalances();
      context.read<TransactionProviderHive>().refresh();
      setState(() {});
    }
  }

  void _editTransaction(dynamic transaction) async {
    // Get the original transaction from the provider
    final transactionProvider = context.read<TransactionProviderHive>();
    final originalTransaction = transactionProvider.getTransaction(transaction.id);
    
    if (originalTransaction == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show the edit form as a modal bottom sheet
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: CompactTransactionForm(
            transaction: originalTransaction,
          ),
        ),
      ),
    );
    
    // Refresh data if transaction was updated
    if (result == true && mounted) {
      await context.read<CreditCardProvider>().refreshBalances();
      context.read<TransactionProviderHive>().refresh();
      setState(() {});
    }
  }

  void _makePayment() {
    // Implementation for making payment
  }

  void _generateStatement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreditCardStatementScreen(creditCard: _creditCard),
      ),
    );
  }

  void _viewHistory() {
    _tabController.animateTo(1);
  }

  void _showEditCardDialog() {
    // Implementation for editing card
  }

  void _showCardSettings() {
    // Implementation for card settings
  }

  void _showDeleteConfirmation(dynamic transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text('Are you sure you want to delete "${transaction.description}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteTransaction(transaction);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteTransaction(dynamic transaction) async {
    try {
      final transactionProvider = context.read<TransactionProviderHive>();
      await transactionProvider.deleteTransaction(transaction.id);
      
      // Refresh data after deletion
      await context.read<CreditCardProvider>().refreshBalances();
      context.read<TransactionProviderHive>().refresh();
      setState(() {});
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting transaction: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
