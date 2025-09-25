import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/transaction.dart';
import '../../../../data/models/category.dart' as app_category;
import '../../../../data/providers/transaction_provider_hive.dart';
import '../../../../data/providers/currency_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../controllers/transaction_form_controller.dart';
import 'multiple_receipt_image_picker.dart';

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
                                  
                                  // Receipt Image Section
                                  _buildReceiptSection(),
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
        
        // Title input (compact)
        TextFormField(
          controller: _controller.descriptionController,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: 'Enter transaction title',
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
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
        const SizedBox(height: 12),
        
        // Large amount input
        TextFormField(
          controller: _controller.amountController,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
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
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
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
                      '${context.read<CurrencyProvider>().currencySymbol}${amount.toStringAsFixed(0)}',
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
        
        // Subcategory (if category selected)
        if (_controller.selectedCategoryId != null) ...[
          _buildSubcategoryCard(transactionProvider),
          const SizedBox(height: 12),
        ],
        
        // Date and Time in one row
        Row(
          children: [
            Expanded(child: _buildDateCard()),
            const SizedBox(width: 12),
            Expanded(child: _buildTimeCard()),
          ],
        ),
        const SizedBox(height: 12),
        
        // Notes section (full width)
        _buildNotesSection(),
      ],
    );
  }

  /// Account selection card
  Widget _buildAccountCard(TransactionProviderHive transactionProvider) {
    // Validate account selection when accounts change
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final availableAccountIds = transactionProvider.accounts.map((a) => a.id).toList();
      _controller.validateAccountSelection(availableAccountIds);
    });

    // Get valid account ID (null if account doesn't exist)
    final validAccountId = _controller.selectedAccountId != null && 
        transactionProvider.accounts.any((a) => a.id == _controller.selectedAccountId) 
        ? _controller.selectedAccountId 
        : null;

    return _buildInfoCard(
      title: 'Account',
      icon: Icons.account_balance_wallet,
      child: DropdownButtonFormField<String>(
        value: validAccountId,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        isExpanded: true,
        menuMaxHeight: 200,
        dropdownColor: Colors.white,
        style: TextStyle(
          color: AppTheme.lightText,
          fontSize: 16,
        ),
        items: transactionProvider.accounts.map((account) {
          return DropdownMenuItem<String>(
            value: account.id,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  account.type.toString() == 'AccountType.bank'
                      ? Icons.account_balance
                      : account.type.toString() == 'AccountType.creditCard'
                          ? Icons.credit_card
                          : Icons.money,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${account.name} - ${context.read<CurrencyProvider>().currencySymbol}${account.balance.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: account.balance >= 0 ? Colors.black87 : Colors.red,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
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
    
    return Column(
      children: [
        _buildInfoCard(
          title: 'Category',
          icon: Icons.category,
          child: DropdownButtonFormField<String>(
            value: _controller.selectedCategoryId,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            isExpanded: true,
            menuMaxHeight: 200,
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
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () => _showAddCategoryDialog(),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Category', style: TextStyle(fontSize: 12)),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ],
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

  /// Time selection card
  Widget _buildTimeCard() {
    return _buildInfoCard(
      title: 'Time',
      icon: Icons.access_time,
      child: GestureDetector(
        onTap: _selectTime,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            '${_controller.selectedTime.hour.toString().padLeft(2, '0')}:${_controller.selectedTime.minute.toString().padLeft(2, '0')}',
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

  /// Subcategory selection card (always visible when category selected)
  Widget _buildSubcategoryCard(TransactionProviderHive transactionProvider) {
    final subcategories = transactionProvider.getSubcategories(_controller.selectedCategoryId!);
    
    return Column(
      children: [
        _buildInfoCard(
          title: 'Subcategory',
          icon: Icons.subdirectory_arrow_right,
          child: subcategories.isEmpty
              ? const Text(
                  'No subcategories available',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                )
              : DropdownButtonFormField<String>(
                  value: _controller.selectedSubcategoryId,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    hintText: 'Select subcategory (optional)',
                  ),
                  isExpanded: true,
                  menuMaxHeight: 200,
                  items: [
                    // Add "None" option
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('None', style: TextStyle(fontSize: 14)),
                    ),
                    // Add all subcategories
                    ...subcategories.map((subcategory) {
                      return DropdownMenuItem<String>(
                        value: subcategory.id,
                        child: Text(
                          subcategory.name,
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    _controller.updateSubcategoryId(value);
                  },
                ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () => _showAddSubcategoryDialog(),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Subcategory', style: TextStyle(fontSize: 12)),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  /// Notes section (full width, bigger)
  Widget _buildNotesSection() {
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
              Icon(Icons.note, size: 16, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                'Notes',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _controller.notesController,
            maxLines: 4,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: 'Add any additional notes about this transaction...',
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  /// Receipt image section
  Widget _buildReceiptSection() {
    return Column(
      children: [
        const SizedBox(height: 12),
        _buildReceiptField(),
      ],
    );
  }



  Widget _buildReceiptField() {
    return MultipleReceiptImagePicker(
      receiptImagePaths: _controller.receiptImagePaths,
      onPickImages: _controller.pickMultipleImages,
      onRemoveImage: _controller.removeImageAt,
      onClearAll: _controller.clearAllImages,
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

  /// Show add category dialog
  Future<void> _showAddCategoryDialog() async {
    final categoryType = _controller.selectedType == TransactionType.income 
        ? app_category.CategoryType.income 
        : app_category.CategoryType.expense;
    
    final nameController = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add ${categoryType.name} Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                try {
                  final transactionProvider = Provider.of<TransactionProviderHive>(context, listen: false);
                  final newCategory = app_category.Category(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text.trim(),
                    icon: 'category',
                    type: categoryType,
                    color: '0xFF3B82F6',
                  );
                  
                  await transactionProvider.addCategory(newCategory);
                  Navigator.pop(context, true);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
    
    if (result == true) {
      setState(() {}); // Refresh the form
    }
  }

  /// Show add subcategory dialog
  Future<void> _showAddSubcategoryDialog() async {
    if (_controller.selectedCategoryId == null) return;
    
    final categoryType = _controller.selectedType == TransactionType.income 
        ? app_category.CategoryType.income 
        : app_category.CategoryType.expense;
    
    final nameController = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Subcategory'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Subcategory Name',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                try {
                  final transactionProvider = Provider.of<TransactionProviderHive>(context, listen: false);
                  final newSubcategory = app_category.Category(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text.trim(),
                    icon: 'subdirectory_arrow_right',
                    type: categoryType,
                    color: '0xFF8B5CF6',
                    parentId: _controller.selectedCategoryId,
                  );
                  
                  await transactionProvider.addCategory(newSubcategory);
                  Navigator.pop(context, true);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
    
    if (result == true) {
      setState(() {}); // Refresh the form
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
