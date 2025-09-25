// File location: lib/presentation/screens/credit_cards/statement_generation_screen.dart
// Purpose: Screen for generating credit card statements
// Author: Pown Kumar - Founder of Korelium
// Date: September 23, 2025

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/credit_card.dart';
import '../../../data/models/credit_card_statement.dart';
import '../../../data/models/transaction.dart';
import '../../../data/providers/statement_provider.dart';
import '../../../data/providers/transaction_provider_hive.dart';
import '../../../data/providers/currency_provider.dart';
import '../../../core/services/currency_service.dart';
import '../../../core/services/pdf_statement_service.dart';
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
      margin: const EdgeInsets.only(bottom: 8),
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
                    color: _getStatusColor(statement.status),
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
                  child: _buildDetailItem(
                    'Statement Date',
                    '${statement.statementDate.day}/${statement.statementDate.month}/${statement.statementDate.year}',
                    Icons.calendar_today,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
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
                  child: _buildDetailItem(
                    'Previous Balance',
                    CurrencyService.formatAmount(statement.previousBalance),
                    Icons.account_balance_wallet,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
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
                  child: _buildDetailItem(
                    'Payments',
                    CurrencyService.formatAmount(statement.totalPayments),
                    Icons.payment,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
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
                  child: _buildDetailItem(
                    'Minimum Payment',
                    CurrencyService.formatAmount(statement.minimumPayment),
                    Icons.credit_card,
                    isHighlight: statement.status != StatementStatus.paid,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // PDF Export Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _exportToPDF(statement),
                    icon: const Icon(Icons.picture_as_pdf, size: 18),
                    label: const Text('PDF'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
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
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                
                // Pay Button
                if (statement.status != StatementStatus.paid)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _makePayment(statement),
                      icon: const Icon(Icons.payment, size: 18),
                      label: const Text('Pay Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
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

  Widget _buildDetailItem(String label, String value, IconData icon, {bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isHighlight 
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: isHighlight 
            ? Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3))
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
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
      // Check if statement already exists
      final existingStatements = statementProvider.getStatementsForCard(widget.creditCard.id);
      CreditCardStatement? existingStatement;
      try {
        existingStatement = existingStatements.firstWhere(
          (s) => s.statementDate.year == _selectedYear && s.statementDate.month == _selectedMonth,
        );
      } catch (e) {
        existingStatement = null;
      }

      if (existingStatement != null) {
        if (mounted) {
          // Show option to regenerate or view existing
          final choice = await showDialog<String>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Statement Already Exists'),
              content: Text(
                'A statement for ${_getMonthName(_selectedMonth)} $_selectedYear already exists.\n\n'
                'What would you like to do?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, 'view'),
                  child: const Text('View Existing'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, 'regenerate'),
                  child: const Text('Regenerate'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, 'cancel'),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          );

          if (choice == 'regenerate') {
            // Delete existing statement and generate new one
            await statementProvider.deleteStatement(existingStatement.id);
            final newStatement = await statementProvider.generateStatement(
              creditCardId: widget.creditCard.id,
              year: _selectedYear,
              month: _selectedMonth,
            );

            if (mounted && newStatement != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Statement regenerated for ${_getMonthName(_selectedMonth)} $_selectedYear'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else if (choice == 'view') {
            // Scroll to existing statement (already visible in list)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Existing statement is shown in the list above'),
                backgroundColor: Colors.blue,
              ),
            );
          }
        }
      } else {
        // Generate new statement
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
                content: Text('Failed to generate statement'),
                backgroundColor: Colors.red,
              ),
            );
          }
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

  Future<void> _exportToPDF(CreditCardStatement statement) async {
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
        creditCard: widget.creditCard,
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
    final fileName = 'Statement_${widget.creditCard.cardName}_${statement.statementPeriod.replaceAll(' ', '_')}';
    
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
}
