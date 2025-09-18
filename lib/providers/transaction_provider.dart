import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/transaction.dart';
import '../models/account.dart';
import '../models/category.dart' as app_category;

class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  List<Account> _accounts = [];
  List<app_category.Category> _categories = [];

  List<Transaction> get transactions => _transactions;
  List<Account> get accounts => _accounts;
  List<app_category.Category> get categories => _categories;

  double get totalBalance {
    return _accounts.fold(0.0, (sum, account) => sum + account.balance);
  }

  double get totalIncome {
    return _transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalExpense {
    return _transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  TransactionProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadTransactions();
    await _loadAccounts();
    await _loadCategories();
  }

  Future<void> _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = prefs.getString('transactions');
    if (transactionsJson != null) {
      final List<dynamic> transactionsList = json.decode(transactionsJson);
      _transactions = transactionsList
          .map((json) => Transaction.fromJson(json))
          .toList();
    }
    notifyListeners();
  }

  Future<void> _loadAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accountsJson = prefs.getString('accounts');
      if (accountsJson != null) {
        final List<dynamic> accountsList = json.decode(accountsJson);
        _accounts = accountsList.map((json) {
          try {
            return Account.fromJson(json);
          } catch (e) {
            print('Error loading account: $e');
            // Return a default account if parsing fails
            return Account(
              id: 'error_${DateTime.now().millisecondsSinceEpoch}',
              name: 'Corrupted Account',
              balance: 0.0,
              type: AccountType.bank,
            );
          }
        }).toList();
      } else {
        // Create default accounts
        _accounts = [
          Account(
            id: '1',
            name: 'Cash',
            balance: 0.0,
            type: AccountType.cash,
          ),
        Account(
          id: '2',
          name: 'Bank Account',
          balance: 0.0,
          type: AccountType.bank,
        ),
      ];
      await _saveAccounts();
    }
    } catch (e) {
      print('Error loading accounts: $e');
      // Fallback to default accounts
      _accounts = [
        Account(
          id: '1',
          name: 'Cash',
          balance: 0.0,
          type: AccountType.cash,
        ),
        Account(
          id: '2',
          name: 'Bank Account',
          balance: 0.0,
          type: AccountType.bank,
        ),
      ];
    }
    notifyListeners();
  }

  Future<void> _loadCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final categoriesJson = prefs.getString('categories');
      if (categoriesJson != null) {
        final List<dynamic> categoriesList = json.decode(categoriesJson);
        _categories = categoriesList.map((json) {
          try {
            return app_category.Category.fromJson(json);
          } catch (e) {
            print('Error loading category: $e');
            // Return a default category if parsing fails
            return app_category.Category(
              id: 'error_${DateTime.now().millisecondsSinceEpoch}',
              name: 'Unknown Category',
              icon: Icons.category.codePoint.toString(),
              type: app_category.CategoryType.expense,
            );
          }
        }).toList();
      } else {
      // Create default categories
      _categories = [
        // Income categories
        app_category.Category(
          id: '1',
          name: 'Salary',
          icon: 'work',
          type: app_category.CategoryType.income,
        ),
        app_category.Category(
          id: '2',
          name: 'Freelance',
          icon: 'laptop',
          type: app_category.CategoryType.income,
        ),
        // Expense categories
        app_category.Category(
          id: '3',
          name: 'Food',
          icon: 'restaurant',
          type: app_category.CategoryType.expense,
        ),
        app_category.Category(
          id: '4',
          name: 'Transport',
          icon: 'directions_car',
          type: app_category.CategoryType.expense,
        ),
        app_category.Category(
          id: '5',
          name: 'Shopping',
          icon: 'shopping_bag',
          type: app_category.CategoryType.expense,
        ),
        app_category.Category(
          id: '6',
          name: 'Entertainment',
          icon: 'movie',
          type: app_category.CategoryType.expense,
        ),
      ];
      await _saveCategories();
    }
    } catch (e) {
      print('Error loading categories: $e');
      // Fallback to default categories
      _categories = [
        app_category.Category(
          id: '1',
          name: 'Salary',
          icon: Icons.work.codePoint.toString(),
          type: app_category.CategoryType.income,
        ),
        app_category.Category(
          id: '2',
          name: 'Food',
          icon: Icons.restaurant.codePoint.toString(),
          type: app_category.CategoryType.expense,
        ),
      ];
    }
    notifyListeners();
  }

  Future<void> addTransaction(Transaction transaction) async {
    _transactions.add(transaction);
    await _saveTransactions();
    notifyListeners();
  }

  Future<void> addAccount(Account account) async {
    _accounts.add(account);
    await _saveAccounts();
    notifyListeners();
  }

  Future<void> updateAccount(Account account) async {
    final index = _accounts.indexWhere((a) => a.id == account.id);
    if (index != -1) {
      _accounts[index] = account;
      await _saveAccounts();
      notifyListeners();
    }
  }

  Future<void> deleteAccount(String accountId) async {
    _accounts.removeWhere((a) => a.id == accountId);
    await _saveAccounts();
    notifyListeners();
  }

  Future<void> _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = json.encode(
      _transactions.map((t) => t.toJson()).toList(),
    );
    await prefs.setString('transactions', transactionsJson);
  }

  Future<void> _saveAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final accountsJson = json.encode(
      _accounts.map((a) => a.toJson()).toList(),
    );
    await prefs.setString('accounts', accountsJson);
  }

  Future<void> _saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesJson = json.encode(
      _categories.map((c) => c.toJson()).toList(),
    );
    await prefs.setString('categories', categoriesJson);
  }
}
