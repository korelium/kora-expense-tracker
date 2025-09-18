// File location: lib/data/providers/transaction_provider.dart
// Purpose: State management for transactions, accounts, and categories using Provider
// Author: Pown Kumar - Founder of Korelium
// Date: September 18, 2025

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

import '../models/transaction.dart';
import '../models/account.dart';
import '../models/category.dart' as app_category;

/// Provider for managing transactions, accounts, and categories
/// Uses SharedPreferences for data persistence
class TransactionProvider with ChangeNotifier {
  // ===== PRIVATE FIELDS =====
  List<Transaction> _transactions = [];
  List<Account> _accounts = [];
  List<app_category.Category> _categories = [];
  final Uuid _uuid = const Uuid();

  // ===== GETTERS =====
  /// List of all transactions
  List<Transaction> get transactions => List.unmodifiable(_transactions);
  
  /// List of all accounts
  List<Account> get accounts => List.unmodifiable(_accounts);
  
  /// List of all categories
  List<app_category.Category> get categories => List.unmodifiable(_categories);

  /// Total balance across all accounts
  /// Assets (bank, cash, investment) are added
  /// Liabilities (credit card, loans) are subtracted
  double get totalBalance {
    return _accounts.fold(0.0, (sum, account) {
      if (account.isLiability) {
        return sum - account.balance; // Subtract debt from total
      } else {
        return sum + account.balance; // Add asset balances
      }
    });
  }

  /// Total income from all income transactions
  double get totalIncome {
    return _transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Total expenses from all expense transactions
  double get totalExpense {
    return _transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Net worth (total income - total expenses)
  double get netWorth => totalIncome - totalExpense;

  /// Savings rate as percentage (savings / income * 100)
  double get savingsRate {
    if (totalIncome == 0) return 0.0;
    final savings = totalIncome - totalExpense;
    return savings > 0 ? (savings / totalIncome) * 100 : 0.0;
  }

  // ===== CONSTRUCTOR =====
  TransactionProvider() {
    _loadData();
  }

  // ===== DATA LOADING =====
  /// Load all data from SharedPreferences
  Future<void> _loadData() async {
    await _loadTransactions();
    await _loadAccounts();
    await _loadCategories();
  }

  /// Load transactions from SharedPreferences
  Future<void> _loadTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? transactionsJson = prefs.getString('transactions');
      
      if (transactionsJson != null) {
        final List<dynamic> decoded = json.decode(transactionsJson);
        _transactions = decoded.map((json) => Transaction.fromJson(json)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading transactions: $e');
      }
      _transactions = []; // Reset to empty list on error
    }
  }

  /// Load accounts from SharedPreferences
  Future<void> _loadAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? accountsJson = prefs.getString('accounts');
      
      if (accountsJson != null) {
        final List<dynamic> decoded = json.decode(accountsJson);
        _accounts = decoded.map((json) => Account.fromJson(json)).toList();
      } else {
        // Start with empty accounts list - user will create their own
        _accounts = [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading accounts: $e');
      }
      _accounts = []; // Start with empty accounts list on error
    }
  }

  /// Load categories from SharedPreferences
  Future<void> _loadCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? categoriesJson = prefs.getString('categories');
      
      if (categoriesJson != null) {
        final List<dynamic> decoded = json.decode(categoriesJson);
        _categories = decoded.map((json) => app_category.Category.fromJson(json)).toList();
      } else {
        // Create default categories if none exist
        _createDefaultCategories();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading categories: $e');
      }
      _createDefaultCategories(); // Create defaults on error
    }
  }

  // ===== DATA PERSISTENCE =====
  /// Save transactions to SharedPreferences
  Future<void> _saveTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = json.encode(_transactions.map((t) => t.toJson()).toList());
      await prefs.setString('transactions', encoded);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving transactions: $e');
      }
    }
  }

  /// Save accounts to SharedPreferences
  Future<void> _saveAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = json.encode(_accounts.map((a) => a.toJson()).toList());
      await prefs.setString('accounts', encoded);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving accounts: $e');
      }
    }
  }

  /// Save categories to SharedPreferences
  Future<void> _saveCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = json.encode(_categories.map((c) => c.toJson()).toList());
      await prefs.setString('categories', encoded);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving categories: $e');
      }
    }
  }

  // ===== TRANSACTION METHODS =====
  /// Add a new transaction
  /// Updates account balance automatically based on transaction type and account type
  Future<void> addTransaction(Transaction transaction) async {
    _transactions.add(transaction);
    
    // Update account balance based on transaction type and account type
    await _updateAccountBalance(transaction);
    
    await _saveTransactions();
    notifyListeners();
  }

  /// Update an existing transaction
  Future<void> updateTransaction(Transaction updatedTransaction) async {
    final index = _transactions.indexWhere((t) => t.id == updatedTransaction.id);
    if (index != -1) {
      _transactions[index] = updatedTransaction;
      await _saveTransactions();
      notifyListeners();
    }
  }

  /// Delete a transaction
  Future<void> deleteTransaction(String transactionId) async {
    _transactions.removeWhere((t) => t.id == transactionId);
    await _saveTransactions();
    notifyListeners();
  }

  // ===== ACCOUNT METHODS =====
  /// Add a new account
  Future<void> addAccount(Account account) async {
    _accounts.add(account);
    await _saveAccounts();
    notifyListeners();
  }

  /// Update an existing account
  Future<void> updateAccount(Account updatedAccount) async {
    final index = _accounts.indexWhere((a) => a.id == updatedAccount.id);
    if (index != -1) {
      _accounts[index] = updatedAccount;
      await _saveAccounts();
      notifyListeners();
    }
  }

  /// Delete an account
  Future<void> deleteAccount(String accountId) async {
    // Don't allow deletion if account has transactions
    final hasTransactions = _transactions.any((t) => t.accountId == accountId);
    if (hasTransactions) {
      throw Exception('Cannot delete account with existing transactions');
    }
    
    _accounts.removeWhere((a) => a.id == accountId);
    await _saveAccounts();
    notifyListeners();
  }

  // ===== CATEGORY METHODS =====
  /// Add a new category
  Future<void> addCategory(app_category.Category category) async {
    _categories.add(category);
    await _saveCategories();
    notifyListeners();
  }

  /// Update an existing category
  Future<void> updateCategory(app_category.Category updatedCategory) async {
    final index = _categories.indexWhere((c) => c.id == updatedCategory.id);
    if (index != -1) {
      _categories[index] = updatedCategory;
      await _saveCategories();
      notifyListeners();
    }
  }

  /// Delete a category
  Future<void> deleteCategory(String categoryId) async {
    // Don't allow deletion if category has transactions
    final hasTransactions = _transactions.any((t) => t.categoryId == categoryId);
    if (hasTransactions) {
      throw Exception('Cannot delete category with existing transactions');
    }
    
    _categories.removeWhere((c) => c.id == categoryId);
    await _saveCategories();
    notifyListeners();
  }

  // ===== HELPER METHODS =====
  /// Update account balance based on transaction
  /// Handles both asset and liability account logic
  Future<void> _updateAccountBalance(Transaction transaction) async {
    final accountIndex = _accounts.indexWhere((account) => account.id == transaction.accountId);
    if (accountIndex == -1) return;

    final account = _accounts[accountIndex];
    double newBalance = account.balance;

    if (account.isLiability) {
      // Liability accounts (credit cards, loans)
      if (transaction.type == TransactionType.income) {
        // Income reduces liability (paying off debt)
        newBalance -= transaction.amount;
      } else {
        // Expense increases liability (adding to debt)
        newBalance += transaction.amount;
      }
    } else {
      // Asset accounts (bank, cash, investment)
      if (transaction.type == TransactionType.income) {
        // Income increases asset balance
        newBalance += transaction.amount;
      } else {
        // Expense decreases asset balance
        newBalance -= transaction.amount;
      }
    }

    _accounts[accountIndex] = account.copyWith(balance: newBalance);
    await _saveAccounts();
  }


  /// Create default categories for new users
  void _createDefaultCategories() {
    _categories = [
      // Income categories
      app_category.Category(
        id: _uuid.v4(),
        name: 'Salary',
        icon: Icons.work.codePoint.toString(),
        type: app_category.CategoryType.income,
        color: Colors.green.value.toRadixString(16),
      ),
      app_category.Category(
        id: _uuid.v4(),
        name: 'Freelance',
        icon: Icons.computer.codePoint.toString(),
        type: app_category.CategoryType.income,
        color: Colors.blue.value.toRadixString(16),
      ),
      
      // Expense categories
      app_category.Category(
        id: _uuid.v4(),
        name: 'Food & Dining',
        icon: Icons.restaurant.codePoint.toString(),
        type: app_category.CategoryType.expense,
        color: Colors.orange.value.toRadixString(16),
      ),
      app_category.Category(
        id: _uuid.v4(),
        name: 'Transportation',
        icon: Icons.directions_car.codePoint.toString(),
        type: app_category.CategoryType.expense,
        color: Colors.red.value.toRadixString(16),
      ),
      app_category.Category(
        id: _uuid.v4(),
        name: 'Shopping',
        icon: Icons.shopping_bag.codePoint.toString(),
        type: app_category.CategoryType.expense,
        color: Colors.purple.value.toRadixString(16),
      ),
      app_category.Category(
        id: _uuid.v4(),
        name: 'Entertainment',
        icon: Icons.movie.codePoint.toString(),
        type: app_category.CategoryType.expense,
        color: Colors.pink.value.toRadixString(16),
      ),
      app_category.Category(
        id: _uuid.v4(),
        name: 'Utilities',
        icon: Icons.build.codePoint.toString(),
        type: app_category.CategoryType.expense,
        color: Colors.teal.value.toRadixString(16),
      ),
    ];
    _saveCategories();
  }

  /// Get transactions for a specific account
  List<Transaction> getTransactionsForAccount(String accountId) {
    return _transactions.where((t) => t.accountId == accountId).toList();
  }

  /// Get transactions for a specific category
  List<Transaction> getTransactionsForCategory(String categoryId) {
    return _transactions.where((t) => t.categoryId == categoryId).toList();
  }

  /// Get transactions within a date range
  List<Transaction> getTransactionsInDateRange(DateTime start, DateTime end) {
    return _transactions.where((t) => t.date.isAfter(start) && t.date.isBefore(end)).toList();
  }

  /// Get recent transactions (last N days)
  List<Transaction> getRecentTransactions(int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _transactions.where((t) => t.date.isAfter(cutoffDate)).toList();
  }
}
