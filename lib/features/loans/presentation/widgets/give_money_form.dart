import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../../../data/models/account.dart';
import '../../../../data/providers/currency_provider.dart';
import '../../data/providers/debt_provider.dart';
import '../../data/models/debt.dart';
import 'payment_proof_gallery.dart';

class GiveMoneyForm extends StatefulWidget {
  final Debt debt;

  const GiveMoneyForm({
    super.key,
    required this.debt,
  });

  @override
  State<GiveMoneyForm> createState() => _GiveMoneyFormState();
}

class _GiveMoneyFormState extends State<GiveMoneyForm> {
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

    // Create a payment that represents giving money (increases debt amount)
    final givenPayment = DebtPayment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      debtId: widget.debt.id,
      amount: double.parse(_amountController.text),
      paymentDate: _selectedDate,
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      linkedAccountId: _selectedAccountId,
      createdAt: DateTime.now(),
      proofImages: _proofImages.map((file) => file.path).toList(),
      transactionType: 'give_money',
    );

    // Give money (this will increase the debt amount)
    await debtProvider.giveMoney(
      debtId: givenPayment.debtId,
      amount: givenPayment.amount,
      paymentDate: givenPayment.paymentDate,
      description: givenPayment.description,
      linkedAccountId: givenPayment.linkedAccountId,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gave ${currencyProvider.formatAmount(givenPayment.amount)} to ${widget.debt.personName}',
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
                    'Give Money to ${widget.debt.personName}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Debt Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Debt: ${currencyProvider.formatAmount(widget.debt.amount)}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'Paid: ${currencyProvider.formatAmount(widget.debt.paidAmount)}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'Remaining: ${currencyProvider.formatAmount(widget.debt.remainingAmount)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
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
                      labelText: 'Amount to Give',
                      hintText: 'Enter amount to give',
                      prefixIcon: const Icon(Icons.send),
                      suffixText: currencyProvider.currencySymbol,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      helperText: 'This will increase the debt amount',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Please enter a valid amount';
                      }
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
                          labelText: 'Date Given',
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
                      labelText: 'Account to Deduct From (Optional)',
                      hintText: 'Select an account',
                      prefixIcon: const Icon(Icons.account_balance),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      helperText: 'Money will be deducted from this account',
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
                      hintText: 'Add a note about giving the money',
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
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Give Money'),
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
