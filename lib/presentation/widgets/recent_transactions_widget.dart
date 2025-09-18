// File location: lib/presentation/widgets/recent_transactions_widget.dart
// Purpose: Recent transactions widget for home screen with edit/delete operations
// Author: Pown Kumar - Founder of Korelium
// Date: September 18, 2025

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/transaction.dart';
import '../../data/models/category.dart' as app_category;
import '../../data/providers/transaction_provider_hive.dart';
import '../../data/providers/currency_provider.dart';
import '../screens/transactions/add_expense_screen.dart';

/// Recent Transactions Widget for Home Screen
/// Shows last 5 transactions with edit/delete operations
class RecentTransactionsWidget extends StatelessWidget {
  final List<Transaction> transactions;
  final VoidCallback? onViewAll;

  const RecentTransactionsWidget({
    super.key,
    required this.transactions,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    // Sort transactions by date (newest first) and take first 5
    final sortedTransactions = List<Transaction>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    final recentTransactions = sortedTransactions.take(5).toList();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with View All button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View All',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Transactions List
          if (recentTransactions.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                ),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No transactions yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add your first transaction to get started',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: recentTransactions.map((transaction) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: _buildCompactTransactionCard(context, transaction),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  /// Build compact transaction card for home screen
  Widget _buildCompactTransactionCard(BuildContext context, Transaction transaction) {
    final isIncome = transaction.type == TransactionType.income;
    
    return Container(
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
          onTap: () => _editTransaction(context, transaction),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Category Icon
                Consumer<TransactionProviderHive>(
                  builder: (context, provider, child) {
                    final category = provider.getCategory(transaction.categoryId);
                    return Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(category).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getCategoryIcon(category),
                        color: _getCategoryColor(category),
                        size: 18,
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
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 2),
                      
                      // Category and Date
                      Row(
                        children: [
                          Text(
                            _getCategoryName(context, transaction),
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (transaction.subcategoryId != null) ...[
                            Text(
                              ' • ${_getSubcategoryName(context, transaction)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                          Text(
                            ' • ${_formatDate(transaction.date)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      
                      // Account and Notes (if available)
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            _getAccountName(context, transaction),
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          if (_hasNotes(transaction)) ...[
                            Text(
                              ' • ${_getNotes(transaction)}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Amount and Actions
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
                            fontSize: 14,
                            color: isIncome ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Image Icon (if receipt exists)
                    if (transaction.receiptImagePath != null)
                      GestureDetector(
                        onTap: () => _showImagePreview(context, transaction),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.image,
                            size: 14,
                            color: Color(0xFF10B981),
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

  /// Edit transaction
  Future<void> _editTransaction(BuildContext context, Transaction transaction) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(
          expense: transaction,
        ),
      ),
    );
    
    if (result == true) {
      // Transaction was updated, no need to refresh here as provider will notify
    }
  }


  /// Show image preview dialog
  void _showImagePreview(BuildContext context, Transaction transaction) {
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


  /// Get category name from provider
  String _getCategoryName(BuildContext context, Transaction transaction) {
    final provider = Provider.of<TransactionProviderHive>(context, listen: false);
    final category = provider.getCategory(transaction.categoryId);
    return category?.name ?? 'Unknown Category';
  }

  /// Get subcategory name from provider
  String _getSubcategoryName(BuildContext context, Transaction transaction) {
    final provider = Provider.of<TransactionProviderHive>(context, listen: false);
    final subcategory = provider.getCategory(transaction.subcategoryId!);
    return subcategory?.name ?? 'Unknown Subcategory';
  }

  /// Get account name from provider
  String _getAccountName(BuildContext context, Transaction transaction) {
    final provider = Provider.of<TransactionProviderHive>(context, listen: false);
    final account = provider.getAccount(transaction.accountId);
    return account?.name ?? 'Unknown Account';
  }

  /// Check if transaction has notes
  bool _hasNotes(Transaction transaction) {
    // For now, we'll use the description field as notes
    // In the future, we might have a separate notes field
    return transaction.description.isNotEmpty && 
           transaction.description.length > 50; // Only show if it's long enough to be notes
  }

  /// Get notes from transaction
  String _getNotes(Transaction transaction) {
    // For now, truncate description if it's long
    if (transaction.description.length > 50) {
      return '${transaction.description.substring(0, 47)}...';
    }
    return transaction.description;
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
      return '${date.day}/${date.month} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }
}
