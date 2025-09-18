import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../../../data/providers/transaction_provider_hive.dart';
import '../../../data/models/transaction.dart';
import '../../../data/models/category.dart' as app_category;
import '../categories/add_category_screen.dart';
import 'dart:io';

/// Modern Add Transaction Screen
/// User-friendly interface with unlimited categories and smart suggestions
/// Author: Pown Kumar - Founder of Korelium
/// Date: September 18, 2025

class AddTransactionScreen extends StatefulWidget {
  final Transaction? transaction;
  final TransactionType? initialType;

  const AddTransactionScreen({super.key, this.transaction, this.initialType});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  
  String? _selectedAccountId;
  String? _selectedCategoryId;
  String? _selectedSubcategoryId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  TransactionType _selectedType = TransactionType.expense;
  bool _isLoading = false;
  String? _receiptImagePath;

  // Quick amount buttons
  final List<double> _quickAmounts = [100, 500, 1000, 2000, 5000];

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _descriptionController.text = widget.transaction!.description;
      _amountController.text = widget.transaction!.amount.toString();
      _selectedAccountId = widget.transaction!.accountId;
      _selectedCategoryId = widget.transaction!.categoryId;
      _selectedSubcategoryId = widget.transaction!.subcategoryId; // Fix: Set subcategory ID
      _selectedDate = widget.transaction!.date;
      _selectedTime = TimeOfDay.fromDateTime(widget.transaction!.date);
      _selectedType = widget.transaction!.type;
      _receiptImagePath = widget.transaction!.receiptImagePath; // Load receipt image
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

  /// Show delete confirmation dialog
  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
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

    if (result == true && widget.transaction != null) {
      try {
        setState(() => _isLoading = true);
        final transactionProvider = Provider.of<TransactionProviderHive>(context, listen: false);
        await transactionProvider.deleteTransaction(widget.transaction!.id);
        
        if (mounted) {
          Navigator.pop(context, 'deleted');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaction deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting transaction: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// Pick image from camera or gallery
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      
      // Show image source selection
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source != null) {
        final XFile? image = await picker.pickImage(source: source);
        if (image != null) {
          // Save image to app directory
          final appDir = await getApplicationDocumentsDirectory();
          final receiptDir = Directory('${appDir.path}/receipts');
          if (!await receiptDir.exists()) {
            await receiptDir.create(recursive: true);
          }
          
          final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
          final filePath = '${receiptDir.path}/$fileName';
          await image.saveTo(filePath);
          
          setState(() {
            _receiptImagePath = filePath;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Remove receipt image
  void _removeImage() {
    setState(() {
      _receiptImagePath = null;
    });
  }

  /// Show time picker
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
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
          if (widget.transaction != null) // Show delete button when editing
            IconButton(
              onPressed: () => _showDeleteConfirmation(context),
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
      body: _isLoading
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
                        _buildTransactionTypeToggle(),
                        const SizedBox(height: 24),

                        // 1. Amount Input with Quick Buttons (FIRST)
                        _buildAmountSection(transactionProvider),
                        const SizedBox(height: 24),

                        // 2. Account Selector with Balance (SECOND)
                        _buildAccountSelector(transactionProvider),
                        const SizedBox(height: 24),

                        // 3. Title Input
                        _buildTitleInput(),
                        const SizedBox(height: 24),

                        // 4. Category Selector
                        _buildCategorySelector(transactionProvider),
                        
        // 5. Subcategory Selection (if category has subcategories)
        if (_selectedCategoryId != null) ...[
          const SizedBox(height: 12),
          _buildSubcategorySelector(transactionProvider),
          
          // Add Subcategory Button (ALWAYS VISIBLE for better UX)
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Need a specific subcategory?',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final parentCategory = transactionProvider.getCategory(_selectedCategoryId!);
                  if (parentCategory != null) {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddCategoryScreen(
                          parentCategory: parentCategory,
                        ),
                      ),
                    );
                    if (result == true) {
                      setState(() {}); // Refresh subcategories
                    }
                  }
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Subcategory'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
        ],
                        
                        const SizedBox(height: 24),

                        // Date Picker
                        _buildDatePicker(),
                        const SizedBox(height: 24),

                        // 6. Notes Input
                        _buildNotesInput(),
                        const SizedBox(height: 24),

                        // 7. Receipt Image
                        _buildReceiptImageSection(),
                        const SizedBox(height: 32),

                        // Save Button
                        _buildSaveButton(transactionProvider),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildTransactionTypeToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transaction Type',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _selectedType = TransactionType.expense;
                    _selectedCategoryId = null;
                    _selectedSubcategoryId = null;
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: _selectedType == TransactionType.expense
                          ? Colors.red
                          : Colors.transparent,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.trending_down,
                          color: _selectedType == TransactionType.expense
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Expense',
                          style: TextStyle(
                            color: _selectedType == TransactionType.expense
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _selectedType = TransactionType.income;
                    _selectedCategoryId = null;
                    _selectedSubcategoryId = null;
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: _selectedType == TransactionType.income
                          ? Colors.green
                          : Colors.transparent,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.trending_up,
                          color: _selectedType == TransactionType.income
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Income',
                          style: TextStyle(
                            color: _selectedType == TransactionType.income
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface,
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
        ),
      ],
    );
  }

  Widget _buildAccountSelector(TransactionProviderHive transactionProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        // Validate that the selected account exists in the list
        Builder(
          builder: (context) {
            final validAccountId = _selectedAccountId != null && 
                transactionProvider.accounts.any((a) => a.id == _selectedAccountId) 
                ? _selectedAccountId 
                : null;
            
            return DropdownButtonFormField<String>(
              value: validAccountId,
              isExpanded: true,
          menuMaxHeight: 300,
          decoration: InputDecoration(
            labelText: 'Select Account',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.account_balance_wallet),
          ),
          items: transactionProvider.accounts.map((account) {
            return DropdownMenuItem(
              value: account.id,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    account.type.toString() == 'AccountType.bank'
                        ? Icons.account_balance
                        : Icons.money,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '${account.name} - ₹${account.balance.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: account.balance >= 0 ? Colors.black87 : Colors.red,
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
              _selectedAccountId = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select an account';
            }
            return null;
          },
        );
          },
        ),
      ],
    );
  }

  Widget _buildAmountSection(TransactionProviderHive transactionProvider) {
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
        
        // Amount Input
        TextFormField(
          controller: _amountController,
          decoration: InputDecoration(
            hintText: '0.00',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.currency_rupee),
            suffixText: 'INR',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (value) {
            setState(() {
              // Trigger rebuild to update balance warning
            });
          },
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
        
                        // Quick Amount Buttons
                        Text(
                          'Quick Amounts',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 40,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _quickAmounts.length,
                            itemBuilder: (context, index) {
                              final amount = _quickAmounts[index];
                              return Container(
                                margin: const EdgeInsets.only(right: 8),
                                child: GestureDetector(
                                  onTap: () {
                                    _amountController.text = amount.toString();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surfaceContainer,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Text(
                                      '₹${amount.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurface,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
        
        // Balance Warning - HIDDEN FOR NOW (logic needs fixing)
        // if (_selectedAccountId != null) ...[
        //   const SizedBox(height: 12),
        //   _buildBalanceWarning(transactionProvider),
        // ],
      ],
    );
  }

  Widget _buildBalanceWarning(TransactionProviderHive transactionProvider) {
    final account = transactionProvider.accounts
        .where((a) => a.id == _selectedAccountId)
        .firstOrNull;
    
    if (account == null) {
      return const SizedBox(height: 0);
    }
    
    final amount = double.tryParse(_amountController.text) ?? 0;
    final newBalance = account.balance + (_selectedType == TransactionType.income ? amount : -amount);
    
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: newBalance < 0 
            ? Colors.red.withValues(alpha: 0.1)
            : Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: newBalance < 0 
              ? Colors.red.withValues(alpha: 0.3)
              : Colors.green.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            newBalance < 0 ? Icons.warning : Icons.check_circle,
            color: newBalance < 0 ? Colors.red : Colors.green,
            size: 20,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'New Balance: ₹${newBalance.toStringAsFixed(2)}',
              style: TextStyle(
                color: newBalance < 0 ? Colors.red : Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector(TransactionProviderHive transactionProvider) {
    final mainCategories = transactionProvider.getMainCategories(
      _selectedType == TransactionType.income 
          ? app_category.CategoryType.income 
          : app_category.CategoryType.expense,
    );
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Category',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddCategoryScreen(
                      parentCategory: null,
                    ),
                  ),
                );
                if (result == true) {
                  setState(() {}); // Refresh categories
                }
              },
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Category'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Main Category Dropdown
        // Validate that the selected category exists in the list
        Builder(
          builder: (context) {
            final validCategoryId = _selectedCategoryId != null && 
                mainCategories.any((c) => c.id == _selectedCategoryId) 
                ? _selectedCategoryId 
                : null;
            
            return DropdownButtonFormField<String>(
              value: validCategoryId,
              isExpanded: true,
          menuMaxHeight: 300,
          decoration: InputDecoration(
            labelText: 'Select Category',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: validCategoryId != null
                ? Icon(
                    transactionProvider.getCategory(validCategoryId!)?.iconData,
                    color: transactionProvider.getCategory(validCategoryId!)?.colorData,
                  )
                : const Icon(Icons.category),
          ),
          items: mainCategories.map((category) {
            return DropdownMenuItem(
              value: category.id,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    category.iconData,
                    color: category.colorData,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      category.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategoryId = value;
              _selectedSubcategoryId = null;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a category';
            }
            return null;
          },
        );
          },
        ),
      ],
    );
  }

  Widget _buildSubcategorySelector(TransactionProviderHive transactionProvider) {
    final subcategories = transactionProvider.getSubcategories(_selectedCategoryId!);
    
    if (subcategories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'No subcategories yet. Create your first one below!',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    // Validate that the selected subcategory exists in the list
    final validSubcategoryId = _selectedSubcategoryId != null && 
        subcategories.any((s) => s.id == _selectedSubcategoryId) 
        ? _selectedSubcategoryId 
        : null;
    
    return DropdownButtonFormField<String>(
      value: validSubcategoryId,
      isExpanded: true,
      menuMaxHeight: 300,
        decoration: InputDecoration(
          labelText: 'Subcategory (Optional)',
          hintText: 'Choose existing or create new below',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          prefixIcon: validSubcategoryId != null
              ? Icon(
                  transactionProvider.getCategory(validSubcategoryId!)?.iconData,
                  color: transactionProvider.getCategory(validSubcategoryId!)?.colorData,
                )
              : const Icon(Icons.subdirectory_arrow_right),
        ),
        items: subcategories.map((subcategory) {
          return DropdownMenuItem(
            value: subcategory.id,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  subcategory.iconData,
                  color: subcategory.colorData,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    subcategory.name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedSubcategoryId = value;
          });
        },
        validator: (value) {
          // Subcategory is optional
          return null;
        },
      );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date & Time',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Date Picker
            Expanded(
              child: GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Time Picker
            Expanded(
              child: GestureDetector(
                onTap: _selectTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedTime.format(context),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
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
          controller: _descriptionController,
          decoration: InputDecoration(
            hintText: 'Enter transaction title (optional)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.title),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Add notes (optional)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.note),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(TransactionProviderHive transactionProvider) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : () => _saveTransaction(transactionProvider),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Text(
          widget.transaction == null ? 'Add Transaction' : 'Update Transaction',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveTransaction(TransactionProviderHive transactionProvider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Combine date and time
      final combinedDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final transaction = Transaction(
        id: widget.transaction?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        accountId: _selectedAccountId!,
        categoryId: _selectedCategoryId!,
        subcategoryId: _selectedSubcategoryId,
        amount: double.parse(_amountController.text),
        description: _descriptionController.text.trim(),
        date: combinedDateTime,
        type: _selectedType,
        receiptImagePath: _receiptImagePath,
      );

      if (widget.transaction == null) {
        await transactionProvider.addTransaction(transaction);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_selectedType == TransactionType.income ? 'Income' : 'Expense'} added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await transactionProvider.updateTransaction(transaction);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_selectedType == TransactionType.income ? 'Income' : 'Expense'} updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Build receipt image section
  Widget _buildReceiptImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Receipt Image (Optional)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        if (_receiptImagePath != null) ...[
          // Show selected image
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Image.file(
                    File(_receiptImagePath!),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: _removeImage,
                        icon: const Icon(Icons.close, color: Colors.white),
                        iconSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        
        // Add/Change image button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _pickImage,
            icon: Icon(_receiptImagePath != null ? Icons.change_circle : Icons.add_photo_alternate),
            label: Text(_receiptImagePath != null ? 'Change Receipt' : 'Add Receipt Photo'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
