import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../../../data/models/account.dart';
import '../../../../data/providers/currency_provider.dart';
import '../../data/models/debt.dart';
import '../../data/providers/debt_provider.dart';
import 'payment_proof_gallery.dart';

class PaymentForm extends StatefulWidget {
  final Debt debt;

  const PaymentForm({
    super.key,
    required this.debt,
  });

  @override
  State<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  String? _selectedAccountId;
  List<File> _proofImages = [];
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Set default amount to remaining amount
    _amountController.text = widget.debt.remainingAmount.toString();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Consumer2<DebtProvider, CurrencyProvider>(
      builder: (context, debtProvider, currencyProvider, child) {
        final allAccounts = debtProvider.getAccounts();
        final accounts = allAccounts.where((account) => account.isAsset).toList();
        
        return Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.payment,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Record Payment',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'To: ${widget.debt.personName}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Form Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Debt Info Card
                    Card(
                      color: widget.debt.isYouOwe 
                        ? Colors.red.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  widget.debt.isYouOwe 
                                    ? Icons.arrow_upward 
                                    : Icons.arrow_downward,
                                  color: widget.debt.isYouOwe ? Colors.red : Colors.green,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  widget.debt.isYouOwe ? 'You Owe' : 'Owed to You',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: widget.debt.isYouOwe ? Colors.red : Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Total Amount',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                      Text(
                                        currencyProvider.formatAmount(widget.debt.amount),
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Paid',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                      Text(
                                        currencyProvider.formatAmount(widget.debt.paidAmount),
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Remaining',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                      Text(
                                        currencyProvider.formatAmount(widget.debt.remainingAmount),
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Payment Amount
                    TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: 'Payment Amount',
                        hintText: 'Enter payment amount',
                        prefixIcon: const Icon(Icons.attach_money),
                        suffixText: currencyProvider.currencySymbol,
                        border: const OutlineInputBorder(),
                        helperText: 'Maximum: ${currencyProvider.formatAmount(widget.debt.remainingAmount)}',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter payment amount';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'Please enter a valid amount';
                        }
                        if (amount > widget.debt.remainingAmount) {
                          return 'Payment cannot exceed remaining amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Date
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Payment Date'),
                      subtitle: Text(_formatDate(_selectedDate)),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: _selectDate,
                    ),
                    const SizedBox(height: 16),
                    
                    // Linked Account (Simplified)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account for Payment (Optional)',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.debt.isYouOwe 
                              ? 'Select the account you\'re paying from (your balance will decrease)'
                              : 'Select the account you\'re receiving money to (your balance will increase)',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _selectedAccountId,
                            decoration: const InputDecoration(
                              labelText: 'Select Account',
                              hintText: 'Choose account',
                              prefixIcon: Icon(Icons.account_balance),
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('No account linked'),
                              ),
                              ...accounts.map((account) => DropdownMenuItem<String>(
                                value: account.id,
                                child: Text('${account.name} (${currencyProvider.formatAmount(account.balance)})'),
                              )),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedAccountId = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                        hintText: 'Enter payment description',
                        prefixIcon: Icon(Icons.description),
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    
                    // Proof Images
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PaymentProofGallery(
                            imagePaths: _proofImages.map((file) => file.path).toList(),
                            canEdit: true,
                            onImagesChanged: (newImagePaths) {
                              setState(() {
                                _proofImages = newImagePaths.map((path) => File(path)).toList();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitForm,
                            child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Record Payment'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final debtProvider = context.read<DebtProvider>();
      
      final payment = await debtProvider.addPayment(
        debtId: widget.debt.id,
        amount: double.parse(_amountController.text),
        paymentDate: _selectedDate,
        description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
        linkedAccountId: _selectedAccountId,
      );
      
      if (payment != null && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment recorded successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
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
