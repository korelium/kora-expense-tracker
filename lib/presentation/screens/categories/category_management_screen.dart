import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/transaction_provider_hive.dart';
import '../../../data/models/category.dart' as app_category;
import 'add_category_screen.dart';

/// Category Management Screen
/// Allows users to view, add, edit, and delete categories
/// Author: Pown Kumar - Founder of Korelium
/// Date: September 18, 2025

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  app_category.CategoryType _selectedType = app_category.CategoryType.expense;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedType = _tabController.index == 0 
              ? app_category.CategoryType.expense 
              : app_category.CategoryType.income;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Manage Categories'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.trending_down),
              text: 'Expenses',
            ),
            Tab(
              icon: Icon(Icons.trending_up),
              text: 'Income',
            ),
          ],
        ),
      ),
      body: Consumer<TransactionProviderHive>(
        builder: (context, transactionProvider, child) {
          final categories = transactionProvider.getCategoriesByType(_selectedType);
          final mainCategories = categories.where((c) => c.isMainCategory).toList();
          
          return TabBarView(
            controller: _tabController,
            children: [
              _buildCategoryList(context, transactionProvider, mainCategories, app_category.CategoryType.expense),
              _buildCategoryList(context, transactionProvider, mainCategories, app_category.CategoryType.income),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryList(
    BuildContext context,
    TransactionProviderHive transactionProvider,
    List<app_category.Category> mainCategories,
    app_category.CategoryType type,
  ) {
    if (mainCategories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Icon(
                type == app_category.CategoryType.expense 
                    ? Icons.trending_down_outlined 
                    : Icons.trending_up_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No ${type.name} Categories',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Create your first ${type.name.toLowerCase()} category',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mainCategories.length,
      itemBuilder: (context, index) {
        final category = mainCategories[index];
        final subcategories = transactionProvider.categories
            .where((c) => c.parentId == category.id)
            .toList();
        
        return _buildCategoryCard(context, transactionProvider, category, subcategories);
      },
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    TransactionProviderHive transactionProvider,
    app_category.Category category,
    List<app_category.Category> subcategories,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surfaceContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: category.colorData.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            category.iconData,
            color: category.colorData,
            size: 24,
          ),
        ),
        title: Text(
          category.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (category.notes != null && category.notes!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                category.notes!,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (category.usageCount > 0) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    size: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Used ${category.usageCount} times',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          onSelected: (value) => _handleMenuAction(context, transactionProvider, category, value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'add_subcategory',
              child: Row(
                children: [
                  Icon(Icons.add),
                  SizedBox(width: 8),
                  Text('Add Subcategory'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        children: subcategories.isEmpty
            ? [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No subcategories yet',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ]
            : subcategories.map((subcategory) => _buildSubcategoryTile(
                context, 
                transactionProvider, 
                subcategory
              )).toList(),
      ),
    );
  }

  Widget _buildSubcategoryTile(
    BuildContext context,
    TransactionProviderHive transactionProvider,
    app_category.Category subcategory,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: subcategory.colorData.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            subcategory.iconData,
            color: subcategory.colorData,
            size: 18,
          ),
        ),
        title: Text(
          subcategory.name,
          style: const TextStyle(fontSize: 14),
        ),
        subtitle: subcategory.notes != null && subcategory.notes!.isNotEmpty
            ? Text(
                subcategory.notes!,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            size: 16,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          onSelected: (value) => _handleMenuAction(context, transactionProvider, subcategory, value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(
    BuildContext context,
    TransactionProviderHive transactionProvider,
    app_category.Category category,
    String action,
  ) {
    switch (action) {
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddCategoryScreen(category: category),
          ),
        );
        break;
      case 'add_subcategory':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddCategoryScreen(parentCategory: category),
          ),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(context, transactionProvider, category);
        break;
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    TransactionProviderHive transactionProvider,
    app_category.Category category,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
          'Are you sure you want to delete "${category.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await transactionProvider.deleteCategory(category.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Category deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error deleting category: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
