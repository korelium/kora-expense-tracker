import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/transaction.dart';
import '../models/account.dart';
import '../models/category.dart' as app_category;

class ExpenseProvider with ChangeNotifier {
  List<Transaction> _expenses = [];
  List<Account> _accounts = [];
  List<app_category.Category> _categories = [];

  List<Transaction> get expenses => _expenses;
  List<Account> get accounts => _accounts;
  List<app_category.Category> get categories => _categories;

  double get totalExpenses {
    return _expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double get monthlyExpenses {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    return _expenses
        .where((expense) => 
            expense.date.isAfter(startOfMonth) && 
            expense.date.isBefore(endOfMonth))
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  ExpenseProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadExpenses();
    await _loadAccounts();
    await _loadCategories();
  }

  Future<void> _loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final expensesJson = prefs.getString('expenses');
    if (expensesJson != null) {
      final List<dynamic> expensesList = json.decode(expensesJson);
      _expenses = expensesList
          .map((json) => Transaction.fromJson(json))
          .where((transaction) => transaction.type == TransactionType.expense)
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
      }
    } catch (e) {
      print('Error loading accounts: $e');
      // Fallback to empty list
      _accounts = [];
    }
    notifyListeners();
  }

  Future<void> _loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesJson = prefs.getString('categories');
    if (categoriesJson != null) {
      final List<dynamic> categoriesList = json.decode(categoriesJson);
      _categories = categoriesList
          .map((json) => app_category.Category.fromJson(json))
          .where((category) => category.type == app_category.CategoryType.expense)
          .toList();
    }
    notifyListeners();
  }

  Future<void> addExpense(Transaction expense) async {
    if (expense.type != TransactionType.expense) {
      throw ArgumentError('Transaction must be of type expense');
    }
    
    _expenses.add(expense);
    await _saveExpenses();
    notifyListeners();
  }

  Future<void> updateExpense(Transaction updatedExpense) async {
    if (updatedExpense.type != TransactionType.expense) {
      throw ArgumentError('Transaction must be of type expense');
    }
    
    final index = _expenses.indexWhere((expense) => expense.id == updatedExpense.id);
    if (index != -1) {
      _expenses[index] = updatedExpense;
      await _saveExpenses();
      notifyListeners();
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    _expenses.removeWhere((expense) => expense.id == expenseId);
    await _saveExpenses();
    notifyListeners();
  }

  Future<void> _saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final expensesJson = json.encode(
      _expenses.map((e) => e.toJson()).toList(),
    );
    await prefs.setString('expenses', expensesJson);
  }

  List<Transaction> getExpensesByCategory(String categoryId) {
    return _expenses.where((expense) => expense.categoryId == categoryId).toList();
  }

  List<Transaction> getExpensesByAccount(String accountId) {
    return _expenses.where((expense) => expense.accountId == accountId).toList();
  }

  List<Transaction> getExpensesByDateRange(DateTime startDate, DateTime endDate) {
    return _expenses.where((expense) => 
        expense.date.isAfter(startDate) && 
        expense.date.isBefore(endDate)).toList();
  }

  Map<String, double> getExpensesByCategorySummary() {
    final Map<String, double> summary = {};
    for (final expense in _expenses) {
      final category = _categories.firstWhere(
        (cat) => cat.id == expense.categoryId,
        orElse: () => app_category.Category(
          id: 'unknown',
          name: 'Unknown',
          icon: 'help',
          type: app_category.CategoryType.expense,
        ),
      );
      summary[category.name] = (summary[category.name] ?? 0.0) + expense.amount;
    }
    return summary;
  }
}
