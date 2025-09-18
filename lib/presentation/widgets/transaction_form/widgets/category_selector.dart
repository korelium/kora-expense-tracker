import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/category.dart' as app_category;
import '../../../../data/models/transaction.dart';
import '../../../../data/providers/transaction_provider_hive.dart';
import '../../../screens/categories/add_category_screen.dart';

/// Category Selector Widget
/// Provides category selection with add category option
/// Author: Pown Kumar - Founder of Korelium
/// Date: September 18, 2025

class CategorySelector extends StatelessWidget {
  final String? selectedCategoryId;
  final TransactionType transactionType;
  final ValueChanged<String?> onCategoryChanged;
  final VoidCallback onCategoryAdded;

  const CategorySelector({
    super.key,
    required this.selectedCategoryId,
    required this.transactionType,
    required this.onCategoryChanged,
    required this.onCategoryAdded,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProviderHive>(
      builder: (context, transactionProvider, child) {
        final mainCategories = transactionProvider.getMainCategories(
          transactionType == TransactionType.income 
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
                      onCategoryAdded(); // Refresh categories
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
                final validCategoryId = selectedCategoryId != null && 
                    mainCategories.any((c) => c.id == selectedCategoryId) 
                    ? selectedCategoryId 
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
                            transactionProvider.getCategory(validCategoryId)?.iconData,
                            color: transactionProvider.getCategory(validCategoryId)?.colorData,
                          )
                        : const Icon(Icons.category),
                  ),
                  items: mainCategories.map<DropdownMenuItem<String>>((category) {
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
                    onCategoryChanged(value);
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
      },
    );
  }
}
