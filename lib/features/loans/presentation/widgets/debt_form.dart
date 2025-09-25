import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/debt.dart';
import '../../../../data/models/account.dart';
import '../../../../data/providers/currency_provider.dart';
import '../../data/providers/debt_provider.dart';

class DebtForm extends StatefulWidget {
  final Debt? debt;
  final bool isEditing;
  final bool defaultIsYouOwe;

  const DebtForm({
    Key? key,
    this.debt,
    this.isEditing = false,
    this.defaultIsYouOwe = true,
  }) : super(key: key);

  @override
  State<DebtForm> createState() => _DebtFormState();
}

class _DebtFormState extends State<DebtForm> {
  final _formKey = GlobalKey<FormState>();
  final _personNameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  bool _isYouOwe = true;
  DateTime _selectedDate = DateTime.now();
  String? _selectedAccountId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isYouOwe = widget.defaultIsYouOwe;
    
    if (widget.isEditing && widget.debt != null) {
      final debt = widget.debt!;
      _personNameController.text = debt.personName;
      _amountController.text = debt.amount.toString();
      _descriptionController.text = debt.description ?? '';
      _isYouOwe = debt.isYouOwe;
      _selectedDate = debt.date;
      _selectedAccountId = debt.linkedAccountId ?? '';
    }
  }

  @override
  void dispose() {
    _personNameController.dispose();
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
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
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
                        widget.isEditing ? Icons.edit : Icons.add,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.isEditing ? 'Edit Debt' : 'Add New Debt',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
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
                      // Person Name
                      TextFormField(
                        controller: _personNameController,
                        decoration: const InputDecoration(
                          labelText: 'Person Name',
                          hintText: 'Enter person\'s name',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter person\'s name';
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
                          hintText: 'Enter amount',
                          prefixIcon: const Icon(Icons.attach_money),
                          suffixText: currencyProvider.currencySymbol,
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter amount';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount <= 0) {
                            return 'Please enter a valid amount';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description (Optional)',
                          hintText: 'Enter description',
                          prefixIcon: Icon(Icons.description),
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      
                      // Debt Type
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Debt Type',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              RadioListTile<bool>(
                                title: const Text('I Owe Money'),
                                subtitle: const Text('I borrowed money from someone'),
                                value: true,
                                groupValue: _isYouOwe,
                                onChanged: (value) {
                                  setState(() {
                                    _isYouOwe = value!;
                                  });
                                },
                              ),
                              RadioListTile<bool>(
                                title: const Text('Owed to Me'),
                                subtitle: const Text('Someone owes me money'),
                                value: false,
                                groupValue: _isYouOwe,
                                onChanged: (value) {
                                  setState(() {
                                    _isYouOwe = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Date
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.calendar_today),
                          title: const Text('Date'),
                          subtitle: Text(
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          ),
                          trailing: const Icon(Icons.arrow_drop_down),
                          onTap: _selectDate,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Account Selection
                      if (accounts.isNotEmpty) ...[
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Linked Account',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: _selectedAccountId,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Select account',
                                  ),
                                  items: accounts.map((account) {
                                    return DropdownMenuItem<String>(
                                      value: account.id,
                                      child: Text(account.name),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedAccountId = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select an account';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isLoading ? null : () {
                                Navigator.pop(context);
                              },
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
                                  : Text(widget.isEditing ? 'Update' : 'Create'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final debtProvider = context.read<DebtProvider>();
      
      if (widget.isEditing && widget.debt != null) {
        // Update existing debt
        final updatedDebt = widget.debt!.copyWith(
          personName: _personNameController.text.trim(),
          amount: double.parse(_amountController.text),
          description: _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
          isYouOwe: _isYouOwe,
          date: _selectedDate,
          linkedAccountId: _selectedAccountId,
        );
        
        final success = await debtProvider.updateDebt(updatedDebt);
        
        if (success && mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Debt updated successfully')),
          );
        }
      } else {
        // Create new debt
        final createdDebt = await debtProvider.addDebt(
          personName: _personNameController.text.trim(),
          amount: double.parse(_amountController.text),
          isYouOwe: _isYouOwe,
          date: _selectedDate,
          description: _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
          linkedAccountId: _selectedAccountId,
        );
        
        if (createdDebt != null && mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Debt created successfully')),
          );
        }
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


