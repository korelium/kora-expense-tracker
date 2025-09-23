// File location: lib/data/providers/credit_card_provider.dart
// Purpose: Credit card provider for managing credit card state and operations
// Author: Pown Kumar - Founder of Korelium
// Date: September 23, 2025

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/credit_card.dart';
import '../models/credit_card_transaction.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../services/hive_database_helper.dart';
import '../../core/error_handling/error_handler.dart';

/// Provider for managing credit card state and operations
/// Handles CRUD operations for credit cards and their transactions
class CreditCardProvider extends ChangeNotifier {
  final HiveDatabaseHelper _databaseHelper = HiveDatabaseHelper();
  
  List<CreditCard> _creditCards = [];
  List<CreditCardTransaction> _creditCardTransactions = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<CreditCard> get creditCards => List.unmodifiable(_creditCards);
  List<CreditCardTransaction> get creditCardTransactions => List.unmodifiable(_creditCardTransactions);
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  /// Get active credit cards only
  List<CreditCard> get activeCreditCards => _creditCards.where((card) => card.isActive).toList();
  
  /// Get credit cards with due payments
  List<CreditCard> get creditCardsWithDuePayments => _creditCards.where((card) => 
    card.isActive && (card.isPaymentDueSoon || card.isOverdue)).toList();
  
  /// Get total credit limit across all active cards
  double get totalCreditLimit => activeCreditCards.fold(0.0, (sum, card) => sum + card.creditLimit);
  
  /// Get total current balance across all active cards
  double get totalCurrentBalance => activeCreditCards.fold(0.0, (sum, card) => sum + card.currentBalance);
  
  /// Get total available credit across all active cards
  double get totalAvailableCredit => totalCreditLimit - totalCurrentBalance;
  
  /// Get average credit utilization across all active cards (hides negative sign)
  double get averageCreditUtilization {
    if (activeCreditCards.isEmpty) return 0.0;
    final totalUtilization = activeCreditCards.fold(0.0, (sum, card) => sum + card.creditUtilization.abs());
    return totalUtilization / activeCreditCards.length;
  }

  /// Initialize the provider and load data
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _loadCreditCards();
      await _loadCreditCardTransactions();
      _clearError();
    } catch (e) {
      _setError('Failed to initialize credit card data: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load all credit cards from database
  Future<void> _loadCreditCards() async {
    try {
      final box = await _databaseHelper.creditCardsBox;
      _creditCards = box.values.toList();
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load credit cards: $e');
    }
  }

  /// Load all credit card transactions from database
  Future<void> _loadCreditCardTransactions() async {
    try {
      final box = await _databaseHelper.creditCardTransactionsBox;
      _creditCardTransactions = box.values.toList();
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load credit card transactions: $e');
    }
  }

  /// Add a new credit card
  Future<void> addCreditCard({
    required String cardName,
    required String lastFourDigits,
    required String bankName,
    required double creditLimit,
    required double interestRate,
    required int dueDay,
    required double minimumPayment,
    String? notes,
  }) async {
    _setLoading(true);
    try {
      final creditCardId = DateTime.now().millisecondsSinceEpoch.toString();
      final accountId = DateTime.now().millisecondsSinceEpoch.toString() + '_acc';
      
      // Create the account first
      final account = Account(
        id: accountId,
        name: cardName,
        balance: 0.0, // Credit cards start with 0 balance
        type: AccountType.creditCard,
        description: notes,
      );
      
      // Add account to database
      final accountsBox = await _databaseHelper.accountsBox;
      await accountsBox.put(accountId, account);
      
      // Create the credit card
      final creditCard = CreditCard(
        id: creditCardId,
        accountId: accountId,
        cardName: cardName,
        lastFourDigits: lastFourDigits,
        bankName: bankName,
        creditLimit: creditLimit,
        currentBalance: 0.0,
        interestRate: interestRate,
        dueDay: dueDay,
        minimumPayment: minimumPayment,
        createdAt: DateTime.now(),
        notes: notes,
      );
      
      // Add credit card to database
      final creditCardsBox = await _databaseHelper.creditCardsBox;
      await creditCardsBox.put(creditCardId, creditCard);
      
      // Reload data
      await _loadCreditCards();
      _clearError();
    } catch (e) {
      _setError('Failed to add credit card: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Update an existing credit card
  Future<void> updateCreditCard({
    required String creditCardId,
    String? cardName,
    String? lastFourDigits,
    String? bankName,
    double? creditLimit,
    double? interestRate,
    int? dueDay,
    double? minimumPayment,
    String? notes,
  }) async {
    _setLoading(true);
    try {
      final creditCard = _creditCards.firstWhere((card) => card.id == creditCardId);
      final updatedCreditCard = creditCard.copyWith(
        cardName: cardName,
        lastFourDigits: lastFourDigits,
        bankName: bankName,
        creditLimit: creditLimit,
        interestRate: interestRate,
        dueDay: dueDay,
        minimumPayment: minimumPayment,
        notes: notes,
      );
      
      // Update in database
      final creditCardsBox = await _databaseHelper.creditCardsBox;
      await creditCardsBox.put(creditCardId, updatedCreditCard);
      
      // Also update the associated account
      final accountsBox = await _databaseHelper.accountsBox;
      final account = accountsBox.get(creditCard.accountId);
      if (account != null) {
        final updatedAccount = account.copyWith(
          name: cardName ?? account.name,
          description: notes ?? account.description,
        );
        await accountsBox.put(creditCard.accountId, updatedAccount);
      }
      
      // Reload data
      await _loadCreditCards();
      _clearError();
    } catch (e) {
      _setError('Failed to update credit card: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a credit card
  Future<void> deleteCreditCard(String creditCardId) async {
    _setLoading(true);
    try {
      final creditCard = _creditCards.firstWhere((card) => card.id == creditCardId);
      
      // Delete credit card transactions first
      final transactionsToDelete = _creditCardTransactions
          .where((transaction) => transaction.creditCardId == creditCardId)
          .toList();
      
      final creditCardTransactionsBox = await _databaseHelper.creditCardTransactionsBox;
      for (final transaction in transactionsToDelete) {
        await creditCardTransactionsBox.delete(transaction.id);
      }
      
      // Delete credit card
      final creditCardsBox = await _databaseHelper.creditCardsBox;
      await creditCardsBox.delete(creditCardId);
      
      // Delete associated account
      final accountsBox = await _databaseHelper.accountsBox;
      await accountsBox.delete(creditCard.accountId);
      
      // Reload data
      await _loadCreditCards();
      await _loadCreditCardTransactions();
      _clearError();
    } catch (e) {
      _setError('Failed to delete credit card: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Add a credit card transaction
  Future<void> addCreditCardTransaction({
    required String creditCardId,
    required String categoryId,
    required double amount,
    required String description,
    required DateTime transactionDate,
    CreditCardTransactionType type = CreditCardTransactionType.purchase,
    String? merchantName,
    String? location,
    String? notes,
  }) async {
    _setLoading(true);
    try {
      final creditCard = _creditCards.firstWhere((card) => card.id == creditCardId);
      final transactionId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Create main transaction
      final transaction = Transaction(
        id: transactionId,
        accountId: creditCard.accountId,
        categoryId: categoryId,
        amount: amount,
        description: description,
        date: transactionDate,
        type: type == CreditCardTransactionType.payment ? TransactionType.income : TransactionType.expense,
      );
      
      // Add main transaction to database
      final transactionsBox = await _databaseHelper.transactionsBox;
      await transactionsBox.put(transactionId, transaction);
      
      // Create credit card transaction
      final creditCardTransaction = CreditCardTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_cc',
        creditCardId: creditCardId,
        transactionId: transactionId,
        categoryId: categoryId,
        amount: amount,
        description: description,
        transactionDate: transactionDate,
        postingDate: DateTime.now(),
        type: type,
        merchantName: merchantName,
        location: location,
        notes: notes,
      );
      
      // Add credit card transaction to database
      final creditCardTransactionsBox = await _databaseHelper.creditCardTransactionsBox;
      await creditCardTransactionsBox.put(creditCardTransaction.id, creditCardTransaction);
      
      // Update credit card balance
      final newBalance = type == CreditCardTransactionType.payment 
          ? creditCard.currentBalance - amount  // Payment reduces balance
          : creditCard.currentBalance + amount; // Purchase increases balance
      
      final updatedCreditCard = creditCard.copyWith(currentBalance: newBalance);
      final creditCardsBox = await _databaseHelper.creditCardsBox;
      await creditCardsBox.put(creditCardId, updatedCreditCard);
      
      // Update associated account balance
      final accountsBox = await _databaseHelper.accountsBox;
      final account = accountsBox.get(creditCard.accountId);
      if (account != null) {
        final updatedAccount = account.copyWith(balance: newBalance);
        await accountsBox.put(creditCard.accountId, updatedAccount);
      }
      
      // Reload data
      await _loadCreditCards();
      await _loadCreditCardTransactions();
      _clearError();
    } catch (e) {
      _setError('Failed to add credit card transaction: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Get credit card by ID
  CreditCard? getCreditCardById(String creditCardId) {
    try {
      return _creditCards.firstWhere((card) => card.id == creditCardId);
    } catch (e) {
      return null;
    }
  }

  /// Get credit card transactions by credit card ID
  List<CreditCardTransaction> getCreditCardTransactions(String creditCardId) {
    return _creditCardTransactions
        .where((transaction) => transaction.creditCardId == creditCardId)
        .toList()
        ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
  }

  /// Get recent credit card transactions (last 30 days)
  List<CreditCardTransaction> getRecentCreditCardTransactions({int days = 30}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _creditCardTransactions
        .where((transaction) => transaction.transactionDate.isAfter(cutoffDate))
        .toList()
        ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
  }

  /// Get credit card transactions by type
  List<CreditCardTransaction> getCreditCardTransactionsByType(CreditCardTransactionType type) {
    return _creditCardTransactions
        .where((transaction) => transaction.type == type)
        .toList()
        ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
  }

  /// Search credit card transactions
  List<CreditCardTransaction> searchCreditCardTransactions(String query) {
    if (query.isEmpty) return _creditCardTransactions;
    
    final lowercaseQuery = query.toLowerCase();
    return _creditCardTransactions.where((transaction) {
      return transaction.description.toLowerCase().contains(lowercaseQuery) ||
             (transaction.merchantName?.toLowerCase().contains(lowercaseQuery) ?? false) ||
             (transaction.location?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList()
      ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refresh all data
  Future<void> refresh() async {
    await initialize();
  }
}
