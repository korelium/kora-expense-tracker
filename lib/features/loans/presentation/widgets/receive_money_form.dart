import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../../../data/models/account.dart';
import '../../../../data/providers/currency_provider.dart';
import '../../data/providers/debt_provider.dart';
import '../../data/models/debt.dart';
import 'payment_proof_gallery.dart';

class ReceiveMoneyForm extends StatefulWidget {
  final Debt debt;

  const ReceiveMoneyForm({
    super.key,
    required this.debt,
  });

  @override
  State<ReceiveMoneyForm> createState() => _ReceiveMoneyFormState();
}

class _ReceiveMoneyFormState extends State<ReceiveMoneyForm> {
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
    // Set default amount to 0 for new loan
    _amountController.text = '0.00';
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final debtProvider = context.read<DebtProvider>();
    final currencyProvider = context.read<CurrencyProvider>();

    // Create a payment that represents receiving money
    // This will reduce the debt amount
    final receivedPayment = DebtPayment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      debtId: widget.debt.id,
      amount: double.parse(_amountController.text),
      paymentDate: _selectedDate,
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      linkedAccountId: _selectedAccountId,
      createdAt: DateTime.now(),
      proofImages: _proofImages.map((file) => file.path).toList(),
    );

    // Handle based on debt type
    if (widget.debt.isYouOwe) {
      // For "I Owe Money" debts, receiving money increases the debt (taking more loan)
      await debtProvider.receiveMoney(
        debtId: receivedPayment.debtId,
        amount: receivedPayment.amount,
        paymentDate: receivedPayment.paymentDate,
        description: receivedPayment.description,
        linkedAccountId: receivedPayment.linkedAccountId,
      );
    } else {
      // For "Owed to Me" debts, getting money back is a payment that reduces the debt
      await debtProvider.addPayment(
        debtId: receivedPayment.debtId,
        amount: receivedPayment.amount,
        paymentDate: receivedPayment.paymentDate,
        description: receivedPayment.description,
        linkedAccountId: receivedPayment.linkedAccountId,
      );
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.debt.isYouOwe 
              ? 'Received ${currencyProvider.formatAmount(receivedPayment.amount)} from ${widget.debt.personName}'
              : 'Got back ${currencyProvider.formatAmount(receivedPayment.amount)} from ${widget.debt.personName}',
          ),
        ),
      );
      Navigator.pop(context);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<DebtProvider, CurrencyProvider>(
      builder: (context, debtProvider, currencyProvider, child) {
        final allAccounts = debtProvider.getAccounts();
        final assetAccounts = allAccounts.where((account) => account.isAsset).toList();

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Take More Money from ${widget.debt.personName}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Debt Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Amount: ${currencyProvider.formatAmount(widget.debt.amount)}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'Paid: ${currencyProvider.formatAmount(widget.debt.paidAmount)}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'Current Debt: ${currencyProvider.formatAmount(widget.debt.amount)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Amount
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Amount Received',
                      hintText: 'Enter amount received',
                      prefixIcon: const Icon(Icons.call_received),
                      suffixText: currencyProvider.currencySymbol,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      helperText: 'Enter the amount you want to borrow',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Please enter a valid amount';
                      }
                      // No maximum limit for receiving money (taking new loans)
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Payment Date
                  GestureDetector(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null && picked != _selectedDate) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Date Received',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        controller: TextEditingController(
                          text: '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Linked Account
                  DropdownButtonFormField<String>(
                    value: _selectedAccountId,
                    decoration: InputDecoration(
                      labelText: 'Account to Receive Money (Optional)',
                      hintText: 'Select an account',
                      prefixIcon: const Icon(Icons.account_balance),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      helperText: 'Money will be added to this account',
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('No Linked Account'),
                      ),
                      ...assetAccounts.map((account) {
                        return DropdownMenuItem(
                          value: account.id,
                          child: Text(
                            '${account.name} (${currencyProvider.formatAmount(account.balance)})',
                          ),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedAccountId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Description (Optional)',
                      hintText: 'Add a note about receiving the money',
                      prefixIcon: const Icon(Icons.description),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payment Proof Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Record Received'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
