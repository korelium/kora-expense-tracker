// File location: lib/presentation/screens/credit_cards/credit_card_payment_screen.dart
// Purpose: Screen for making credit card payments via bank transfer
// Author: Pown Kumar - Founder of Korelium
// Date: September 23, 2025

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/credit_card.dart';
import '../../../data/models/credit_card_statement.dart';
import '../../../data/models/account.dart';
import '../../../data/providers/statement_provider.dart';
import '../../../data/providers/transaction_provider_hive.dart';
import '../../../core/services/currency_service.dart';

/// Screen for making credit card payments
/// Integrates with existing transfer system for bank transfers
class CreditCardPaymentScreen extends StatefulWidget {
  final CreditCard creditCard;
  final CreditCardStatement? statement;

  const CreditCardPaymentScreen({
    super.key,
    required this.creditCard,
    this.statement,
  });

  @override
  State<CreditCardPaymentScreen> createState() => _CreditCardPaymentScreenState();
}

class _CreditCardPaymentScreenState extends State<CreditCardPaymentScreen> {
  Account? _selectedFromAccount;
  double _paymentAmount = 0.0;
  String _description = '';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _paymentAmount = widget.statement?.newBalance ?? widget.creditCard.currentBalance;
    _description = 'Payment for ${widget.creditCard.cardName} - ${widget.statement?.statementPeriod ?? 'Current Balance'}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Make Payment - ${widget.creditCard.cardName}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer2<TransactionProviderHive, StatementProvider>(
        builder: (context, transactionProvider, statementProvider, child) {
          final assetAccounts = transactionProvider.accounts
              .where((account) => account.type == AccountType.bank || account.type == AccountType.cash)
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPaymentInfo(),
                const SizedBox(height: 24),
                _buildFromAccountSelector(assetAccounts),
                const SizedBox(height: 24),
                _buildPaymentAmountField(),
                const SizedBox(height: 24),
                _buildDescriptionField(),
                const SizedBox(height: 32),
                _buildPaymentButton(transactionProvider, statementProvider),
                if (assetAccounts.isEmpty) ...[
                  const SizedBox(height: 16),
                  _buildNoAccountsWarning(),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Information',
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
                Text('Current Balance:'),
                Text(
                  CurrencyService.formatAmount(widget.creditCard.currentBalance),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            if (widget.statement != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Statement Balance:'),
                  Text(
                    CurrencyService.formatAmount(widget.statement!.newBalance),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Statement Period:'),
                  Text(widget.statement!.statementPeriod),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Payment Amount:'),
                Text(
                  CurrencyService.formatAmount(_paymentAmount),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFromAccountSelector(List<Account> assetAccounts) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'From Account *',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (assetAccounts.isEmpty)
              const Text('No asset accounts available for payment')
            else
              DropdownButtonFormField<Account>(
                value: _selectedFromAccount,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Select account to pay from',
                ),
                items: assetAccounts.map((account) {
                  return DropdownMenuItem<Account>(
                    value: account,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getAccountIcon(account.type),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(account.name),
                              Text(
                                'Balance: ${CurrencyService.formatAmount(account.balance)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (account) {
                  setState(() {
                    _selectedFromAccount = account;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentAmountField() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Amount *',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _paymentAmount.toString(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Amount to pay',
                prefixText: '₹ ',
              ),
              onChanged: (value) {
                setState(() {
                  _paymentAmount = double.tryParse(value) ?? 0.0;
                });
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _paymentAmount = widget.creditCard.currentBalance;
                    });
                  },
                  child: const Text('Pay Full Balance'),
                ),
                if (widget.statement != null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _paymentAmount = widget.statement!.newBalance;
                      });
                    },
                    child: const Text('Pay Statement Balance'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _description,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Payment description',
              ),
              onChanged: (value) {
                setState(() {
                  _description = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentButton(TransactionProviderHive transactionProvider, StatementProvider statementProvider) {
    final isValid = _selectedFromAccount != null && 
                   _paymentAmount > 0 && 
                   _paymentAmount <= _selectedFromAccount!.balance;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isValid && !_isProcessing ? () => _processPayment(transactionProvider, statementProvider) : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isProcessing
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Processing Payment...'),
                ],
              )
            : Text('Pay ${CurrencyService.formatAmount(_paymentAmount)}'),
      ),
    );
  }

  Widget _buildNoAccountsWarning() {
    return Card(
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange[700]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'No asset accounts available. Please add a bank account or cash account first.',
                style: TextStyle(color: Colors.orange[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getAccountIcon(AccountType type) {
    switch (type) {
      case AccountType.bank:
        return Icons.account_balance;
      case AccountType.cash:
        return Icons.money;
      case AccountType.creditCard:
        return Icons.credit_card;
    }
  }

  Future<void> _processPayment(TransactionProviderHive transactionProvider, StatementProvider statementProvider) async {
    if (_selectedFromAccount == null || _paymentAmount <= 0) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Create transfer transaction (from asset account to credit card)
      await transactionProvider.addTransfer(
        fromAccountId: _selectedFromAccount!.id,
        toAccountId: widget.creditCard.accountId,
        amount: _paymentAmount,
        description: _description,
      );

      // Update statement status if this is a statement payment
      if (widget.statement != null) {
        await statementProvider.updateStatementStatus(
          widget.statement!.id,
          StatementStatus.paid,
          paymentAmount: _paymentAmount,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment of ${CurrencyService.formatAmount(_paymentAmount)} processed successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.of(context).pop(true); // Return true to indicate successful payment
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing payment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
