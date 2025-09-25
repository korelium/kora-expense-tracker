// File location: lib/data/providers/transaction_provider_hive.dart
// Purpose: Transaction provider using Hive database for efficient data management
// Author: Pown Kumar - Founder of Korelium
// Date: September 18, 2025

import 'package:flutter/foundation.dart';

import '../models/transaction.dart';
import '../models/account.dart';
import '../models/category.dart' as app_category;
import '../models/credit_card_transaction.dart';
import '../services/hive_database_helper.dart';

/// Enhanced Transaction Provider using Hive database
/// Provides efficient CRUD operations and real-time data updates
class TransactionProviderHive with ChangeNotifier {
  // ===== PRIVATE FIELDS =====
  final HiveDatabaseHelper _db = HiveDatabaseHelper();
  bool _isLoading = false;

  // ===== GETTERS =====
  /// List of all transactions
  List<Transaction> get transactions => _db.getAllTransactions();
  
  /// List of all accounts
  List<Account> get accounts => _db.getAllAccounts();
  
  /// List of all categories
  List<app_category.Category> get categories => _db.getAllCategories();

  /// Loading state
  bool get isLoading => _isLoading;

  /// Total balance across all accounts
  double get totalBalance => _db.getTotalBalance();

  /// Total income from all income transactions
  double get totalIncome => _db.getTotalIncome();

  /// Total expenses from all expense transactions
  double get totalExpense => _db.getTotalExpenses();

  /// Net worth (total income - total expenses)
  double get netWorth => totalIncome - totalExpense;

  /// Savings rate as percentage (savings / income * 100)
  double get savingsRate {
    if (totalIncome == 0) return 0.0;
    final savings = totalIncome - totalExpense;
    return savings > 0 ? (savings / totalIncome) * 100 : 0.0;
  }

  /// Refresh data and notify listeners
  void refresh() {
    notifyListeners();
  }

  // ===== TRANSACTION METHODS =====
  
  /// Add a new transaction
  Future<void> addTransaction(Transaction transaction) async {
    _setLoading(true);
    try {
      // First check if the transaction would create negative balance
      await _validateTransactionBalance(transaction);
      
      // If validation passes, save transaction and update balance
      await _db.addTransaction(transaction);
      await _updateAccountBalance(transaction);
      await _incrementCategoryUsage(transaction.categoryId);
      
      // If this is a credit card transaction, also create a credit card transaction record
      final account = _db.getAccount(transaction.accountId);
      if (account != null && account.type == AccountType.creditCard) {
        await _createCreditCardTransaction(transaction);
      }
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error adding transaction: $e');
      }
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Update an existing transaction
  Future<void> updateTransaction(Transaction transaction) async {
    _setLoading(true);
    try {
      // Validate transaction exists
      final oldTransaction = _db.getTransaction(transaction.id);
      if (oldTransaction == null) {
        throw Exception('Transaction not found');
      }
      
      // Validate account exists
      final account = _db.getAccount(transaction.accountId);
      if (account == null) {
        throw Exception('Account not found');
      }
      
      // Validate transaction amount
      if (transaction.amount <= 0) {
        throw Exception('Transaction amount must be greater than 0');
      }
      
      // Check if the new transaction would create negative balance for asset accounts (not credit cards)
      if (account.isAsset && account.type != AccountType.creditCard) {
        final currentBalance = account.balance;
        final oldAmount = oldTransaction.amount;
        final newAmount = transaction.amount;
        final balanceChange = (oldTransaction.type == TransactionType.income ? oldAmount : -oldAmount) - 
                             (transaction.type == TransactionType.income ? newAmount : -newAmount);
        final newBalance = currentBalance + balanceChange;
        
        if (newBalance < 0) {
          throw Exception('Insufficient balance. This would result in a negative balance of ${newBalance.abs().toStringAsFixed(2)}');
        }
      }
      
      // For credit cards, validate against credit limit instead of negative balance
      if (account.type == AccountType.creditCard) {
        final currentBalance = account.balance;
        final oldAmount = oldTransaction.amount;
        final newAmount = transaction.amount;
        
        // Calculate the new balance after the transaction update
        double balanceChange = 0;
        if (oldTransaction.type == TransactionType.income) {
          balanceChange += oldAmount; // Payment was reducing debt, so we add it back
        } else {
          balanceChange -= oldAmount; // Purchase was increasing debt, so we subtract it
        }
        
        if (transaction.type == TransactionType.income) {
          balanceChange -= newAmount; // New payment reduces debt
        } else {
          balanceChange += newAmount; // New purchase increases debt
        }
        
        final newBalance = currentBalance + balanceChange;
        
        // Get credit card to check credit limit
        try {
          final creditCardsBox = await _db.creditCardsBox;
          final creditCards = creditCardsBox.values.where((card) => card.accountId == account.id).toList();
          
          if (creditCards.isNotEmpty) {
            final creditCard = creditCards.first;
            if (newBalance > creditCard.creditLimit) {
              throw Exception('Transaction would exceed credit limit. Available credit: ${(creditCard.creditLimit - currentBalance).toStringAsFixed(2)}');
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Warning: Could not validate credit limit: $e');
          }
        }
      }
      
      // Update the transaction in database
      await _db.updateTransaction(transaction);
      
      // Reverse the old transaction's effect on account balance
      await _reverseAccountBalance(oldTransaction);
      
      // Apply the new transaction's effect on account balance
      await _updateAccountBalance(transaction);
      
      // Handle credit card transaction updates
      if (account.type == AccountType.creditCard) {
        try {
          // Delete the old credit card transaction
          await _deleteCreditCardTransaction(oldTransaction.id);
          // Create the new credit card transaction
          await _createCreditCardTransaction(transaction);
        } catch (e) {
          // If credit card transaction update fails, log error but don't fail the entire operation
          if (kDebugMode) {
            print('Warning: Failed to update credit card transaction: $e');
          }
        }
      }
      
      notifyListeners();
    } catch (e) {
      _setLoading(false);
      if (kDebugMode) {
        print('Error updating transaction: $e');
      }
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Fix accounts with negative balances (set to 0)
  Future<void> fixNegativeBalances() async {
    _setLoading(true);
    try {
      for (var account in accounts) {
        if (account.balance < 0) {
          final fixedAccount = account.copyWith(balance: 0.0);
          await _db.updateAccount(fixedAccount);
        }
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error fixing negative balances: $e');
      }
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a transaction
  Future<void> deleteTransaction(String transactionId) async {
    _setLoading(true);
    try {
      // Get the transaction before deleting to update account balance
      final transaction = _db.getTransaction(transactionId);
      if (transaction != null) {
        // Delete the transaction first
        await _db.deleteTransaction(transactionId);
        // Update account balance by reversing the transaction
        await _reverseAccountBalance(transaction);
        
        // If this is a credit card transaction, also delete the credit card transaction record
        final account = _db.getAccount(transaction.accountId);
        if (account != null && account.type == AccountType.creditCard) {
          await _deleteCreditCardTransaction(transactionId);
        }
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting transaction: $e');
      }
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Get transactions by date range
  List<Transaction> getTransactionsByDateRange(DateTime start, DateTime end) {
    return _db.getTransactionsByDateRange(start, end);
  }

  /// Get transactions by type
  List<Transaction> getTransactionsByType(TransactionType type) {
    return _db.getTransactionsByType(type);
  }

  /// Get transactions by account
  List<Transaction> getTransactionsByAccount(String accountId) {
    return _db.getTransactionsByAccount(accountId);
  }

  /// Search transactions
  List<Transaction> searchTransactions(String query) {
    return _db.searchTransactions(query);
  }

  /// Get a single transaction by ID
  Transaction? getTransaction(String transactionId) {
    return _db.getTransaction(transactionId);
  }

  // ===== ACCOUNT METHODS =====
  
  /// Add a new account
  Future<void> addAccount(Account account) async {
    _setLoading(true);
    try {
      await _db.addAccount(account);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error adding account: $e');
      }
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Update an existing account
  Future<void> updateAccount(Account account) async {
    _setLoading(true);
    try {
      await _db.updateAccount(account);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error updating account: $e');
      }
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete an account
  Future<void> deleteAccount(String accountId) async {
    _setLoading(true);
    try {
      // First, delete all transfer transactions that reference this account
      await _deleteTransferTransactionsForAccount(accountId);
      
      // Then delete the account
      await _db.deleteAccount(accountId);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting account: $e');
      }
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete all transfer transactions that reference a specific account
  Future<void> _deleteTransferTransactionsForAccount(String accountId) async {
    try {
      final transactionsBox = await _db.transactionsBox;
      final transferTransactions = transactionsBox.values
          .where((transaction) => 
              transaction.type == TransactionType.transfer &&
              (transaction.fromAccountId == accountId || transaction.toAccountId == accountId))
          .toList();
      
      for (final transaction in transferTransactions) {
        await transactionsBox.delete(transaction.id);
      }
      
      if (kDebugMode && transferTransactions.isNotEmpty) {
        print('Deleted ${transferTransactions.length} transfer transactions for account: $accountId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting transfer transactions for account: $e');
      }
    }
  }

  /// Get account by ID
  Account? getAccount(String accountId) {
    return _db.getAccount(accountId);
  }

  /// Get accounts by type
  List<Account> getAccountsByType(AccountType type) {
    return _db.getAccountsByType(type);
  }

  /// Get asset accounts
  List<Account> getAssetAccounts() {
    return _db.getAssetAccounts();
  }

  /// Get liability accounts
  List<Account> getLiabilityAccounts() {
    return _db.getLiabilityAccounts();
  }

  // ===== CATEGORY METHODS =====
  
  /// Add a new category
  Future<void> addCategory(app_category.Category category) async {
    _setLoading(true);
    try {
      await _db.addCategory(category);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error adding category: $e');
      }
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Update an existing category
  Future<void> updateCategory(app_category.Category category) async {
    _setLoading(true);
    try {
      await _db.updateCategory(category);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error updating category: $e');
      }
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a category
  Future<void> deleteCategory(String categoryId) async {
    _setLoading(true);
    try {
      await _db.deleteCategory(categoryId);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting category: $e');
      }
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Get category by ID
  app_category.Category? getCategory(String categoryId) {
    return _db.getCategory(categoryId);
  }

  /// Get categories by type
  List<app_category.Category> getCategoriesByType(app_category.CategoryType type) {
    return _db.getCategoriesByType(type);
  }

  /// Get main categories (no parent)
  List<app_category.Category> getMainCategories(app_category.CategoryType type) {
    return _db.getMainCategories(type);
  }

  /// Get subcategories for a parent category
  List<app_category.Category> getSubcategories(String parentId) {
    return _db.getSubcategories(parentId);
  }

  /// Get most used categories (for suggestions)
  List<app_category.Category> getMostUsedCategories(app_category.CategoryType type, {int limit = 5}) {
    return _db.getMostUsedCategories(type, limit: limit);
  }

  // ===== ANALYTICS METHODS =====
  
  /// Get monthly statistics
  Map<String, double> getMonthlyStats(int year, int month) {
    return _db.getMonthlyStats(year, month);
  }

  /// Get category spending breakdown
  Map<String, double> getCategorySpending(TransactionType type) {
    return _db.getCategorySpending(type);
  }

  /// Get database statistics
  Map<String, int> getDatabaseStats() {
    return _db.getDatabaseStats();
  }

  // ===== DATA MANAGEMENT =====
  
  /// Export all data for backup
  Map<String, dynamic> exportAllData() {
    return _db.exportAllData();
  }

  /// Import data from backup
  Future<void> importData(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      await _db.importData(data);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error importing data: $e');
      }
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Clear all data
  Future<void> clearAllData() async {
    _setLoading(true);
    try {
      await _db.clearAllData();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing data: $e');
      }
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ===== PRIVATE HELPER METHODS =====
  
  /// Set loading state
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// Validate that transaction won't create negative balance
  Future<void> _validateTransactionBalance(Transaction transaction) async {
    final account = _db.getAccount(transaction.accountId);
    if (account == null) return;
    
    if (account.type == AccountType.creditCard) {
      // For credit cards, validate against credit limit
      if (transaction.type == TransactionType.expense) {
        // Get credit card to check credit limit
        final creditCardsBox = await _db.creditCardsBox;
        final creditCards = creditCardsBox.values.where((card) => card.accountId == account.id).toList();
        
        if (creditCards.isNotEmpty) {
          final creditCard = creditCards.first;
          final newBalance = account.balance + transaction.amount; // Expense increases debt
          if (newBalance > creditCard.creditLimit) {
            throw Exception('Transaction would exceed credit limit. Available credit: ${creditCard.creditLimit - account.balance}');
          }
        }
      }
    } else {
      // For asset accounts, prevent negative balances
      if (transaction.type == TransactionType.expense) {
        final newBalance = account.balance - transaction.amount;
        if (newBalance < 0) {
          throw Exception('Insufficient funds. Cannot have negative balance in ${account.type.name} account.');
        }
      }
    }
  }

  /// Update account balance based on transaction
  Future<void> _updateAccountBalance(Transaction transaction) async {
    final account = _db.getAccount(transaction.accountId);
    if (account == null) return;

    double newBalance = account.balance;
    
    // Update balance based on account type and transaction type
    if (account.type == AccountType.creditCard) {
      // Credit card logic: balance represents debt owed
      if (transaction.type == TransactionType.income) {
        // Payment reduces debt (decreases balance)
        newBalance -= transaction.amount;
      } else if (transaction.type == TransactionType.expense) {
        // Purchase increases debt (increases balance)
        newBalance += transaction.amount;
      }
    } else {
      // Asset accounts (Cash, Bank, etc.): balance represents money available
      if (transaction.type == TransactionType.income) {
        // Income increases asset balance
        newBalance += transaction.amount;
      } else if (transaction.type == TransactionType.expense) {
        // Expense decreases asset balance (validation already done in _validateTransactionBalance)
        newBalance -= transaction.amount;
      }
    }

    // Update account with new balance
    final updatedAccount = account.copyWith(balance: newBalance);
    await _db.updateAccount(updatedAccount);
    
    // If this is a credit card account, also update the credit card balance
    if (account.type == AccountType.creditCard) {
      try {
        // Get credit card from database directly
        final creditCardsBox = await _db.creditCardsBox;
        final creditCards = creditCardsBox.values.where((card) => card.accountId == account.id).toList();
        
        if (creditCards.isNotEmpty) {
          final creditCard = creditCards.first;
          // Use the same newBalance to ensure consistency
          final updatedCreditCard = creditCard.copyWith(currentBalance: newBalance);
          await creditCardsBox.put(creditCard.id, updatedCreditCard);
        }
      } catch (e) {
        // If credit card update fails, just log the error
        if (kDebugMode) {
          print('Error updating credit card balance: $e');
        }
      }
    }
  }

  /// Update account balances for transfer transactions
  Future<void> _updateTransferBalances(Account fromAccount, Account toAccount, double amount) async {
    // Update source account balance (decrease)
    final updatedFromAccount = fromAccount.copyWith(balance: fromAccount.balance - amount);
    await _db.updateAccount(updatedFromAccount);
    
    // Update destination account balance (increase)
    final updatedToAccount = toAccount.copyWith(balance: toAccount.balance + amount);
    await _db.updateAccount(updatedToAccount);
    
    // Update credit card balances if applicable
    if (fromAccount.type == AccountType.creditCard) {
      try {
        final creditCardsBox = await _db.creditCardsBox;
        final creditCards = creditCardsBox.values.where((card) => card.accountId == fromAccount.id).toList();
        if (creditCards.isNotEmpty) {
          final creditCard = creditCards.first;
          final updatedCreditCard = creditCard.copyWith(currentBalance: updatedFromAccount.balance);
          await creditCardsBox.put(creditCard.id, updatedCreditCard);
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error updating source credit card balance: $e');
        }
      }
    }
    
    if (toAccount.type == AccountType.creditCard) {
      try {
        final creditCardsBox = await _db.creditCardsBox;
        final creditCards = creditCardsBox.values.where((card) => card.accountId == toAccount.id).toList();
        if (creditCards.isNotEmpty) {
          final creditCard = creditCards.first;
          final updatedCreditCard = creditCard.copyWith(currentBalance: updatedToAccount.balance);
          await creditCardsBox.put(creditCard.id, updatedCreditCard);
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error updating destination credit card balance: $e');
        }
      }
    }
  }

  /// Create a credit card transaction record
  Future<void> _createCreditCardTransaction(Transaction transaction) async {
    try {
      // Find the credit card associated with this account
      final creditCardsBox = await _db.creditCardsBox;
      final creditCards = creditCardsBox.values.where((card) => card.accountId == transaction.accountId).toList();
      
      if (creditCards.isNotEmpty) {
        final creditCard = creditCards.first;
        
        // Create credit card transaction
        final creditCardTransaction = CreditCardTransaction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          creditCardId: creditCard.id,
          transactionId: transaction.id,
          categoryId: transaction.categoryId,
          amount: transaction.amount,
          description: transaction.description,
          transactionDate: transaction.date,
          postingDate: transaction.date,
          type: transaction.type == TransactionType.income 
              ? CreditCardTransactionType.payment 
              : CreditCardTransactionType.purchase,
          merchantName: null,
          location: null,
          isPending: false,
          receiptImagePath: null,
          notes: transaction.description,
        );
        
        // Save to credit card transactions box
        final creditCardTransactionsBox = await _db.creditCardTransactionsBox;
        await creditCardTransactionsBox.put(creditCardTransaction.id, creditCardTransaction);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating credit card transaction: $e');
      }
    }
  }

  /// Delete a credit card transaction record
  Future<void> _deleteCreditCardTransaction(String transactionId) async {
    try {
      // Find and delete the credit card transaction associated with this transaction
      final creditCardTransactionsBox = await _db.creditCardTransactionsBox;
      final creditCardTransactions = creditCardTransactionsBox.values
          .where((ccTransaction) => ccTransaction.transactionId == transactionId)
          .toList();
      
      for (final ccTransaction in creditCardTransactions) {
        await creditCardTransactionsBox.delete(ccTransaction.id);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting credit card transaction: $e');
      }
    }
  }

  /// Increment category usage count
  Future<void> _incrementCategoryUsage(String categoryId) async {
    final category = _db.getCategory(categoryId);
    if (category != null) {
      final updatedCategory = category.incrementUsage();
      await _db.updateCategory(updatedCategory);
    }
  }

  /// Reverse account balance when transaction is deleted
  Future<void> _reverseAccountBalance(Transaction transaction) async {
    // Handle transfer transactions differently
    if (transaction.type == TransactionType.transfer) {
      await _reverseTransferBalances(transaction);
      return;
    }

    final account = _db.getAccount(transaction.accountId);
    if (account == null) return;

    double newBalance = account.balance;
    
    // Reverse the balance change based on account type
    if (account.type == AccountType.creditCard) {
      // Credit card logic: balance represents debt owed
      if (transaction.type == TransactionType.income) {
        // Payment was reducing debt, so deletion increases debt (adds back to balance)
        newBalance += transaction.amount;
      } else if (transaction.type == TransactionType.expense) {
        // Purchase was increasing debt, so deletion decreases debt (subtracts from balance)
        newBalance -= transaction.amount;
      }
    } else {
      // Asset accounts (Cash, Bank, etc.): balance represents money available
      if (transaction.type == TransactionType.income) {
        // Income was increasing asset, so deletion decreases asset
        newBalance -= transaction.amount;
      } else if (transaction.type == TransactionType.expense) {
        // Expense was decreasing asset, so deletion increases asset
        newBalance += transaction.amount;
      }
    }

    // Update account with reversed balance
    final updatedAccount = account.copyWith(balance: newBalance);
    await _db.updateAccount(updatedAccount);
    
    // If this is a credit card account, also update the credit card balance
    if (account.type == AccountType.creditCard) {
      try {
        // Get credit card from database directly
        final creditCardsBox = await _db.creditCardsBox;
        final creditCards = creditCardsBox.values.where((card) => card.accountId == account.id).toList();
        
        if (creditCards.isNotEmpty) {
          final creditCard = creditCards.first;
          // Use the same newBalance to ensure consistency
          final updatedCreditCard = creditCard.copyWith(currentBalance: newBalance);
          await creditCardsBox.put(creditCard.id, updatedCreditCard);
        }
      } catch (e) {
        // If credit card update fails, just log the error
        if (kDebugMode) {
          print('Error updating credit card balance on deletion: $e');
        }
      }
    }
  }

  /// Reverse transfer balances when a transfer transaction is deleted
  Future<void> _reverseTransferBalances(Transaction transaction) async {
    if (transaction.fromAccountId == null || transaction.toAccountId == null) {
      if (kDebugMode) {
        print('Error: Transfer transaction missing fromAccountId or toAccountId');
      }
      return;
    }

    // Get both accounts
    final fromAccount = _db.getAccount(transaction.fromAccountId!);
    final toAccount = _db.getAccount(transaction.toAccountId!);
    
    if (fromAccount == null || toAccount == null) {
      if (kDebugMode) {
        print('Error: Could not find source or destination account for transfer deletion');
      }
      return;
    }

    // Reverse the transfer: add amount back to source, subtract from destination
    final updatedFromAccount = fromAccount.copyWith(balance: fromAccount.balance + transaction.amount);
    final updatedToAccount = toAccount.copyWith(balance: toAccount.balance - transaction.amount);
    
    // Update both accounts
    await _db.updateAccount(updatedFromAccount);
    await _db.updateAccount(updatedToAccount);
    
    // Update credit card balances and delete credit card transaction records if applicable
    if (fromAccount.type == AccountType.creditCard) {
      try {
        final creditCardsBox = await _db.creditCardsBox;
        final creditCards = creditCardsBox.values.where((card) => card.accountId == fromAccount.id).toList();
        if (creditCards.isNotEmpty) {
          final creditCard = creditCards.first;
          final updatedCreditCard = creditCard.copyWith(currentBalance: updatedFromAccount.balance);
          await creditCardsBox.put(creditCard.id, updatedCreditCard);
        }
        // Delete the credit card transaction record for the source account
        await _deleteCreditCardTransaction(transaction.id);
      } catch (e) {
        if (kDebugMode) {
          print('Error updating source credit card balance on transfer deletion: $e');
        }
      }
    }
    
    if (toAccount.type == AccountType.creditCard) {
      try {
        final creditCardsBox = await _db.creditCardsBox;
        final creditCards = creditCardsBox.values.where((card) => card.accountId == toAccount.id).toList();
        if (creditCards.isNotEmpty) {
          final creditCard = creditCards.first;
          final updatedCreditCard = creditCard.copyWith(currentBalance: updatedToAccount.balance);
          await creditCardsBox.put(creditCard.id, updatedCreditCard);
        }
        // Delete the credit card transaction record for the destination account
        // Note: For transfers, we need to delete the credit card transaction that was created for the destination account
        // This would have been created with a different transaction ID, so we need to find and delete it
        await _deleteCreditCardTransactionByTransactionId(transaction.id, toAccount.id);
      } catch (e) {
        if (kDebugMode) {
          print('Error updating destination credit card balance on transfer deletion: $e');
        }
      }
    }
  }

  /// Delete credit card transaction by transaction ID and account ID
  Future<void> _deleteCreditCardTransactionByTransactionId(String transactionId, String accountId) async {
    try {
      // First, find the credit card associated with the account
      final creditCardsBox = await _db.creditCardsBox;
      final creditCards = creditCardsBox.values.where((card) => card.accountId == accountId).toList();
      
      if (creditCards.isEmpty) {
        if (kDebugMode) {
          print('No credit card found for account: $accountId');
        }
        return;
      }
      
      final creditCard = creditCards.first;
      
      // Now find and delete the credit card transaction
      final creditCardTransactionsBox = await _db.creditCardTransactionsBox;
      final creditCardTransactions = creditCardTransactionsBox.values
          .where((ccTransaction) => 
              ccTransaction.transactionId == transactionId && 
              ccTransaction.creditCardId == creditCard.id)
          .toList();
      
      for (final ccTransaction in creditCardTransactions) {
        await creditCardTransactionsBox.delete(ccTransaction.id);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting credit card transaction by transaction ID: $e');
      }
    }
  }

  /// Add a transfer between two accounts
  Future<void> addTransfer({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    required String description,
  }) async {
    _setLoading(true);
    try {
      // Validate input parameters
      if (amount <= 0) {
        throw Exception('Transfer amount must be greater than 0');
      }
      
      if (fromAccountId == toAccountId) {
        throw Exception('Cannot transfer to the same account');
      }
      
      if (description.trim().isEmpty) {
        throw Exception('Transfer description cannot be empty');
      }
      
      // Validate accounts exist
      final fromAccount = _db.getAccount(fromAccountId);
      final toAccount = _db.getAccount(toAccountId);
      
      if (fromAccount == null) {
        throw Exception('Source account not found');
      }
      if (toAccount == null) {
        throw Exception('Destination account not found');
      }
      
      // Validate sufficient balance for asset accounts
      if (fromAccount.isAsset && fromAccount.balance < amount) {
        throw Exception('Insufficient balance in source account. Available: ${fromAccount.balance.toStringAsFixed(2)}, Required: ${amount.toStringAsFixed(2)}');
      }
      
      // Get the first available category for transfers (we'll use a generic one)
      final categories = _db.getMainCategories(app_category.CategoryType.expense);
      final transferCategoryId = categories.isNotEmpty ? categories.first.id : 'default';
      
      // Create single transfer transaction
      final transferTransaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        accountId: fromAccountId, // Primary account (source)
        categoryId: transferCategoryId, // Use existing category
        amount: amount,
        type: TransactionType.transfer,
        description: description,
        date: DateTime.now(),
        fromAccountId: fromAccountId,
        toAccountId: toAccountId,
      );
      
      // Add the transfer transaction
      await _db.addTransaction(transferTransaction);
      
      // Update both account balances manually
      await _updateTransferBalances(fromAccount, toAccount, amount);
      
      // If either account is a credit card, create credit card transaction records
      try {
        if (fromAccount.type == AccountType.creditCard) {
          await _createCreditCardTransaction(transferTransaction);
        }
        if (toAccount.type == AccountType.creditCard) {
          // Create a separate credit card transaction for the destination account
          final creditCardTransaction = transferTransaction.copyWith(
            accountId: toAccountId,
            type: TransactionType.income, // Credit card sees it as income
          );
          await _createCreditCardTransaction(creditCardTransaction);
        }
      } catch (e) {
        // If credit card transaction creation fails, log error but don't fail the entire operation
        if (kDebugMode) {
          print('Warning: Failed to create credit card transaction records: $e');
        }
      }
      
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setLoading(false);
      if (kDebugMode) {
        print('Error adding transfer: $e');
      }
      rethrow;
    }
  }
}
