import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/transaction.dart';
import '../../../../data/models/category.dart' as app_category;
import '../../../../data/providers/transaction_provider_hive.dart';
import '../controllers/transaction_form_controller.dart';

/// Compact Transaction Form
/// A more efficient and user-friendly layout for adding transactions
/// Author: Pown Kumar - Founder of Korelium
/// Date: September 18, 2025

class CompactTransactionForm extends StatefulWidget {
  final Transaction? transaction;
  final TransactionType? initialType;

  const CompactTransactionForm({
    super.key,
    this.transaction,
    this.initialType,
  });

  @override
  State<CompactTransactionForm> createState() => _CompactTransactionFormState();
}

class _CompactTransactionFormState extends State<CompactTransactionForm> {
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
                    return Column(
                      children: [
                        // Compact Form Content
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  // Compact Header with Type and Amount
                                  _buildCompactHeader(),
                                  const SizedBox(height: 20),
                                  
                                  // Essential Fields in Cards
                                  _buildEssentialFields(transactionProvider),
                                  const SizedBox(height: 20),
                                  
                                  // Optional Fields (Collapsible)
                                  _buildOptionalFields(),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        // Fixed Save Button at Bottom
                        _buildFixedSaveButton(),
                      ],
                    );
                  },
                );
        },
      ),
    );
  }

  /// Compact header with transaction type and amount in one row
  Widget _buildCompactHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          // Transaction Type Toggle (Compact)
          _buildCompactTypeToggle(),
          const SizedBox(height: 16),
          
          // Amount Input (Large and prominent)
          _buildCompactAmountInput(),
        ],
      ),
    );
  }

  /// Compact transaction type toggle
  Widget _buildCompactTypeToggle() {
    return Row(
      children: [
        Expanded(
          child: _buildTypeButton(
            type: TransactionType.expense,
            icon: Icons.trending_down,
            label: 'Expense',
            color: Colors.red,
            isSelected: _controller.selectedType == TransactionType.expense,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTypeButton(
            type: TransactionType.income,
            icon: Icons.trending_up,
            label: 'Income',
            color: Colors.green,
            isSelected: _controller.selectedType == TransactionType.income,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeButton({
    required TransactionType type,
    required IconData icon,
    required String label,
    required Color color,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => _controller.updateTransactionType(type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : color,
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Compact amount input with quick buttons
  Widget _buildCompactAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        // Large amount input
        TextFormField(
          controller: _controller.amountController,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            hintText: '0.00',
            hintStyle: TextStyle(
              fontSize: 24,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.currency_rupee, size: 28),
            suffixText: 'INR',
            suffixStyle: const TextStyle(fontSize: 16),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter amount';
            }
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return 'Please enter a valid amount';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 12),
        
        // Quick amount buttons (horizontal)
        SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _controller.quickAmounts.length,
            itemBuilder: (context, index) {
              final amount = _controller.quickAmounts[index];
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    _controller.amountController.text = amount.toString();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      '₹${amount.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Essential fields in compact cards
  Widget _buildEssentialFields(TransactionProviderHive transactionProvider) {
    return Column(
      children: [
        // Account and Category in one row
        Row(
          children: [
            Expanded(child: _buildAccountCard(transactionProvider)),
            const SizedBox(width: 12),
            Expanded(child: _buildCategoryCard(transactionProvider)),
          ],
        ),
        const SizedBox(height: 12),
        
        // Title and Date in one row
        Row(
          children: [
            Expanded(child: _buildTitleCard()),
            const SizedBox(width: 12),
            Expanded(child: _buildDateCard()),
          ],
        ),
      ],
    );
  }

  /// Account selection card
  Widget _buildAccountCard(TransactionProviderHive transactionProvider) {
    return _buildInfoCard(
      title: 'Account',
      icon: Icons.account_balance_wallet,
      child: DropdownButtonFormField<String>(
        value: _controller.selectedAccountId,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        items: transactionProvider.accounts.map((account) {
          return DropdownMenuItem<String>(
            value: account.id,
            child: Text(
              account.name,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: _controller.updateAccountId,
        validator: (value) => value == null ? 'Select account' : null,
      ),
    );
  }

  /// Category selection card
  Widget _buildCategoryCard(TransactionProviderHive transactionProvider) {
    final categoryType = _controller.selectedType == TransactionType.income 
        ? app_category.CategoryType.income 
        : app_category.CategoryType.expense;
    final mainCategories = transactionProvider.getMainCategories(categoryType);
    
    return _buildInfoCard(
      title: 'Category',
      icon: Icons.category,
      child: DropdownButtonFormField<String>(
        value: _controller.selectedCategoryId,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        items: mainCategories.map((category) {
          return DropdownMenuItem<String>(
            value: category.id,
            child: Text(
              category.name,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: _controller.updateCategoryId,
        validator: (value) => value == null ? 'Select category' : null,
      ),
    );
  }

  /// Title input card
  Widget _buildTitleCard() {
    return _buildInfoCard(
      title: 'Title',
      icon: Icons.title,
      child: TextFormField(
        controller: _controller.descriptionController,
        decoration: const InputDecoration(
          hintText: 'Enter title',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        style: const TextStyle(fontSize: 14),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Enter title';
          }
          return null;
        },
      ),
    );
  }

  /// Date selection card
  Widget _buildDateCard() {
    return _buildInfoCard(
      title: 'Date',
      icon: Icons.calendar_today,
      child: GestureDetector(
        onTap: _selectDate,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            '${_controller.selectedDate.day}/${_controller.selectedDate.month}/${_controller.selectedDate.year}',
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ),
    );
  }

  /// Generic info card widget
  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  /// Optional fields (collapsible)
  Widget _buildOptionalFields() {
    return ExpansionTile(
      title: Text(
        'More Options',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      children: [
        // Subcategory (if main category selected)
        if (_controller.selectedCategoryId != null) ...[
          _buildSubcategoryField(),
          const SizedBox(height: 12),
        ],
        
        // Notes
        _buildNotesField(),
        const SizedBox(height: 12),
        
        // Receipt Image
        _buildReceiptField(),
      ],
    );
  }

  Widget _buildSubcategoryField() {
    return _buildInfoCard(
      title: 'Subcategory',
      icon: Icons.subdirectory_arrow_right,
      child: Consumer<TransactionProviderHive>(
        builder: (context, transactionProvider, child) {
          final subcategories = transactionProvider.getSubcategories(_controller.selectedCategoryId!);
          
          if (subcategories.isEmpty) {
            return const Text(
              'No subcategories',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            );
          }
          
          return DropdownButtonFormField<String>(
            value: _controller.selectedSubcategoryId,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: subcategories.map((subcategory) {
              return DropdownMenuItem<String>(
                value: subcategory.id,
                child: Text(
                  subcategory.name,
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: _controller.updateSubcategoryId,
          );
        },
      ),
    );
  }

  Widget _buildNotesField() {
    return _buildInfoCard(
      title: 'Notes',
      icon: Icons.note,
      child: TextFormField(
        maxLines: 2,
        decoration: const InputDecoration(
          hintText: 'Add notes...',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _buildReceiptField() {
    return _buildInfoCard(
      title: 'Receipt',
      icon: Icons.receipt,
      child: Row(
        children: [
          if (_controller.receiptImagePath != null) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: FileImage(File(_controller.receiptImagePath!)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Receipt attached',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            IconButton(
              onPressed: _controller.removeImage,
              icon: const Icon(Icons.close, size: 16),
            ),
          ] else ...[
            Expanded(
              child: GestureDetector(
                onTap: _controller.pickImage,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, size: 16),
                      const SizedBox(width: 4),
                      Text('Add Receipt', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Fixed save button at bottom
  Widget _buildFixedSaveButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
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
        ),
      ),
    );
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
}
