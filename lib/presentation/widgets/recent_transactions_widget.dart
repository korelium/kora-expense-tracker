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
    final isTransfer = transaction.type == TransactionType.transfer;
    
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
                      Consumer<TransactionProviderHive>(
                        builder: (context, transactionProvider, child) {
                          String displayText = transaction.description;
                          
                          // For transfers, show "Transfer from X to Y"
                          if (isTransfer && transaction.fromAccountId != null && transaction.toAccountId != null) {
                            try {
                              final fromAccount = transactionProvider.accounts.firstWhere(
                                (account) => account.id == transaction.fromAccountId,
                                orElse: () => throw Exception('From account not found'),
                              );
                              final toAccount = transactionProvider.accounts.firstWhere(
                                (account) => account.id == transaction.toAccountId,
                                orElse: () => throw Exception('To account not found'),
                              );
                              displayText = 'Transfer from ${fromAccount.name} to ${toAccount.name}';
                            } catch (e) {
                              // If accounts are not found (deleted), show generic transfer text
                              displayText = 'Transfer (Account deleted)';
                            }
                          }
                          
                          return Text(
                            displayText,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),
                      
                      const SizedBox(height: 2),
                      
                      // Category and Date
                      Row(
                        children: [
                          Text(
                            isTransfer ? 'Transfer' : _getCategoryName(context, transaction),
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
                            color: isTransfer 
                                ? const Color(0xFF3B82F6) // Blue for transfers
                                : isIncome 
                                    ? const Color(0xFF22C55E) // Green for income
                                    : const Color(0xFFEF4444), // Red for expenses
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Image Icon (if receipt exists)
                    if (transaction.receiptImagePath != null || transaction.receiptImagePaths.isNotEmpty)
                      GestureDetector(
                        onTap: () => _showImagePreview(context, transaction),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.image,
                                size: 14,
                                color: Color(0xFF10B981),
                              ),
                              if (transaction.receiptImagePaths.length > 1) ...[
                                const SizedBox(width: 2),
                                Text(
                                  '${transaction.receiptImagePaths.length}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF10B981),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ],
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


  /// Show image preview - always use gallery view for consistency
  void _showImagePreview(BuildContext context, Transaction transaction) {
    final List<String> imagePaths = [];
    
    // Add single image path if exists
    if (transaction.receiptImagePath != null) {
      imagePaths.add(transaction.receiptImagePath!);
    }
    
    // Add multiple image paths
    imagePaths.addAll(transaction.receiptImagePaths);
    
    if (imagePaths.isEmpty) return;
    
    // Always use gallery view for consistent experience
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageGalleryScreen(
          imagePaths: imagePaths,
          title: 'Receipt Images',
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
    return transaction.notes != null && transaction.notes!.isNotEmpty;
  }

  /// Get notes from transaction
  String _getNotes(Transaction transaction) {
    if (transaction.notes != null && transaction.notes!.isNotEmpty) {
      if (transaction.notes!.length > 50) {
        return '${transaction.notes!.substring(0, 47)}...';
      }
      return transaction.notes!;
    }
    return '';
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
    if (category == null) return Icons.category_outlined;
    
    // Use the same icon mapping as the Category model
    return category.iconData;
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

/// Image Gallery Screen for viewing multiple images
class ImageGalleryScreen extends StatefulWidget {
  final List<String> imagePaths;
  final String title;

  const ImageGalleryScreen({
    Key? key,
    required this.imagePaths,
    required this.title,
  }) : super(key: key);

  @override
  State<ImageGalleryScreen> createState() => _ImageGalleryScreenState();
}

class _ImageGalleryScreenState extends State<ImageGalleryScreen> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${widget.title} (${_currentIndex + 1}/${widget.imagePaths.length})',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          // Zoom controls
          IconButton(
            onPressed: () => _showZoomInstructions(context),
            icon: const Icon(Icons.zoom_in, color: Colors.white),
            tooltip: 'Zoom Instructions',
          ),
        ],
      ),
      body: Column(
        children: [
          // Image viewer with enhanced zoom
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.imagePaths.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Center(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 5.0,
                    panEnabled: true,
                    boundaryMargin: const EdgeInsets.all(20),
                    constrained: false,
                    child: Image.file(
                      File(widget.imagePaths[index]),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image,
                                color: Colors.white,
                                size: 64,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Failed to load image',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Thumbnail strip (show for single image too for consistency)
          Container(
            height: 80,
            padding: const EdgeInsets.all(8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.imagePaths.length,
              itemBuilder: (context, index) {
                final isSelected = index == _currentIndex;
                return GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.grey,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.file(
                        File(widget.imagePaths[index]),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade800,
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.white,
                              size: 24,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showZoomInstructions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Zoom Instructions',
          style: TextStyle(color: Colors.white),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '• Pinch to zoom in/out',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 8),
            Text(
              '• Drag to pan around',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 8),
            Text(
              '• Double tap to reset zoom',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 8),
            Text(
              '• Swipe left/right to navigate',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Got it',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
