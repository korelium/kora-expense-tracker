// File location: lib/presentation/widgets/transaction_card.dart
// Purpose: Enhanced transaction card widget with all details
// Author: Pown Kumar - Founder of Korelium
// Date: September 18, 2025

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/transaction.dart';
import '../../data/models/category.dart' as app_category;
import '../../data/providers/transaction_provider_hive.dart';
import '../../data/providers/currency_provider.dart';

/// Enhanced Transaction Card Widget
/// Displays all transaction details in a beautiful, organized layout
class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row: Icon, Amount, Type
                Row(
                  children: [
                    // Transaction Icon with Category Color
                    Consumer<TransactionProviderHive>(
                      builder: (context, provider, child) {
                        final category = provider.getCategory(transaction.categoryId);
                        return Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _getCategoryColor(category).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getCategoryColor(category).withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            _getCategoryIcon(category),
                            color: _getCategoryColor(category),
                            size: 24,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    
                    // Title and Description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.description,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(transaction.date),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Amount and Type
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Consumer<CurrencyProvider>(
                          builder: (context, currencyProvider, child) {
                            return Text(
                              currencyProvider.formatAmount(transaction.amount),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: isIncome ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                              ),
                            );
                          },
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isIncome 
                                ? const Color(0xFF22C55E).withValues(alpha: 0.1)
                                : const Color(0xFFEF4444).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isIncome ? 'Income' : 'Expense',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isIncome ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Details Row: Account, Category, Subcategory
                Row(
                  children: [
                    // Account Info
                    Expanded(
                      child: _buildDetailChip(
                        icon: Icons.account_balance,
                        label: 'Account',
                        value: _getAccountName(context),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    
                    // Category Info
                    Expanded(
                      child: _buildDetailChip(
                        icon: Icons.category,
                        label: 'Category',
                        value: _getCategoryName(context),
                        color: const Color(0xFF8B5CF6),
                      ),
                    ),
                  ],
                ),
                
                // Subcategory Row (if exists)
                if (transaction.subcategoryId != null) ...[
                  const SizedBox(height: 8),
                  _buildDetailChip(
                    icon: Icons.subdirectory_arrow_right,
                    label: 'Subcategory',
                    value: _getSubcategoryName(context),
                    color: const Color(0xFF06B6D4),
                    isFullWidth: true,
                  ),
                ],
                
                // Notes Row (if exists)
                if (transaction.description.isNotEmpty && transaction.description != transaction.description) ...[
                  const SizedBox(height: 8),
                  _buildDetailChip(
                    icon: Icons.note,
                    label: 'Notes',
                    value: transaction.description,
                    color: const Color(0xFFF59E0B),
                    isFullWidth: true,
                    maxLines: 2,
                  ),
                ],
                
                // Footer Row: Receipt Icon, Actions
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Receipt Image Indicator
                    if (transaction.receiptImagePath != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF10B981).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.receipt,
                              size: 14,
                              color: const Color(0xFF10B981),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Receipt',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    const Spacer(),
                    
                    // Action Buttons
                    if (onEdit != null || onDelete != null)
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        onSelected: (value) {
                          if (value == 'edit' && onEdit != null) {
                            onEdit!();
                          } else if (value == 'delete' && onDelete != null) {
                            onDelete!();
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          if (onEdit != null)
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                          if (onDelete != null)
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Delete'),
                                ],
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build detail chip for account, category, etc.
  Widget _buildDetailChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isFullWidth = false,
    int maxLines = 1,
  }) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: color.withValues(alpha: 0.8),
                  ),
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Get account name from provider
  String _getAccountName(BuildContext context) {
    final provider = Provider.of<TransactionProviderHive>(context, listen: false);
    final account = provider.getAccount(transaction.accountId);
    return account?.name ?? 'Unknown Account';
  }

  /// Get category name from provider
  String _getCategoryName(BuildContext context) {
    final provider = Provider.of<TransactionProviderHive>(context, listen: false);
    final category = provider.getCategory(transaction.categoryId);
    return category?.name ?? 'Unknown Category';
  }

  /// Get subcategory name from provider
  String _getSubcategoryName(BuildContext context) {
    final provider = Provider.of<TransactionProviderHive>(context, listen: false);
    final subcategory = provider.getCategory(transaction.subcategoryId!);
    return subcategory?.name ?? 'Unknown Subcategory';
  }

  /// Get category color
  Color _getCategoryColor(app_category.Category? category) {
    if (category == null) return const Color(0xFF6B7280);
    
    try {
      return Color(int.parse((category.color ?? '#6B7280').replaceAll('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF6B7280);
    }
  }

  /// Get category icon
  IconData _getCategoryIcon(app_category.Category? category) {
    if (category == null) return Icons.category;
    
    // Map of icon strings to IconData
    const iconMap = {
      'food': Icons.restaurant,
      'transport': Icons.directions_car,
      'shopping': Icons.shopping_bag,
      'entertainment': Icons.movie,
      'health': Icons.health_and_safety,
      'education': Icons.school,
      'utilities': Icons.electrical_services,
      'salary': Icons.work,
      'freelance': Icons.computer,
      'investment': Icons.trending_up,
      'gift': Icons.card_giftcard,
      'other': Icons.category,
    };
    
    return iconMap[category.icon] ?? Icons.category;
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);
    
    if (transactionDate == today) {
      return 'Today ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (transactionDate == yesterday) {
      return 'Yesterday ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }
}
