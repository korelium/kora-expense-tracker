// File location: lib/presentation/screens/credit_cards/credit_card_details_screen.dart
// Purpose: Detailed view of a specific credit card
// Author: Pown Kumar - Founder of Korelium
// Date: September 23, 2025

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/credit_card_provider.dart';
import '../../../data/providers/currency_provider.dart';
import '../../../data/providers/transaction_provider_hive.dart';
import '../../../data/providers/bill_provider.dart';
import '../../../data/models/credit_card.dart';
import '../../../data/models/credit_card_transaction.dart';
import '../../../data/models/transaction.dart';
import '../../../core/theme/app_theme.dart';
import '../../screens/transactions/add_transaction_screen.dart';

/// Detailed view of a specific credit card
/// Shows transactions, payment history, and credit card details
class CreditCardDetailsScreen extends StatefulWidget {
  final CreditCard creditCard;

  const CreditCardDetailsScreen({
    super.key,
    required this.creditCard,
  });

  @override
  State<CreditCardDetailsScreen> createState() => _CreditCardDetailsScreenState();
}

class _CreditCardDetailsScreenState extends State<CreditCardDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CreditCardProvider>().initialize();
      context.read<CreditCardProvider>().refresh();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          widget.creditCard.displayName,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => _showEditDialog(context),
            tooltip: 'Edit Credit Card',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
          labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Transactions'),
            Tab(text: 'Analytics'),
          ],
        ),
      ),
      body: Consumer3<CreditCardProvider, CurrencyProvider, TransactionProviderHive>(
        builder: (context, creditCardProvider, currencyProvider, transactionProvider, child) {
          if (creditCardProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryBlue,
              ),
            );
          }

          // Get fresh transactions from the database directly
          return FutureBuilder<List<CreditCardTransaction>>(
            future: creditCardProvider.getFreshCreditCardTransactions(widget.creditCard.id),
            key: ValueKey('${widget.creditCard.id}_${transactionProvider.transactions.length}'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryBlue,
                  ),
                );
              }
              
              final transactions = snapshot.data ?? [];

              return TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(transactions, currencyProvider),
                  _buildTransactionsTab(transactions),
                  _buildAnalyticsTab(transactions, currencyProvider),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTransaction(context),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        tooltip: 'Add Transaction',
      ),
    );
  }

  Widget _buildCreditCardHeader(CurrencyProvider currencyProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.primaryBlue.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.credit_card,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.creditCard.displayName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (widget.creditCard.isPaymentDueSoon || widget.creditCard.isOverdue)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.creditCard.isOverdue ? Colors.red : Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.creditCard.isOverdue ? 'Overdue' : 'Due Soon',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            widget.creditCard.bankName,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildCompactBalanceCard(
                  'Current Balance',
                  widget.creditCard.formattedCurrentBalance(currencyProvider.currencySymbol),
                  Colors.red[100]!,
                  Colors.red[800]!,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCompactBalanceCard(
                  'Available Credit',
                  widget.creditCard.formattedAvailableCredit(currencyProvider.currencySymbol),
                  Colors.green[100]!,
                  Colors.green[800]!,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(String title, String amount, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: textColor.withValues(alpha: 0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactBalanceCard(String title, String amount, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: textColor.withValues(alpha: 0.8),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyInfo(CurrencyProvider currencyProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildKeyInfoItem('Limit', widget.creditCard.formattedCreditLimit(currencyProvider.currencySymbol)),
          ),
          Container(
            width: 1,
            height: 20,
            color: Theme.of(context).colorScheme.outline,
          ),
          Expanded(
            child: _buildKeyInfoItem('Rate', '${widget.creditCard.interestRate.toStringAsFixed(2)}%'),
          ),
          Container(
            width: 1,
            height: 20,
            color: Theme.of(context).colorScheme.outline,
          ),
          Expanded(
            child: _buildKeyInfoItem('Due', '${widget.creditCard.dueDay}'),
          ),
          Container(
            width: 1,
            height: 20,
            color: Theme.of(context).colorScheme.outline,
          ),
          Expanded(
            child: _buildKeyInfoItem('Utilization', widget.creditCard.formattedCreditUtilization),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.payment,
                  label: 'Make Payment',
                  color: Colors.green,
                  onTap: () => _showPaymentDialog(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.add,
                  label: 'Add Transaction',
                  color: AppTheme.primaryBlue,
                  onTap: () => _showAddTransactionDialog(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.receipt_long,
                  label: 'Generate Bill',
                  color: Colors.orange,
                  onTap: () => _generateBill(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.history,
                  label: 'View Bills',
                  color: Colors.purple,
                  onTap: () => _viewBills(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList(List transactions) {
    if (transactions.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long,
              size: 32,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'No Transactions Yet',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Add your first transaction to start tracking',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Text(
                  'Recent Transactions',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Text(
                  '${transactions.length}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          ...transactions.take(5).map((transaction) => 
            _buildTransactionItem(transaction)
          ),
          if (transactions.length > 5)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Center(
                child: Text(
                  'View All Transactions',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(transaction) {
    return InkWell(
      onTap: () => _editTransaction(context, transaction),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: transaction.isPurchase 
                    ? Colors.red.withValues(alpha: 0.1)
                    : Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                transaction.isPurchase ? Icons.shopping_cart : Icons.payment,
                size: 14,
                color: transaction.isPurchase ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(transaction.transactionDate),
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              transaction.formattedAmount,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: transaction.isPayment ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _editTransaction(context, transaction),
              icon: const Icon(Icons.edit, size: 16),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Edit Transaction',
            ),
          ],
        ),
      ),
    );
  }

  // Tab Methods
  Widget _buildOverviewTab(List transactions, CurrencyProvider currencyProvider) {
    return RefreshIndicator(
      onRefresh: () => context.read<CreditCardProvider>().refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildCreditCardHeader(currencyProvider),
            _buildKeyInfo(currencyProvider),
            // _buildQuickActions(), // Hidden for now - using transfer functionality instead
            _buildRecentTransactionsPreview(transactions),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsTab(List transactions) {
    return RefreshIndicator(
      onRefresh: () => context.read<CreditCardProvider>().refresh(),
      child: _buildTransactionsList(transactions),
    );
  }

  Widget _buildAnalyticsTab(List transactions, CurrencyProvider currencyProvider) {
    return RefreshIndicator(
      onRefresh: () => context.read<CreditCardProvider>().refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildAnalyticsOverview(currencyProvider),
            _buildSpendingByCategory(transactions),
            _buildMonthlyTrends(transactions),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactionsPreview(List transactions) {
    if (transactions.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long,
              size: 32,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'No Recent Transactions',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Text(
                  'Recent Transactions',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _tabController.animateTo(1),
                  child: Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...transactions.take(3).map((transaction) => 
            _buildTransactionItem(transaction)
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsOverview(CurrencyProvider currencyProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending Overview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildAnalyticsCard(
                  'This Month',
                  '${currencyProvider.currencySymbol}${widget.creditCard.currentBalance.abs().toStringAsFixed(2)}',
                  Icons.trending_up,
                  Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnalyticsCard(
                  'Avg Daily',
                  '${currencyProvider.currencySymbol}${(widget.creditCard.currentBalance.abs() / 30).toStringAsFixed(2)}',
                  Icons.calendar_today,
                  Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingByCategory(List transactions) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending by Category',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          if (transactions.isEmpty)
            Center(
              child: Text(
                'No spending data available',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                ),
              ),
            )
          else
            Center(
              child: Text(
                'Category breakdown coming soon!',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMonthlyTrends(List transactions) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Trends',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          if (transactions.isEmpty)
            Center(
              child: Text(
                'No trend data available',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                ),
              ),
            )
          else
            Center(
              child: Text(
                'Trend charts coming soon!',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '${difference} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  /// Add new transaction for this credit card
  Future<void> _addTransaction(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(
          initialType: TransactionType.expense, // Default to expense for credit cards
        ),
      ),
    );
    
    if (result == true) {
      // Refresh both credit card and transaction data
      if (mounted) {
        context.read<CreditCardProvider>().refresh();
        context.read<TransactionProviderHive>().refresh();
        setState(() {});
      }
    }
  }

  /// Edit existing transaction
  Future<void> _editTransaction(BuildContext context, transaction) async {
    // Convert CreditCardTransaction to Transaction for editing
    final transactionProvider = context.read<TransactionProviderHive>();
    final originalTransaction = transactionProvider.getTransaction(transaction.transactionId);
    
    if (originalTransaction == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(
          transaction: originalTransaction,
        ),
      ),
    );
    
    if (result == true) {
      // Refresh both credit card and transaction data
      if (mounted) {
        context.read<CreditCardProvider>().refresh();
        context.read<TransactionProviderHive>().refresh();
        setState(() {});
      }
    }
  }

  void _showEditDialog(BuildContext context) {
    // TODO: Implement edit dialog - Planned for Phase 4 (Deep Refactoring)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit functionality coming soon!'),
      ),
    );
  }

  /// Generate bill for this credit card
  Future<void> _generateBill() async {
    try {
      final billProvider = context.read<BillProvider>();
      final creditCardProvider = context.read<CreditCardProvider>();
      
      // Get transactions for this credit card
      final transactions = creditCardProvider.getCreditCardTransactions(widget.creditCard.id);
      
      // Generate bill for last 30 days
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 30));
      
      final bill = await billProvider.generateBill(
        creditCardId: widget.creditCard.id,
        creditCard: widget.creditCard,
        transactions: transactions,
        statementPeriodStart: startDate,
        statementPeriodEnd: endDate,
        notes: 'Monthly statement for ${widget.creditCard.displayName}',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bill generated successfully! Due: ${bill.formattedDueDate}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate bill: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// View bills for this credit card
  void _viewBills() {
    // TODO: Navigate to bills screen - Planned for Phase 5 (Credit Card Bill Cycles)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bills screen coming soon!'),
      ),
    );
  }

  void _showPaymentDialog() {
    // TODO: Implement payment dialog - Planned for Phase 5 (Credit Card Bill Cycles)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment functionality coming soon!'),
      ),
    );
  }

  void _showAddTransactionDialog() {
    // TODO: Implement add transaction dialog - Planned for Phase 4 (Deep Refactoring)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add transaction functionality coming soon!'),
      ),
    );
  }
}
