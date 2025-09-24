import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/currency_provider.dart';
import '../../data/providers/transaction_provider_hive.dart';
import '../../data/providers/credit_card_provider.dart';
import '../../data/models/account.dart';
import '../../core/theme/app_theme.dart';

class TransferDialog extends StatefulWidget {
  const TransferDialog({super.key});

  @override
  State<TransferDialog> createState() => _TransferDialogState();
}

class _TransferDialogState extends State<TransferDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  Account? _fromAccount;
  Account? _toAccount;
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TransactionProviderHive, CurrencyProvider>(
      builder: (context, transactionProvider, currencyProvider, child) {
        final accounts = transactionProvider.accounts;
        
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.swap_horiz,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              const Text('Transfer Money'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // From Account
                  DropdownButtonFormField<Account>(
                    value: _fromAccount,
                    decoration: InputDecoration(
                      labelText: 'From Account',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.account_balance_wallet),
                    ),
                    dropdownColor: Colors.white,
                    style: TextStyle(
                      color: AppTheme.lightText,
                      fontSize: 16,
                    ),
                    items: accounts.map((account) {
                      return DropdownMenuItem<Account>(
                        value: account,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getAccountIcon(account.type),
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                '${account.name} (${currencyProvider.formatAmount(account.balance)})',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.lightText,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _fromAccount = value;
                        // Reset to account if it's the same as from account
                        if (_toAccount == value) {
                          _toAccount = null;
                        }
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select source account';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // To Account
                  DropdownButtonFormField<Account>(
                    value: _toAccount,
                    decoration: InputDecoration(
                      labelText: 'To Account',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.account_balance),
                    ),
                    dropdownColor: Colors.white,
                    style: TextStyle(
                      color: AppTheme.lightText,
                      fontSize: 16,
                    ),
                    items: accounts.where((account) => account != _fromAccount).map((account) {
                      return DropdownMenuItem<Account>(
                        value: account,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getAccountIcon(account.type),
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                '${account.name} (${currencyProvider.formatAmount(account.balance)})',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.lightText,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _toAccount = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select destination account';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Amount
                  TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.attach_money),
                      prefixText: '${currencyProvider.currencySymbol} ',
                    ),
                    style: TextStyle(
                      color: AppTheme.lightText,
                      fontSize: 16,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter amount';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Please enter valid amount';
                      }
                      if (_fromAccount != null && amount > _fromAccount!.balance) {
                        return 'Insufficient balance';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description (Optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.description),
                    ),
                    style: TextStyle(
                      color: AppTheme.lightText,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : _performTransfer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Transfer'),
            ),
          ],
        );
      },
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

  Future<void> _performTransfer() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_fromAccount == null || _toAccount == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final amount = double.parse(_amountController.text);
      final description = _descriptionController.text.isEmpty 
          ? 'Transfer from ${_fromAccount!.name} to ${_toAccount!.name}'
          : _descriptionController.text;
      
      // Create transfer transaction
      await context.read<TransactionProviderHive>().addTransfer(
        fromAccountId: _fromAccount!.id,
        toAccountId: _toAccount!.id,
        amount: amount,
        description: description,
      );
      
      // Refresh credit card provider to ensure UI updates
      if (mounted) {
        context.read<CreditCardProvider>().refresh();
        
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transfer of ${context.read<CurrencyProvider>().formatAmount(amount)} completed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transfer failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
