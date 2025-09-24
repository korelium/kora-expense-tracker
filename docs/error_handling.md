# Error Handling Documentation

## Overview
This document provides comprehensive information about the error handling system implemented in the Kora Expense Tracker application. It covers error types, handling strategies, and troubleshooting guidelines.

## Table of Contents
1. [Error Handling Architecture](#error-handling-architecture)
2. [Transaction Operations Error Handling](#transaction-operations-error-handling)
3. [Transfer Operations Error Handling](#transfer-operations-error-handling)
4. [Credit Card Operations Error Handling](#credit-card-operations-error-handling)
5. [Common Error Scenarios](#common-error-scenarios)
6. [Troubleshooting Guide](#troubleshooting-guide)
7. [Error Recovery Strategies](#error-recovery-strategies)

## Error Handling Architecture

### Core Principles
- **Graceful Degradation**: Non-critical failures don't break core functionality
- **User-Friendly Messages**: Clear, actionable error messages for users
- **Data Integrity**: Prevent invalid data from being saved
- **Comprehensive Logging**: Detailed logging for debugging and monitoring

### Error Categories
1. **Validation Errors**: Input validation failures
2. **Business Logic Errors**: Rule violations (e.g., negative balances)
3. **Database Errors**: Data persistence failures
4. **Network Errors**: External service failures
5. **System Errors**: Unexpected application errors

## Transaction Operations Error Handling

### Add Transaction
```dart
Future<void> addTransaction(Transaction transaction) async {
  _setLoading(true);
  try {
    // Validate transaction balance
    await _validateTransactionBalance(transaction);
    
    // Save transaction and update balance
    await _db.addTransaction(transaction);
    await _updateAccountBalance(transaction);
    await _incrementCategoryUsage(transaction.categoryId);
    
    // Handle credit card transactions
    if (account.type == AccountType.creditCard) {
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
```

#### Error Scenarios
- **Insufficient Balance**: `"Insufficient balance. Available: 100.00, Required: 150.00"`
- **Invalid Amount**: `"Transaction amount must be greater than 0"`
- **Account Not Found**: `"Account not found"`
- **Category Not Found**: `"Category not found"`

### Update Transaction
```dart
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
    
    // Check balance constraints
    if (account.isAsset) {
      final newBalance = _calculateNewBalance(oldTransaction, transaction, account);
      if (newBalance < 0) {
        throw Exception('Insufficient balance. This would result in a negative balance of ${newBalance.abs().toStringAsFixed(2)}');
      }
    }
    
    // Update transaction
    await _db.updateTransaction(transaction);
    await _reverseAccountBalance(oldTransaction);
    await _updateAccountBalance(transaction);
    
    // Handle credit card transaction updates
    if (account.type == AccountType.creditCard) {
      try {
        await _deleteCreditCardTransaction(oldTransaction.id);
        await _createCreditCardTransaction(transaction);
      } catch (e) {
        // Log warning but don't fail the entire operation
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
```

#### Error Scenarios
- **Transaction Not Found**: `"Transaction not found"`
- **Account Not Found**: `"Account not found"`
- **Invalid Amount**: `"Transaction amount must be greater than 0"`
- **Negative Balance**: `"Insufficient balance. This would result in a negative balance of 50.00"`
- **Credit Card Update Failure**: Warning logged, main transaction still succeeds

### Delete Transaction
```dart
Future<void> deleteTransaction(String transactionId) async {
  _setLoading(true);
  try {
    final transaction = _db.getTransaction(transactionId);
    if (transaction != null) {
      await _db.deleteTransaction(transactionId);
      await _reverseAccountBalance(transaction);
      
      // Handle credit card transaction deletion
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
```

## Transfer Operations Error Handling

### Add Transfer
```dart
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
    
    // Validate sufficient balance
    if (fromAccount.isAsset && fromAccount.balance < amount) {
      throw Exception('Insufficient balance in source account. Available: ${fromAccount.balance.toStringAsFixed(2)}, Required: ${amount.toStringAsFixed(2)}');
    }
    
    // Create transfer transactions
    final expenseTransaction = Transaction(/* ... */);
    final incomeTransaction = Transaction(/* ... */);
    
    await _db.addTransaction(expenseTransaction);
    await _db.addTransaction(incomeTransaction);
    await _updateAccountBalance(expenseTransaction);
    await _updateAccountBalance(incomeTransaction);
    
    // Handle credit card transactions
    try {
      if (fromAccount.type == AccountType.creditCard) {
        await _createCreditCardTransaction(expenseTransaction);
      }
      if (toAccount.type == AccountType.creditCard) {
        await _createCreditCardTransaction(incomeTransaction);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Warning: Failed to create credit card transaction records: $e');
      }
    }
    
    notifyListeners();
  } catch (e) {
    _setLoading(false);
    if (kDebugMode) {
      print('Error adding transfer: $e');
    }
    rethrow;
  } finally {
    _setLoading(false);
  }
}
```

#### Error Scenarios
- **Invalid Amount**: `"Transfer amount must be greater than 0"`
- **Same Account**: `"Cannot transfer to the same account"`
- **Empty Description**: `"Transfer description cannot be empty"`
- **Source Account Not Found**: `"Source account not found"`
- **Destination Account Not Found**: `"Destination account not found"`
- **Insufficient Balance**: `"Insufficient balance in source account. Available: 100.00, Required: 150.00"`

## Credit Card Operations Error Handling

### Credit Card Transaction Creation
```dart
Future<void> _createCreditCardTransaction(Transaction transaction) async {
  try {
    final account = _db.getAccount(transaction.accountId);
    if (account == null || account.type != AccountType.creditCard) {
      return;
    }
    
    final creditCardsBox = await _db.creditCardsBox;
    final creditCards = creditCardsBox.values.where((card) => card.accountId == account.id).toList();
    
    if (creditCards.isNotEmpty) {
      final creditCard = creditCards.first;
      final creditCardTransaction = CreditCardTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        creditCardId: creditCard.id,
        transactionId: transaction.id,
        amount: transaction.amount,
        type: transaction.type == TransactionType.income 
            ? CreditCardTransactionType.payment 
            : CreditCardTransactionType.purchase,
        description: transaction.description,
        transactionDate: transaction.date,
      );
      
      await creditCardsBox.put(creditCardTransaction.id, creditCardTransaction);
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error creating credit card transaction: $e');
    }
  }
}
```

### Credit Card Transaction Deletion
```dart
Future<void> _deleteCreditCardTransaction(String transactionId) async {
  try {
    final creditCardTransactionsBox = await _db.creditCardTransactionsBox;
    final transactions = creditCardTransactionsBox.values
        .where((t) => t.transactionId == transactionId)
        .toList();
    
    for (final transaction in transactions) {
      await creditCardTransactionsBox.delete(transaction.id);
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error deleting credit card transaction: $e');
    }
  }
}
```

## Common Error Scenarios

### 1. Database Connection Issues
**Symptoms**: 
- "Database not initialized"
- "Failed to open database"

**Solutions**:
- Check Hive initialization
- Verify database permissions
- Restart the application

### 2. Data Synchronization Issues
**Symptoms**:
- Transactions not appearing in credit card details
- Balance inconsistencies
- Duplicate transactions

**Solutions**:
- Refresh the credit card provider
- Check transaction provider state
- Verify account balance calculations

### 3. Memory Issues
**Symptoms**:
- App crashes during large operations
- Slow performance
- "Out of memory" errors

**Solutions**:
- Implement pagination for large datasets
- Optimize database queries
- Add memory monitoring

### 4. UI State Issues
**Symptoms**:
- Loading states not clearing
- UI not updating after operations
- Inconsistent data display

**Solutions**:
- Check provider state management
- Verify notifyListeners() calls
- Ensure proper error handling in UI

## Troubleshooting Guide

### Step 1: Check Logs
```dart
if (kDebugMode) {
  print('Error: $error');
  print('Stack trace: $stackTrace');
}
```

### Step 2: Validate Data
```dart
// Check if data exists
final transaction = _db.getTransaction(transactionId);
if (transaction == null) {
  throw Exception('Transaction not found');
}

// Validate data integrity
if (transaction.amount <= 0) {
  throw Exception('Invalid transaction amount');
}
```

### Step 3: Test Database Operations
```dart
try {
  await _db.addTransaction(transaction);
  print('Database operation successful');
} catch (e) {
  print('Database operation failed: $e');
}
```

### Step 4: Check Provider State
```dart
// Verify provider is not in loading state
if (isLoading) {
  print('Provider is still loading');
  return;
}

// Check if data is available
if (transactions.isEmpty) {
  print('No transactions available');
}
```

## Error Recovery Strategies

### 1. Automatic Retry
```dart
Future<void> _retryOperation(Future<void> Function() operation, {int maxRetries = 3}) async {
  for (int i = 0; i < maxRetries; i++) {
    try {
      await operation();
      return;
    } catch (e) {
      if (i == maxRetries - 1) rethrow;
      await Future.delayed(Duration(seconds: i + 1));
    }
  }
}
```

### 2. Fallback Operations
```dart
try {
  await _createCreditCardTransaction(transaction);
} catch (e) {
  // Fallback: Log warning but continue
  if (kDebugMode) {
    print('Warning: Failed to create credit card transaction: $e');
  }
}
```

### 3. Data Validation
```dart
Future<void> _validateTransactionData(Transaction transaction) async {
  if (transaction.amount <= 0) {
    throw Exception('Invalid transaction amount');
  }
  
  final account = _db.getAccount(transaction.accountId);
  if (account == null) {
    throw Exception('Account not found');
  }
  
  if (account.isAsset && account.balance < transaction.amount) {
    throw Exception('Insufficient balance');
  }
}
```

### 4. State Recovery
```dart
Future<void> _recoverFromError() async {
  try {
    // Reset loading state
    _setLoading(false);
    
    // Refresh data
    await _loadTransactions();
    await _loadAccounts();
    
    // Notify listeners
    notifyListeners();
  } catch (e) {
    if (kDebugMode) {
      print('Error during recovery: $e');
    }
  }
}
```

## Best Practices

### 1. Error Message Guidelines
- Use clear, user-friendly language
- Include specific details when helpful
- Avoid technical jargon
- Provide actionable guidance

### 2. Logging Guidelines
- Log errors with context
- Include stack traces for debugging
- Use appropriate log levels
- Don't log sensitive information

### 3. Error Handling Patterns
- Always use try-catch blocks for async operations
- Set loading states appropriately
- Clean up resources in finally blocks
- Notify listeners after successful operations

### 4. Testing Error Scenarios
- Test with invalid data
- Test network failures
- Test database errors
- Test memory constraints

## Monitoring and Alerting

### Error Metrics to Track
- Error frequency by operation type
- Error recovery success rate
- User impact of errors
- Performance impact of error handling

### Alerting Thresholds
- Error rate > 5% for any operation
- Critical errors (data loss, corruption)
- Performance degradation
- User experience issues

## Conclusion

This error handling system provides robust protection against various failure scenarios while maintaining a good user experience. Regular monitoring and testing of error scenarios will help ensure the system remains reliable and user-friendly.

For additional support or questions about error handling, refer to the development team or check the application logs for detailed error information.
