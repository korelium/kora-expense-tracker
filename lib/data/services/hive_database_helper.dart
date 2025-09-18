// File location: lib/data/services/hive_database_helper.dart
// Purpose: Hive database helper for efficient data storage and retrieval
// Author: Pown Kumar - Founder of Korelium
// Date: September 18, 2025

import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';

import '../models/transaction.dart';
import '../models/account.dart';
import '../models/category.dart' as app_category;

/// Hive database helper class
/// Manages all database operations for transactions, accounts, and categories
/// Provides efficient CRUD operations and data persistence
class HiveDatabaseHelper {
  // ===== SINGLETON PATTERN =====
  static final HiveDatabaseHelper _instance = HiveDatabaseHelper._internal();
  factory HiveDatabaseHelper() => _instance;
  HiveDatabaseHelper._internal();

  // ===== DATABASE BOXES =====
  static const String _transactionsBox = 'transactions_box';
  static const String _accountsBox = 'accounts_box';
  static const String _categoriesBox = 'categories_box';
  static const String _settingsBox = 'settings_box';

  // ===== BOX REFERENCES =====
  late Box<Transaction> _transactionsBoxRef;
  late Box<Account> _accountsBoxRef;
  late Box<app_category.Category> _categoriesBoxRef;
  late Box _settingsBoxRef;

  // ===== INITIALIZATION =====
  /// Initialize Hive database and open all boxes
  Future<void> initialize() async {
    try {
      // Initialize Hive Flutter
      await Hive.initFlutter();

      // Register type adapters
      _registerAdapters();

      // Open all boxes
      await _openBoxes();

      if (kDebugMode) {
        print('✅ Hive database initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing Hive database: $e');
      }
      rethrow;
    }
  }

  /// Register Hive type adapters for custom models
  void _registerAdapters() {
    // Register adapters if not already registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TransactionTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(AccountTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(app_category.CategoryTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(TransactionAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(AccountAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(app_category.CategoryAdapter());
    }
  }

  /// Open all required Hive boxes
  Future<void> _openBoxes() async {
    _transactionsBoxRef = await Hive.openBox<Transaction>(_transactionsBox);
    _accountsBoxRef = await Hive.openBox<Account>(_accountsBox);
    _categoriesBoxRef = await Hive.openBox<app_category.Category>(_categoriesBox);
    _settingsBoxRef = await Hive.openBox(_settingsBox);
    
    // Create default categories if none exist
    await _createDefaultCategories();
  }

  // ===== TRANSACTION OPERATIONS =====
  
  /// Get all transactions
  List<Transaction> getAllTransactions() {
    return _transactionsBoxRef.values.toList();
  }

  /// Get transaction by ID
  Transaction? getTransaction(String id) {
    return _transactionsBoxRef.get(id);
  }

  /// Add new transaction
  Future<void> addTransaction(Transaction transaction) async {
    await _transactionsBoxRef.put(transaction.id, transaction);
  }

  /// Update existing transaction
  Future<void> updateTransaction(Transaction transaction) async {
    await _transactionsBoxRef.put(transaction.id, transaction);
  }

  /// Delete transaction
  Future<void> deleteTransaction(String id) async {
    await _transactionsBoxRef.delete(id);
  }

  /// Get transactions by date range
  List<Transaction> getTransactionsByDateRange(DateTime start, DateTime end) {
    return _transactionsBoxRef.values
        .where((transaction) => 
            transaction.date.isAfter(start.subtract(const Duration(days: 1))) &&
            transaction.date.isBefore(end.add(const Duration(days: 1))))
        .toList();
  }

  /// Get transactions by type
  List<Transaction> getTransactionsByType(TransactionType type) {
    return _transactionsBoxRef.values
        .where((transaction) => transaction.type == type)
        .toList();
  }

  /// Get transactions by account
  List<Transaction> getTransactionsByAccount(String accountId) {
    return _transactionsBoxRef.values
        .where((transaction) => transaction.accountId == accountId)
        .toList();
  }

  /// Get transactions by category
  List<Transaction> getTransactionsByCategory(String categoryId) {
    return _transactionsBoxRef.values
        .where((transaction) => transaction.categoryId == categoryId)
        .toList();
  }

  /// Search transactions by description
  List<Transaction> searchTransactions(String query) {
    final lowerQuery = query.toLowerCase();
    return _transactionsBoxRef.values
        .where((transaction) => 
            transaction.description.toLowerCase().contains(lowerQuery))
        .toList();
  }

  // ===== ACCOUNT OPERATIONS =====
  
  /// Get all accounts
  List<Account> getAllAccounts() {
    return _accountsBoxRef.values.toList();
  }

  /// Get account by ID
  Account? getAccount(String id) {
    return _accountsBoxRef.get(id);
  }

  /// Add new account
  Future<void> addAccount(Account account) async {
    await _accountsBoxRef.put(account.id, account);
  }

  /// Update existing account
  Future<void> updateAccount(Account account) async {
    await _accountsBoxRef.put(account.id, account);
  }

  /// Delete account
  Future<void> deleteAccount(String id) async {
    await _accountsBoxRef.delete(id);
  }

  /// Get accounts by type
  List<Account> getAccountsByType(AccountType type) {
    return _accountsBoxRef.values
        .where((account) => account.type == type)
        .toList();
  }

  /// Get asset accounts (positive balance accounts)
  List<Account> getAssetAccounts() {
    return _accountsBoxRef.values
        .where((account) => !account.isLiability)
        .toList();
  }

  /// Get liability accounts (debt accounts)
  List<Account> getLiabilityAccounts() {
    return _accountsBoxRef.values
        .where((account) => account.isLiability)
        .toList();
  }

  // ===== CATEGORY OPERATIONS =====
  
  /// Get all categories
  List<app_category.Category> getAllCategories() {
    return _categoriesBoxRef.values.toList();
  }

  /// Get category by ID
  app_category.Category? getCategory(String id) {
    return _categoriesBoxRef.get(id);
  }

  /// Add new category
  Future<void> addCategory(app_category.Category category) async {
    await _categoriesBoxRef.put(category.id, category);
  }

  /// Update existing category
  Future<void> updateCategory(app_category.Category category) async {
    await _categoriesBoxRef.put(category.id, category);
  }

  /// Delete category
  Future<void> deleteCategory(String id) async {
    await _categoriesBoxRef.delete(id);
  }

  /// Get categories by type
  List<app_category.Category> getCategoriesByType(app_category.CategoryType type) {
    return _categoriesBoxRef.values
        .where((category) => category.type == type)
        .toList();
  }

  // ===== ANALYTICS & STATISTICS =====
  
  /// Get total balance across all accounts
  double getTotalBalance() {
    return _accountsBoxRef.values.fold(0.0, (sum, account) {
      if (account.isLiability) {
        return sum - account.balance;
      } else {
        return sum + account.balance;
      }
    });
  }

  /// Get total income
  double getTotalIncome() {
    return _transactionsBoxRef.values
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Get total expenses
  double getTotalExpenses() {
    return _transactionsBoxRef.values
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Get monthly statistics
  Map<String, double> getMonthlyStats(int year, int month) {
    final transactions = _transactionsBoxRef.values
        .where((t) => t.date.year == year && t.date.month == month)
        .toList();

    final income = transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);

    final expenses = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    return {
      'income': income,
      'expenses': expenses,
      'savings': income - expenses,
    };
  }

  /// Get category spending breakdown
  Map<String, double> getCategorySpending(TransactionType type) {
    final transactions = _transactionsBoxRef.values
        .where((t) => t.type == type)
        .toList();

    final Map<String, double> spending = {};
    
    for (final transaction in transactions) {
      final categoryId = transaction.categoryId;
      spending[categoryId] = (spending[categoryId] ?? 0.0) + transaction.amount;
    }

    return spending;
  }

  // ===== SETTINGS & PREFERENCES =====
  
  /// Save setting
  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBoxRef.put(key, value);
  }

  /// Get setting
  T? getSetting<T>(String key) {
    return _settingsBoxRef.get(key);
  }

  /// Delete setting
  Future<void> deleteSetting(String key) async {
    await _settingsBoxRef.delete(key);
  }

  // ===== DATABASE MAINTENANCE =====
  
  /// Clear all data (use with caution)
  Future<void> clearAllData() async {
    await _transactionsBoxRef.clear();
    await _accountsBoxRef.clear();
    await _categoriesBoxRef.clear();
    await _settingsBoxRef.clear();
  }

  /// Get database statistics
  Map<String, int> getDatabaseStats() {
    return {
      'transactions': _transactionsBoxRef.length,
      'accounts': _accountsBoxRef.length,
      'categories': _categoriesBoxRef.length,
      'settings': _settingsBoxRef.length,
    };
  }

  /// Export all data as JSON (for backup)
  Map<String, dynamic> exportAllData() {
    return {
      'transactions': _transactionsBoxRef.values.map((t) => t.toJson()).toList(),
      'accounts': _accountsBoxRef.values.map((a) => a.toJson()).toList(),
      'categories': _categoriesBoxRef.values.map((c) => c.toJson()).toList(),
      'settings': _settingsBoxRef.toMap(),
    };
  }

  /// Import data from JSON (for restore)
  Future<void> importData(Map<String, dynamic> data) async {
    // Clear existing data
    await clearAllData();

    // Import transactions
    if (data['transactions'] != null) {
      for (final json in data['transactions']) {
        final transaction = Transaction.fromJson(json);
        await addTransaction(transaction);
      }
    }

    // Import accounts
    if (data['accounts'] != null) {
      for (final json in data['accounts']) {
        final account = Account.fromJson(json);
        await addAccount(account);
      }
    }

    // Import categories
    if (data['categories'] != null) {
      for (final json in data['categories']) {
        final category = app_category.Category.fromJson(json);
        await addCategory(category);
      }
    }

    // Import settings
    if (data['settings'] != null) {
      for (final entry in data['settings'].entries) {
        await saveSetting(entry.key, entry.value);
      }
    }
  }

  // ===== CLEANUP =====
  
  /// Close all database boxes
  Future<void> close() async {
    await _transactionsBoxRef.close();
    await _accountsBoxRef.close();
    await _categoriesBoxRef.close();
    await _settingsBoxRef.close();
  }

  // ===== PRIVATE HELPER METHODS =====
  
  /// Create default categories if none exist
  Future<void> _createDefaultCategories() async {
    if (_categoriesBoxRef.isEmpty) {
      // Income Categories
      final incomeCategories = [
        app_category.Category(
          id: 'salary',
          name: 'Salary',
          icon: 'work',
          type: app_category.CategoryType.income,
          color: '0xFF22C55E',
        ),
        app_category.Category(
          id: 'freelance',
          name: 'Freelance',
          icon: 'laptop',
          type: app_category.CategoryType.income,
          color: '0xFF3B82F6',
        ),
        app_category.Category(
          id: 'investment',
          name: 'Investment',
          icon: 'trending_up',
          type: app_category.CategoryType.income,
          color: '0xFF10B981',
        ),
        app_category.Category(
          id: 'gift',
          name: 'Gift',
          icon: 'card_giftcard',
          type: app_category.CategoryType.income,
          color: '0xFF8B5CF6',
        ),
        app_category.Category(
          id: 'other_income',
          name: 'Other Income',
          icon: 'category',
          type: app_category.CategoryType.income,
          color: '0xFF6B7280',
        ),
      ];

      // Expense Categories
      final expenseCategories = [
        app_category.Category(
          id: 'food',
          name: 'Food & Dining',
          icon: 'restaurant',
          type: app_category.CategoryType.expense,
          color: '0xFFEF4444',
        ),
        app_category.Category(
          id: 'shopping',
          name: 'Shopping',
          icon: 'shopping_cart',
          type: app_category.CategoryType.expense,
          color: '0xFFF59E0B',
        ),
        app_category.Category(
          id: 'transport',
          name: 'Transportation',
          icon: 'directions_car',
          type: app_category.CategoryType.expense,
          color: '0xFF6366F1',
        ),
        app_category.Category(
          id: 'entertainment',
          name: 'Entertainment',
          icon: 'movie',
          type: app_category.CategoryType.expense,
          color: '0xFFEC4899',
        ),
        app_category.Category(
          id: 'health',
          name: 'Health & Medical',
          icon: 'health_and_safety',
          type: app_category.CategoryType.expense,
          color: '0xFF06B6D4',
        ),
        app_category.Category(
          id: 'education',
          name: 'Education',
          icon: 'school',
          type: app_category.CategoryType.expense,
          color: '0xFF8B5CF6',
        ),
        app_category.Category(
          id: 'travel',
          name: 'Travel',
          icon: 'flight',
          type: app_category.CategoryType.expense,
          color: '0xFF10B981',
        ),
        app_category.Category(
          id: 'utilities',
          name: 'Utilities',
          icon: 'electrical_services',
          type: app_category.CategoryType.expense,
          color: '0xFFF59E0B',
        ),
        app_category.Category(
          id: 'other_expense',
          name: 'Other Expense',
          icon: 'category',
          type: app_category.CategoryType.expense,
          color: '0xFF6B7280',
        ),
      ];

      // Add all categories to database
      for (final category in [...incomeCategories, ...expenseCategories]) {
        await _categoriesBoxRef.put(category.id, category);
      }

      if (kDebugMode) {
        print('✅ Created ${incomeCategories.length + expenseCategories.length} default categories');
      }
    }
  }
}
