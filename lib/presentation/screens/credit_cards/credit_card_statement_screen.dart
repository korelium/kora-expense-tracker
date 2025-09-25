import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../data/models/credit_card.dart';
import '../../../data/providers/credit_card_provider.dart';
import '../../../data/providers/transaction_provider_hive.dart';
import '../../../core/services/currency_service.dart';

class CreditCardStatementScreen extends StatelessWidget {
  final CreditCard creditCard;

  const CreditCardStatementScreen({
    Key? key,
    required this.creditCard,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Card Statement'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareStatement(context),
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _printStatement(context),
          ),
        ],
      ),
      body: Consumer2<CreditCardProvider, TransactionProviderHive>(
        builder: (context, creditCardProvider, transactionProvider, child) {
          final availableCredit = creditCardProvider.getAvailableCreditForCard(creditCard.id);
        final utilization = creditCard.creditUtilization;
        final transactions = transactionProvider.transactions
            .where((t) => t.accountId == creditCard.accountId)
            .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildCardInfo(context),
                const SizedBox(height: 24),
                _buildSummary(context, availableCredit, utilization),
                const SizedBox(height: 24),
                _buildTransactionDetails(context, transactions),
                const SizedBox(height: 24),
                _buildPaymentInfo(context, availableCredit, utilization),
                const SizedBox(height: 24),
                _buildUtilizationChart(context, utilization),
                const SizedBox(height: 24),
                _buildBillCycleSummary(context, transactions),
                const SizedBox(height: 24),
                _buildFooter(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'KORA EXPENSE TRACKER',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'CREDIT CARD STATEMENT',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardInfo(BuildContext context) {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1, 1);
    final lastDayOfMonth = DateTime(now.year, now.month, 0);
    final dueDate = DateTime(now.year, now.month, 15);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CARD INFO',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '• Card Name: ${creditCard.cardName}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '• Last 4: ****${creditCard.lastFourDigits}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '• Credit Limit: ${CurrencyService.formatAmount(creditCard.creditLimit)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STATEMENT PERIOD',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '• Period: ${DateFormat('MMM dd').format(lastMonth)} - ${DateFormat('dd, yyyy').format(lastDayOfMonth)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '• Due Date: ${DateFormat('MMM dd, yyyy').format(dueDate)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '• Statement Date: ${DateFormat('MMM dd, yyyy').format(now)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context, double availableCredit, double utilization) {
    final previousBalance = 0.0; // This would come from previous statement
    final newCharges = creditCard.currentBalance;
    final paymentsMade = 0.0; // This would come from payment transactions
    final totalDue = newCharges - paymentsMade;
    final minimumPayment = totalDue * 0.05; // 5% minimum payment

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SUMMARY',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Previous Balance', CurrencyService.formatAmount(previousBalance)),
          _buildSummaryRow('New Charges', CurrencyService.formatAmount(newCharges)),
          _buildSummaryRow('Payments Made', CurrencyService.formatAmount(paymentsMade)),
          _buildSummaryRow('Total Due', CurrencyService.formatAmount(totalDue)),
          _buildSummaryRow('Minimum Payment', CurrencyService.formatAmount(minimumPayment)),
          _buildSummaryRow('Available Credit', CurrencyService.formatAmount(availableCredit)),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetails(BuildContext context, List<dynamic> transactions) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TRANSACTION DETAILS',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (transactions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No transactions found',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            )
          else
            Table(
              border: TableBorder.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  ),
                  children: [
                    _buildTableCell('Date', isHeader: true),
                    _buildTableCell('Description', isHeader: true),
                    _buildTableCell('Amount', isHeader: true),
                    _buildTableCell('Balance', isHeader: true),
                  ],
                ),
                ...transactions.map((transaction) {
                  final isExpense = transaction.type.toString().contains('expense');
                  final isIncome = transaction.type.toString().contains('income');
                  final amountText = '${isExpense ? '-' : (isIncome ? '+' : '')}${CurrencyService.formatAmount(transaction.amount.abs())}';
                  
                  return TableRow(
                    children: [
                      _buildTableCell(DateFormat('MM/dd/yyyy').format(transaction.date)),
                      _buildTableCell(transaction.description),
                      _buildTableCell(amountText),
                      _buildTableCell(CurrencyService.formatAmount(transaction.amount)),
                    ],
                  );
                }).toList(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildPaymentInfo(BuildContext context, double availableCredit, double utilization) {
    final now = DateTime.now();
    final dueDate = DateTime(now.year, now.month, 15);
    final totalDue = creditCard.currentBalance;
    final minimumPayment = totalDue * 0.05;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PAYMENT INFORMATION',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildPaymentRow('Payment Due Date', DateFormat('MMMM dd, yyyy').format(dueDate)),
          _buildPaymentRow('Minimum Payment', CurrencyService.formatAmount(minimumPayment)),
          _buildPaymentRow('Total Amount Due', CurrencyService.formatAmount(totalDue)),
          _buildPaymentRow('Available Credit', CurrencyService.formatAmount(availableCredit)),
          _buildPaymentRow('Credit Utilization', '${utilization.toStringAsFixed(2)}%'),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text('• $label: $value'),
    );
  }

  Widget _buildUtilizationChart(BuildContext context, double utilization) {
    Color barColor;
    if (utilization <= 30) {
      barColor = Colors.green;
    } else if (utilization <= 70) {
      barColor = Colors.orange;
    } else {
      barColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'UTILIZATION CHART',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: utilization / 100,
            backgroundColor: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
            minHeight: 20,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0%'),
              Text('50%'),
              Text('100%'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Safe Zone',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
              Text(
                'Warning Zone',
                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
              ),
              Text(
                'Danger Zone',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillCycleSummary(BuildContext context, List<dynamic> transactions) {
    final totalTransactions = transactions.length;
    final averageTransaction = totalTransactions > 0 
        ? transactions.map((t) => t.amount.abs()).reduce((a, b) => a + b) / totalTransactions 
        : 0.0;
    final largestTransaction = totalTransactions > 0 
        ? transactions.map((t) => t.amount.abs()).reduce((a, b) => a > b ? a : b) 
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BILL CYCLE SUMMARY',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Statement Period', '${DateFormat('MMMM').format(DateTime.now())} 1-31, ${DateTime.now().year}'),
          _buildSummaryRow('Total Transactions', totalTransactions.toString()),
          _buildSummaryRow('Average Transaction', CurrencyService.formatAmount(averageTransaction)),
          _buildSummaryRow('Largest Transaction', CurrencyService.formatAmount(largestTransaction)),
          _buildSummaryRow('Payment Status', 'On Time'),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Thank you for using Kora Expense Tracker',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Generated on ${DateFormat('MMMM dd, yyyy').format(DateTime.now())}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _shareStatement(BuildContext context) {
    // Implementation for sharing statement
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon')),
    );
  }

  void _printStatement(BuildContext context) {
    // Implementation for printing statement
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Print functionality coming soon')),
    );
  }
}
