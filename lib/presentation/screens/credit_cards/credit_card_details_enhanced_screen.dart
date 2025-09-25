import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import '../../../data/models/credit_card.dart';
import '../../../data/models/credit_card_statement.dart';
import '../../../data/models/transaction.dart';
import '../../../data/providers/credit_card_provider.dart';
import '../../../data/providers/transaction_provider_hive.dart';
import '../../../data/providers/statement_provider.dart';
import '../../../data/providers/currency_provider.dart';
import '../../../core/services/currency_service.dart';
import '../../../core/services/pdf_statement_service.dart';
import '../../widgets/transaction_form/widgets/compact_transaction_form.dart';
import 'credit_card_statement_screen.dart';
import 'statement_generation_screen.dart';
import 'credit_card_payment_screen.dart';

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
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TabController _statementsTabController;
  late CreditCard _creditCard;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _statementsTabController = TabController(length: 2, vsync: this);
    _creditCard = widget.creditCard;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _statementsTabController.dispose();
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
    return Consumer<StatementProvider>(
      builder: (context, statementProvider, child) {
        final statements = statementProvider.getStatementsForCard(_creditCard.id);
        
        // Always separate statements by status, even if empty
        final currentStatements = statements.where((s) => s.status != StatementStatus.paid).toList();
        final paidStatements = statements.where((s) => s.status == StatementStatus.paid).toList();
        
        return Column(
          children: [
            // Header with generate button
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Statements (${statements.length})',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _generateStatement,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Generate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            // Tab bar for statement categories - ALWAYS show both tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _statementsTabController,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.schedule, size: 18),
                        const SizedBox(width: 8),
                        Text('Current/Past (${currentStatements.length})'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle, size: 18),
                        const SizedBox(width: 8),
                        Text('Paid (${paidStatements.length})'),
                      ],
                    ),
                  ),
                ],
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                indicator: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                dividerColor: Colors.transparent,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Tab content - ALWAYS show both tabs
            Expanded(
              child: TabBarView(
                controller: _statementsTabController,
                physics: const NeverScrollableScrollPhysics(), // Disable swipe
                children: [
                  // Current/Past statements
                  _buildStatementsList(currentStatements, isCurrentTab: true),
                  // Paid statements
                  _buildStatementsList(paidStatements, isCurrentTab: false),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatementsList(List<CreditCardStatement> statements, {required bool isCurrentTab}) {
    if (statements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCurrentTab ? Icons.schedule_outlined : Icons.check_circle_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              isCurrentTab ? 'No Current/Past Statements' : 'No Paid Statements',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isCurrentTab 
                ? 'Generated statements will appear here until paid'
                : 'Paid statements will be moved here automatically',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
            if (isCurrentTab) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _generateStatement,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Generate Statement'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: statements.length,
      itemBuilder: (context, index) {
        final statement = statements[index];
        return _buildStatementItem(statement);
      },
    );
  }

  Widget _buildStatementItem(CreditCardStatement statement) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with period and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    statement.statementPeriod,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatementStatusColor(statement.status),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    statement.statusText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Statement details in a grid
            Row(
              children: [
                Expanded(
                  child: _buildStatementDetailItem(
                    'Statement Date',
                    '${statement.statementDate.day}/${statement.statementDate.month}/${statement.statementDate.year}',
                    Icons.calendar_today,
                  ),
                ),
                Expanded(
                  child: _buildStatementDetailItem(
                    'Due Date',
                    '${statement.dueDate.day}/${statement.dueDate.month}/${statement.dueDate.year}',
                    Icons.schedule,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatementDetailItem(
                    'Previous Balance',
                    CurrencyService.formatAmount(statement.previousBalance),
                    Icons.account_balance_wallet,
                  ),
                ),
                Expanded(
                  child: _buildStatementDetailItem(
                    'New Purchases',
                    CurrencyService.formatAmount(statement.totalPurchases),
                    Icons.shopping_cart,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatementDetailItem(
                    'Payments',
                    CurrencyService.formatAmount(statement.totalPayments),
                    Icons.payment,
                  ),
                ),
                Expanded(
                  child: _buildStatementDetailItem(
                    'New Balance',
                    CurrencyService.formatAmount(statement.newBalance),
                    Icons.account_balance,
                    isHighlight: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatementDetailItem(
                    'Minimum Payment',
                    CurrencyService.formatAmount(statement.minimumPayment),
                    Icons.credit_card,
                    isHighlight: statement.status != StatementStatus.paid,
                  ),
                ),
                Expanded(
                  child: _buildStatementDetailItem(
                    'Available Credit',
                    CurrencyService.formatAmount(statement.availableCredit),
                    Icons.credit_score,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                // PDF Export Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _exportStatementToPDF(statement),
                    icon: const Icon(Icons.picture_as_pdf, size: 18),
                    label: const Text('PDF'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                
                // Delete Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _deleteStatement(statement),
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                
                // Pay Button
                if (statement.status != StatementStatus.paid)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _makePaymentForStatement(statement),
                      icon: const Icon(Icons.payment, size: 18),
                      label: const Text('Pay Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.check_circle, size: 18),
                      label: const Text('Paid'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: const BorderSide(color: Colors.green),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatementDetailItem(String label, String value, IconData icon, {bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isHighlight 
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: isHighlight 
            ? Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: isHighlight 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isHighlight 
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getStatementStatusColor(StatementStatus status) {
    switch (status) {
      case StatementStatus.generated:
        return Colors.blue;
      case StatementStatus.paid:
        return Colors.green;
      case StatementStatus.overdue:
        return Colors.red;
    }
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreditCardPaymentScreen(creditCard: _creditCard),
      ),
    ).then((paymentSuccessful) {
      if (paymentSuccessful == true) {
        // Refresh data after successful payment
        context.read<CreditCardProvider>().refreshBalances();
        context.read<TransactionProviderHive>().refresh();
      }
    });
  }

  void _generateStatement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatementGenerationScreen(creditCard: _creditCard),
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

  Future<void> _exportStatementToPDF(CreditCardStatement statement) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Get required providers
      final transactionProvider = context.read<TransactionProviderHive>();
      final currencyProvider = context.read<CurrencyProvider>();
      
      // Get transactions for this statement
      final transactions = statement.transactionIds
          .map((id) => transactionProvider.getTransaction(id))
          .where((transaction) => transaction != null)
          .cast<Transaction>()
          .toList();

      // Generate PDF
      final pdfBytes = await PDFStatementService.generateStatementPDF(
        statement: statement,
        creditCard: _creditCard,
        transactions: transactions,
        currencyProvider: currencyProvider,
      );

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show export options
      _showExportOptions(pdfBytes, statement);

    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showExportOptions(Uint8List pdfBytes, CreditCardStatement statement) {
    final fileName = 'Statement_${_creditCard.cardName}_${statement.statementPeriod.replaceAll(' ', '_')}';
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Export Statement',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.blue),
              title: const Text('Share PDF'),
              subtitle: const Text('Share via email, messaging apps'),
              onTap: () async {
                Navigator.pop(context);
                await PDFStatementService.sharePDF(pdfBytes, fileName);
              },
            ),
            ListTile(
              leading: const Icon(Icons.print, color: Colors.green),
              title: const Text('Print PDF'),
              subtitle: const Text('Print directly to printer'),
              onTap: () async {
                Navigator.pop(context);
                await PDFStatementService.printPDF(pdfBytes, fileName);
              },
            ),
            ListTile(
              leading: const Icon(Icons.save, color: Colors.orange),
              title: const Text('Save to Device'),
              subtitle: const Text('Save PDF to device storage'),
              onTap: () async {
                Navigator.pop(context);
                final filePath = await PDFStatementService.savePDFToDevice(pdfBytes, fileName);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('PDF saved to: $filePath'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteStatement(CreditCardStatement statement) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Statement'),
        content: Text(
          'Are you sure you want to delete the statement for ${statement.statementPeriod}?\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await context.read<StatementProvider>().deleteStatement(statement.id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Statement deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting statement: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _makePaymentForStatement(CreditCardStatement statement) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreditCardPaymentScreen(
          creditCard: _creditCard,
          statement: statement,
        ),
      ),
    ).then((paymentSuccessful) {
      if (paymentSuccessful == true) {
        // Refresh statements after successful payment
        context.read<StatementProvider>().loadStatementsForCard(_creditCard.id);
      }
    });
  }
}
