import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/transaction_provider_hive.dart';
import '../../../data/models/transaction.dart';
import '../../../data/models/category.dart' as app_category;

class AddExpenseScreen extends StatefulWidget {
  final Transaction? expense;
  final TransactionType? initialType;

  const AddExpenseScreen({super.key, this.expense, this.initialType});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  
  String? _selectedAccountId;
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  TransactionType _selectedType = TransactionType.expense;

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _descriptionController.text = widget.expense!.description;
      _amountController.text = widget.expense!.amount.toString();
      _selectedAccountId = widget.expense!.accountId;
      _selectedCategoryId = widget.expense!.categoryId;
      _selectedDate = widget.expense!.date;
      _selectedType = widget.expense!.type;
    } else if (widget.initialType != null) {
      _selectedType = widget.initialType!;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense == null ? 'Add Transaction' : 'Edit Transaction'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          TextButton(
            onPressed: _saveExpense,
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Consumer<TransactionProviderHive>(
        builder: (context, transactionProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Description Field
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Enter expense description',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Transaction Type Selector
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedType = TransactionType.income;
                              _selectedCategoryId = null; // Reset category when type changes
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                            decoration: BoxDecoration(
                              color: _selectedType == TransactionType.income
                                  ? const Color(0xFF22C55E).withValues(alpha: 0.1)
                                  : Theme.of(context).colorScheme.surface,
                              border: Border.all(
                                color: _selectedType == TransactionType.income
                                    ? const Color(0xFF22C55E)
                                    : Theme.of(context).colorScheme.outline,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.arrow_upward,
                                  color: _selectedType == TransactionType.income
                                      ? const Color(0xFF22C55E)
                                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Income',
                                  style: TextStyle(
                                    color: _selectedType == TransactionType.income
                                        ? const Color(0xFF22C55E)
                                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedType = TransactionType.expense;
                              _selectedCategoryId = null; // Reset category when type changes
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                            decoration: BoxDecoration(
                              color: _selectedType == TransactionType.expense
                                  ? const Color(0xFFEF4444).withValues(alpha: 0.1)
                                  : Theme.of(context).colorScheme.surface,
                              border: Border.all(
                                color: _selectedType == TransactionType.expense
                                    ? const Color(0xFFEF4444)
                                    : Theme.of(context).colorScheme.outline,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.arrow_downward,
                                  color: _selectedType == TransactionType.expense
                                      ? const Color(0xFFEF4444)
                                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Expense',
                                  style: TextStyle(
                                    color: _selectedType == TransactionType.expense
                                        ? const Color(0xFFEF4444)
                                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Amount Field
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      hintText: 'Enter amount',
                      border: OutlineInputBorder(),
                      prefixText: '\$ ',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      if (double.parse(value) <= 0) {
                        return 'Amount must be greater than 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Account Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _selectedAccountId,
                    decoration: const InputDecoration(
                      labelText: 'Account',
                      border: OutlineInputBorder(),
                    ),
                    items: transactionProvider.accounts.map((account) {
                      return DropdownMenuItem(
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
                  const SizedBox(height: 16),

                  // Category Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: _getFilteredCategories(transactionProvider.categories).map((category) {
                      return DropdownMenuItem(
                        value: category.id,
                        child: Row(
                          children: [
                            Icon(_getIconData(category.icon)),
                            const SizedBox(width: 8),
                            Text(category.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Date Picker
                  InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDate(_selectedDate)),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Save Button
                  ElevatedButton(
                    onPressed: _saveExpense,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      widget.expense == null ? 'Add Transaction' : 'Update Transaction',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'movie':
        return Icons.movie;
      case 'work':
        return Icons.work;
      case 'laptop':
        return Icons.laptop;
      default:
        return Icons.help;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      final transactionProvider = context.read<TransactionProviderHive>();
      
      final transaction = Transaction(
        id: widget.expense?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        accountId: _selectedAccountId!,
        categoryId: _selectedCategoryId!,
        amount: double.parse(_amountController.text),
        description: _descriptionController.text,
        date: _selectedDate,
        type: _selectedType,
      );

      try {
        if (widget.expense == null) {
          // Adding new transaction
          await transactionProvider.addTransaction(transaction);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${_selectedType == TransactionType.income ? 'Income' : 'Expense'} added successfully')),
          );
        } else {
          // Updating existing transaction
          await transactionProvider.updateTransaction(transaction);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${_selectedType == TransactionType.income ? 'Income' : 'Expense'} updated successfully')),
          );
        }
      } catch (e) {
        // Show error message if transaction fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
        return; // Don't close the screen if there's an error
      }

      Navigator.pop(context);
    }
  }

  /// Get filtered categories based on transaction type
  List<app_category.Category> _getFilteredCategories(List<app_category.Category> categories) {
    return categories.where((category) {
      if (_selectedType == TransactionType.income) {
        return category.type == app_category.CategoryType.income;
      } else {
        return category.type == app_category.CategoryType.expense;
      }
    }).toList();
  }
}
