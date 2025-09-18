import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/providers/transaction_provider_hive.dart';
import '../../../screens/categories/add_category_screen.dart';

/// Subcategory Selector Widget
/// Provides subcategory selection with add subcategory option
/// Author: Pown Kumar - Founder of Korelium
/// Date: September 18, 2025

class SubcategorySelector extends StatelessWidget {
  final String? selectedCategoryId;
  final String? selectedSubcategoryId;
  final ValueChanged<String?> onSubcategoryChanged;
  final VoidCallback onSubcategoryAdded;

  const SubcategorySelector({
    super.key,
    required this.selectedCategoryId,
    required this.selectedSubcategoryId,
    required this.onSubcategoryChanged,
    required this.onSubcategoryAdded,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedCategoryId == null) {
      return const SizedBox.shrink();
    }

    return Consumer<TransactionProviderHive>(
      builder: (context, transactionProvider, child) {
        final subcategories = transactionProvider.getSubcategories(selectedCategoryId!);
        
        return Column(
          children: [
            // Subcategory Selector
            _buildSubcategoryDropdown(context, transactionProvider, subcategories),
            
            const SizedBox(height: 8),
            
            // Add Subcategory Button (ALWAYS VISIBLE for better UX)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddCategoryScreen(
                            parentCategory: transactionProvider.getCategory(selectedCategoryId!),
                          ),
                        ),
                      );
                      if (result == true) {
                        onSubcategoryAdded(); // Refresh subcategories
                      }
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Subcategory'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSubcategoryDropdown(
    BuildContext context, 
    TransactionProviderHive transactionProvider, 
    List subcategories
  ) {
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
    final validSubcategoryId = selectedSubcategoryId != null && 
        subcategories.any((s) => s.id == selectedSubcategoryId) 
        ? selectedSubcategoryId 
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
                transactionProvider.getCategory(validSubcategoryId)?.iconData,
                color: transactionProvider.getCategory(validSubcategoryId)?.colorData,
              )
            : const Icon(Icons.subdirectory_arrow_right),
      ),
      items: subcategories.map<DropdownMenuItem<String>>((subcategory) {
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
      onChanged: onSubcategoryChanged,
      validator: (value) {
        // Subcategory is optional
        return null;
      },
    );
  }
}
