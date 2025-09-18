// File location: lib/presentation/screens/transactions/expense_list_screen.dart
// Purpose: Transactions list screen with search, filter, and transaction management
// Author: Pown Kumar - Founder of Korelium
// Date: September 18, 2025

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/transaction_provider_hive.dart';
import '../../../data/providers/currency_provider.dart';
import '../../../data/models/transaction.dart';
import '../../widgets/transaction_card.dart';
import 'add_expense_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  String _searchQuery = '';

  final List<String> _filterOptions = [
    'All',
    'Income',
    'Expense',
    'Today',
    'This Week',
    'This Month',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Transaction> _filterTransactions(List<Transaction> transactions) {
    // Create a mutable copy of the transactions list
    var filtered = List<Transaction>.from(transactions);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((transaction) =>
          transaction.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          transaction.amount.toString().contains(_searchQuery)).toList();
    }

    // Apply time/type filter
    final now = DateTime.now();
    switch (_selectedFilter) {
      case 'Today':
        filtered = filtered.where((transaction) =>
            transaction.date.year == now.year &&
            transaction.date.month == now.month &&
            transaction.date.day == now.day).toList();
        break;
      case 'This Week':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        filtered = filtered.where((transaction) =>
            transaction.date.isAfter(weekStart) &&
            transaction.date.isBefore(now.add(const Duration(days: 1)))).toList();
        break;
      case 'This Month':
        filtered = filtered.where((transaction) =>
            transaction.date.year == now.year &&
            transaction.date.month == now.month).toList();
        break;
      case 'Income':
        filtered = filtered.where((transaction) =>
            transaction.type == TransactionType.income).toList();
        break;
      case 'Expense':
        filtered = filtered.where((transaction) =>
            transaction.type == TransactionType.expense).toList();
        break;
    }

    // Sort by date (most recent first) - now safe to sort since it's a mutable copy
    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddExpenseScreen(),
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search transactions...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                // Filter Chips
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filterOptions.length,
                    itemBuilder: (context, index) {
                      final option = _filterOptions[index];
                      final isSelected = _selectedFilter == option;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(option),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = option;
                            });
                          },
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                          checkmarkColor: Theme.of(context).colorScheme.primary,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Consumer2<TransactionProviderHive, CurrencyProvider>(
        builder: (context, transactionProvider, currencyProvider, child) {
          final filteredTransactions = _filterTransactions(transactionProvider.transactions);
            
          if (filteredTransactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _searchQuery.isNotEmpty || _selectedFilter != 'All' 
                        ? Icons.search_off 
                        : Icons.receipt_long,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isNotEmpty || _selectedFilter != 'All'
                        ? 'No transactions found'
                        : 'No transactions yet',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _searchQuery.isNotEmpty || _selectedFilter != 'All'
                        ? 'Try adjusting your search or filter'
                        : 'Add some transactions to get started!',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Summary Card - Enhanced for Dark Theme
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.surfaceContainer,
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem(context, 'Total', currencyProvider.formatAmount(
                      filteredTransactions.fold(0.0, (sum, transaction) => sum + transaction.amount)
                    )),
                    _buildSummaryItem(context, 'Count', filteredTransactions.length.toString()),
                  ],
                ),
              ),
              // Transactions List
              Expanded(
                child: ListView.builder(
                  itemCount: filteredTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = filteredTransactions[index];
                    return TransactionCard(
                      transaction: transaction,
                      onTap: () => _editTransaction(context, transaction),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
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
      // Refresh the list if needed
      setState(() {});
    }
  }

  /// Show delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context, Transaction transaction) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Transaction'),
          content: Text(
            'Are you sure you want to delete "${transaction.description}"?\n\nThis action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteTransaction(context, transaction);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  /// Delete transaction and show confirmation
  void _deleteTransaction(BuildContext context, Transaction transaction) {
    final transactionProvider = context.read<TransactionProviderHive>();
    
    transactionProvider.deleteTransaction(transaction.id).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transaction "${transaction.description}" deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting transaction: $error'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }
}