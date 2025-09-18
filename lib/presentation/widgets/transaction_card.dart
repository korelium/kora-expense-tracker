// File location: lib/presentation/widgets/transaction_card.dart
// Purpose: Enhanced transaction card widget with all details
// Author: Pown Kumar - Founder of Korelium
// Date: September 18, 2025

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/transaction.dart';
import '../../data/models/category.dart' as app_category;
import '../../data/providers/transaction_provider_hive.dart';
import '../../data/providers/currency_provider.dart';

/// Simple Transaction Card Widget - Inspired by Money Manager
/// Clean, minimal design showing essential transaction details
class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Category Icon
                Consumer<TransactionProviderHive>(
                  builder: (context, provider, child) {
                    final category = provider.getCategory(transaction.categoryId);
                    return Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(category).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getCategoryIcon(category),
                        color: _getCategoryColor(category),
                        size: 20,
                      ),
                    );
                  },
                ),
                
                const SizedBox(width: 12),
                
                // Transaction Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        transaction.description,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 2),
                      
                      // Category and Account
                      Row(
                        children: [
                          Text(
                            _getCategoryName(context),
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          if (transaction.subcategoryId != null) ...[
                            Text(
                              ' • ${_getSubcategoryName(context)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ],
                      ),
                      
                      const SizedBox(height: 2),
                      
                      // Account and Date
                      Row(
                        children: [
                          Text(
                            _getAccountName(context),
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          Text(
                            ' • ${_formatDate(transaction.date)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Amount and Image Icon
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Amount
                    Consumer<CurrencyProvider>(
                      builder: (context, currencyProvider, child) {
                        return Text(
                          currencyProvider.formatAmount(transaction.amount),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isIncome ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Image Icon (if receipt exists)
                    if (transaction.receiptImagePath != null)
                      GestureDetector(
                        onTap: () => _showImagePreview(context),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.image,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
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

  /// Show image preview dialog
  void _showImagePreview(BuildContext context) {
    if (transaction.receiptImagePath == null) return;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Receipt Image',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Image
              Flexible(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 400),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(transaction.receiptImagePath!),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error, size: 48, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Image not found'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
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
