import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/transaction_provider_hive.dart';
import '../../../data/models/category.dart' as app_category;

/// Add/Edit Category Screen
/// Allows users to create new categories or edit existing ones
/// Supports unlimited categories with subcategories and notes
/// Author: Pown Kumar - Founder of Korelium
/// Date: September 18, 2025

class AddCategoryScreen extends StatefulWidget {
  final app_category.Category? category;
  final app_category.Category? parentCategory;

  const AddCategoryScreen({
    super.key,
    this.category,
    this.parentCategory,
  });

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  
  app_category.CategoryType _selectedType = app_category.CategoryType.expense;
  String _selectedIcon = 'category';
  Color _selectedColor = Colors.grey;
  bool _isLoading = false;

  // Popular icons for categories
  final List<Map<String, dynamic>> _popularIcons = [
    {'icon': 'restaurant', 'label': 'Food'},
    {'icon': 'directions_car', 'label': 'Transport'},
    {'icon': 'shopping_cart', 'label': 'Shopping'},
    {'icon': 'home', 'label': 'Home'},
    {'icon': 'work', 'label': 'Work'},
    {'icon': 'school', 'label': 'Education'},
    {'icon': 'health_and_safety', 'label': 'Health'},
    {'icon': 'movie', 'label': 'Entertainment'},
    {'icon': 'flight', 'label': 'Travel'},
    {'icon': 'fitness_center', 'label': 'Fitness'},
    {'icon': 'pets', 'label': 'Pets'},
    {'icon': 'card_giftcard', 'label': 'Gifts'},
    {'icon': 'savings', 'label': 'Savings'},
    {'icon': 'trending_up', 'label': 'Investment'},
    {'icon': 'account_balance', 'label': 'Banking'},
    {'icon': 'receipt', 'label': 'Bills'},
  ];

  // Popular colors for categories
  final List<Color> _popularColors = [
    Colors.red,
    Colors.orange,
    Colors.amber,
    Colors.green,
    Colors.teal,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    Colors.pink,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _notesController.text = widget.category!.notes ?? '';
      _selectedType = widget.category!.type;
      _selectedIcon = widget.category!.icon;
      _selectedColor = widget.category!.colorData;
    } else if (widget.parentCategory != null) {
      _selectedType = widget.parentCategory!.type;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          widget.category == null 
              ? (widget.parentCategory == null ? 'Add Category' : 'Add Subcategory')
              : 'Edit Category',
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        actions: [
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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Type (only for main categories)
                    if (widget.parentCategory == null) ...[
                      Text(
                        'Category Type',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedType = app_category.CategoryType.expense),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    color: _selectedType == app_category.CategoryType.expense
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.transparent,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      bottomLeft: Radius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.trending_down,
                                        color: _selectedType == app_category.CategoryType.expense
                                            ? Colors.white
                                            : Theme.of(context).colorScheme.onSurface,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Expense',
                                        style: TextStyle(
                                          color: _selectedType == app_category.CategoryType.expense
                                              ? Colors.white
                                              : Theme.of(context).colorScheme.onSurface,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedType = app_category.CategoryType.income),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    color: _selectedType == app_category.CategoryType.income
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.transparent,
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(12),
                                      bottomRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.trending_up,
                                        color: _selectedType == app_category.CategoryType.income
                                            ? Colors.white
                                            : Theme.of(context).colorScheme.onSurface,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Income',
                                        style: TextStyle(
                                          color: _selectedType == app_category.CategoryType.income
                                              ? Colors.white
                                              : Theme.of(context).colorScheme.onSurface,
                                          fontWeight: FontWeight.bold,
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
                      const SizedBox(height: 24),
                    ],

                    // Category Name
                    Text(
                      'Category Name',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'e.g., Groceries, Salary, Entertainment',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
            prefixIcon: Icon(
              _getIconFromString(_selectedIcon),
              color: _selectedColor,
            ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter category name';
                        }
                        if (value.trim().length < 2) {
                          return 'Category name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Icon Selection
                    Text(
                      'Choose Icon',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 1.2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _popularIcons.length,
                        itemBuilder: (context, index) {
                          final iconData = _popularIcons[index];
                          final isSelected = _selectedIcon == iconData['icon'];
                          
                          return GestureDetector(
                            onTap: () => setState(() => _selectedIcon = iconData['icon']),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _selectedColor.withValues(alpha: 0.2)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? _selectedColor
                                      : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _getIconFromString(iconData['icon']),
                                    color: isSelected
                                        ? _selectedColor
                                        : Theme.of(context).colorScheme.onSurface,
                                    size: 20,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    iconData['label'],
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isSelected
                                          ? _selectedColor
                                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Color Selection
                    Text(
                      'Choose Color',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6,
                          childAspectRatio: 1,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _popularColors.length,
                        itemBuilder: (context, index) {
                          final color = _popularColors[index];
                          final isSelected = _selectedColor.value == color.value;
                          
                          return GestureDetector(
                            onTap: () => setState(() => _selectedColor = color),
                            child: Container(
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.white
                                      : color.withValues(alpha: 0.3),
                                  width: isSelected ? 3 : 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: color.withValues(alpha: 0.4),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 20,
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Notes
                    Text(
                      'Notes (Optional)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        hintText: 'Add description or notes about this category',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.note),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveCategory,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          widget.category == null ? 'Create Category' : 'Update Category',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  IconData _getIconFromString(String iconString) {
    // Create a temporary category to use its iconData getter
    final tempCategory = app_category.Category(
      id: 'temp',
      name: 'temp',
      icon: iconString,
      type: app_category.CategoryType.expense,
    );
    
    return tempCategory.iconData;
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final transactionProvider = context.read<TransactionProviderHive>();
      
      final category = app_category.Category(
        id: widget.category?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        icon: _selectedIcon,
        type: _selectedType,
        color: _selectedColor.value.toRadixString(16),
        parentId: widget.parentCategory?.id,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        usageCount: widget.category?.usageCount ?? 0,
        lastUsed: widget.category?.lastUsed,
      );

      if (widget.category == null) {
        await transactionProvider.addCategory(category);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Category created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await transactionProvider.updateCategory(category);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Category updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving category: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
