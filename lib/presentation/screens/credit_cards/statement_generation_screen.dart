// File location: lib/presentation/screens/credit_cards/statement_generation_screen.dart
// Purpose: Screen for generating credit card statements
// Author: Pown Kumar - Founder of Korelium
// Date: September 23, 2025

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/credit_card.dart';
import '../../../data/models/credit_card_statement.dart';
import '../../../data/providers/statement_provider.dart';
import '../../../core/services/currency_service.dart';
import 'credit_card_payment_screen.dart';

/// Screen for generating credit card statements
/// Allows users to generate statements for specific months
class StatementGenerationScreen extends StatefulWidget {
  final CreditCard creditCard;

  const StatementGenerationScreen({
    super.key,
    required this.creditCard,
  });

  @override
  State<StatementGenerationScreen> createState() => _StatementGenerationScreenState();
}

class _StatementGenerationScreenState extends State<StatementGenerationScreen> {
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    // Initialize statement provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatementProvider>().loadStatementsForCard(widget.creditCard.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generate Statement - ${widget.creditCard.cardName}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<StatementProvider>(
        builder: (context, statementProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCardInfo(),
                const SizedBox(height: 24),
                _buildStatementHistory(statementProvider),
                const SizedBox(height: 24),
                _buildGenerateSection(statementProvider),
                const SizedBox(height: 24),
                _buildBillingCycleInfo(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Card Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Card: ${widget.creditCard.cardName}'),
                Text('****${widget.creditCard.lastFourDigits}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Credit Limit: ${CurrencyService.formatAmount(widget.creditCard.creditLimit)}'),
                Text('Available: ${CurrencyService.formatAmount(widget.creditCard.availableCredit)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Current Balance: ${CurrencyService.formatAmount(widget.creditCard.currentBalance)}'),
                Text('Utilization: ${widget.creditCard.creditUtilization.toStringAsFixed(1)}%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatementHistory(StatementProvider statementProvider) {
    final statements = statementProvider.getStatementsForCard(widget.creditCard.id);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statement History',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (statements.isEmpty)
              const Text('No statements generated yet')
            else
              ...statements.take(5).map((statement) => _buildStatementItem(statement)),
            if (statements.length > 5)
              TextButton(
                onPressed: () {
                  // TODO: Navigate to full statement history
                },
                child: const Text('View All Statements'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatementItem(CreditCardStatement statement) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statement.statementPeriod,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Due: ${statement.formattedDueDate}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    CurrencyService.formatAmount(statement.newBalance),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(statement.status),
                    borderRadius: BorderRadius.circular(12),
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
                const SizedBox(height: 8),
                if (statement.status != StatementStatus.paid)
                  ElevatedButton(
                    onPressed: () => _makePayment(statement),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    child: const Text('Pay'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(StatementStatus status) {
    switch (status) {
      case StatementStatus.generated:
        return Colors.blue;
      case StatementStatus.paid:
        return Colors.green;
      case StatementStatus.overdue:
        return Colors.red;
    }
  }

  Widget _buildGenerateSection(StatementProvider statementProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Generate New Statement',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedYear,
                    decoration: const InputDecoration(
                      labelText: 'Year',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(5, (index) {
                      final year = DateTime.now().year - index;
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        _selectedYear = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedMonth,
                    decoration: const InputDecoration(
                      labelText: 'Month',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(12, (index) {
                      final month = index + 1;
                      return DropdownMenuItem(
                        value: month,
                        child: Text(_getMonthName(month)),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        _selectedMonth = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isGenerating ? null : () => _generateStatement(statementProvider),
                child: _isGenerating
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Generating...'),
                        ],
                      )
                    : const Text('Generate Statement'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingCycleInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Billing Cycle Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Statement Generation Day', '${widget.creditCard.statementGenerationDay}'),
            _buildInfoRow('Grace Period', '${widget.creditCard.gracePeriodDays} days'),
            _buildInfoRow('Minimum Payment Type', 
              widget.creditCard.minimumPaymentFixedAmount != null 
                ? 'Fixed: ${CurrencyService.formatAmount(widget.creditCard.minimumPaymentFixedAmount!)}'
                : 'Percentage: ${widget.creditCard.minimumPaymentPercentage}%'),
            _buildInfoRow('Next Statement Date', _getNextStatementDate()),
            _buildInfoRow('Next Due Date', _getNextDueDate()),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  String _getNextStatementDate() {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final nextMonth = DateTime(now.year, now.month + 1);
    
    DateTime statementDate;
    if (widget.creditCard.statementGenerationDay <= now.day) {
      statementDate = DateTime(nextMonth.year, nextMonth.month, widget.creditCard.statementGenerationDay);
    } else {
      statementDate = DateTime(currentMonth.year, currentMonth.month, widget.creditCard.statementGenerationDay);
    }
    
    return '${statementDate.day} ${_getMonthName(statementDate.month)} ${statementDate.year}';
  }

  String _getNextDueDate() {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final nextMonth = DateTime(now.year, now.month + 1);
    
    DateTime statementDate;
    if (widget.creditCard.statementGenerationDay <= now.day) {
      statementDate = DateTime(nextMonth.year, nextMonth.month, widget.creditCard.statementGenerationDay);
    } else {
      statementDate = DateTime(currentMonth.year, currentMonth.month, widget.creditCard.statementGenerationDay);
    }
    
    final dueDate = statementDate.add(Duration(days: widget.creditCard.gracePeriodDays));
    return '${dueDate.day} ${_getMonthName(dueDate.month)} ${dueDate.year}';
  }

  void _makePayment(CreditCardStatement statement) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreditCardPaymentScreen(
          creditCard: widget.creditCard,
          statement: statement,
        ),
      ),
    ).then((paymentSuccessful) {
      if (paymentSuccessful == true) {
        // Refresh statements after successful payment
        context.read<StatementProvider>().loadStatementsForCard(widget.creditCard.id);
      }
    });
  }

  Future<void> _generateStatement(StatementProvider statementProvider) async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final statement = await statementProvider.generateStatement(
        creditCardId: widget.creditCard.id,
        year: _selectedYear,
        month: _selectedMonth,
      );

      if (mounted) {
        if (statement != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Statement generated successfully for ${_getMonthName(_selectedMonth)} $_selectedYear'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Statement already exists for this period'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating statement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }
}
