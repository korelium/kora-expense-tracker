import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/transaction.dart';
import '../../../data/providers/transaction_provider_hive.dart';
import 'controllers/transaction_form_controller.dart';
import 'widgets/transaction_type_toggle.dart';
import 'widgets/amount_input_section.dart';
import 'widgets/account_selector.dart';
import 'widgets/category_selector.dart';
import 'widgets/subcategory_selector.dart';
import 'widgets/date_time_picker.dart';
import 'widgets/receipt_image_picker.dart';

/// Modern Transaction Form Screen
/// Refactored with clean widget separation and controller pattern
/// Author: Pown Kumar - Founder of Korelium
/// Date: September 18, 2025

class TransactionFormScreen extends StatefulWidget {
  final Transaction? transaction;
  final TransactionType? initialType;

  const TransactionFormScreen({
    super.key,
    this.transaction,
    this.initialType,
  });

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  late TransactionFormController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TransactionFormController();
    
    if (widget.transaction != null) {
      _controller.initializeWithTransaction(widget.transaction!);
    } else if (widget.initialType != null) {
      _controller.initializeWithType(widget.initialType!);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Show delete confirmation dialog
  Future<void> _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction? This action cannot be undone.'),
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

    if (confirmed == true && widget.transaction != null) {
      try {
        final transactionProvider = Provider.of<TransactionProviderHive>(context, listen: false);
        await transactionProvider.deleteTransaction(widget.transaction!.id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaction deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceFirst('Exception: ', '')),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// Select date
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _controller.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _controller.selectedDate) {
      _controller.updateDate(picked);
    }
  }

  /// Select time
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _controller.selectedTime,
    );
    if (picked != null && picked != _controller.selectedTime) {
      _controller.updateTime(picked);
    }
  }

  /// Save transaction
  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate() || !_controller.validateForm()) {
      return;
    }

    _controller.setLoading(true);

    try {
      final transactionProvider = Provider.of<TransactionProviderHive>(context, listen: false);
      
      if (widget.transaction == null) {
        // Adding new transaction
        final transaction = _controller.createTransaction();
        await transactionProvider.addTransaction(transaction);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_controller.selectedType == TransactionType.income ? 'Income' : 'Expense'} added successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Updating existing transaction
        final transaction = _controller.updateTransaction(widget.transaction!);
        await transactionProvider.updateTransaction(transaction);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_controller.selectedType == TransactionType.income ? 'Income' : 'Expense'} updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _controller.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          widget.transaction == null ? 'Add Transaction' : 'Edit Transaction',
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        actions: [
          if (widget.transaction != null)
            IconButton(
              onPressed: _showDeleteConfirmation,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete Transaction',
              color: Colors.red,
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return _controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Consumer<TransactionProviderHive>(
                  builder: (context, transactionProvider, child) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Transaction Type Toggle
                            TransactionTypeToggle(
                              selectedType: _controller.selectedType,
                              onTypeChanged: _controller.updateTransactionType,
                            ),
                            const SizedBox(height: 24),

                            // Amount Input with Quick Buttons
                            AmountInputSection(
                              amountController: _controller.amountController,
                              onAmountChanged: () {},
                              quickAmounts: _controller.quickAmounts,
                            ),
                            const SizedBox(height: 24),

                            // Account Selector
                            AccountSelector(
                              selectedAccountId: _controller.selectedAccountId,
                              accounts: transactionProvider.accounts,
                              onAccountChanged: _controller.updateAccountId,
                            ),
                            const SizedBox(height: 24),

                            // Title Input
                            _buildTitleInput(),
                            const SizedBox(height: 24),

                            // Category Selector
                            CategorySelector(
                              selectedCategoryId: _controller.selectedCategoryId,
                              transactionType: _controller.selectedType,
                              onCategoryChanged: _controller.updateCategoryId,
                              onCategoryAdded: () {},
                            ),
                            
                            // Subcategory Selection
                            if (_controller.selectedCategoryId != null) ...[
                              const SizedBox(height: 12),
                              SubcategorySelector(
                                selectedCategoryId: _controller.selectedCategoryId,
                                selectedSubcategoryId: _controller.selectedSubcategoryId,
                                onSubcategoryChanged: _controller.updateSubcategoryId,
                                onSubcategoryAdded: () {},
                              ),
                            ],
                            
                            const SizedBox(height: 24),

                            // Date & Time Picker
                            DateTimePicker(
                              selectedDate: _controller.selectedDate,
                              selectedTime: _controller.selectedTime,
                              onDateTap: _selectDate,
                              onTimeTap: _selectTime,
                            ),
                            const SizedBox(height: 24),

                            // Notes Input
                            _buildNotesInput(),
                            const SizedBox(height: 24),

                            // Receipt Image
                            ReceiptImagePicker(
                              receiptImagePath: _controller.receiptImagePath,
                              onPickImage: _controller.pickImage,
                              onRemoveImage: _controller.removeImage,
                            ),
                            const SizedBox(height: 32),

                            // Save Button
                            _buildSaveButton(),
                          ],
                        ),
                      ),
                    );
                  },
                );
        },
      ),
    );
  }

  Widget _buildTitleInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Title',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _controller.descriptionController,
          decoration: InputDecoration(
            hintText: 'Enter transaction title',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.title),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a title';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildNotesInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes (Optional)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Add any additional notes...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.note),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _controller.isLoading ? null : _saveTransaction,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _controller.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                widget.transaction == null ? 'Add Transaction' : 'Update Transaction',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
