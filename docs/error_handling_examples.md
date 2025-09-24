# Error Handling Examples

## Using ErrorUtils in Your Code

### Example 1: Transaction Creation with Error Handling

```dart
import '../core/error_handling/error_utils.dart';

Future<void> addTransaction(Transaction transaction) async {
  _setLoading(true);
  
  try {
    // Validate transaction data
    final validationError = ErrorUtils.validateTransaction(
      amount: transaction.amount,
      accountId: transaction.accountId,
      categoryId: transaction.categoryId,
      description: transaction.description,
    );
    
    if (validationError != null) {
      throw Exception(validationError);
    }
    
    // Use retry mechanism for database operations
    await ErrorUtils.retryOperation(
      () async {
        await _db.addTransaction(transaction);
        await _updateAccountBalance(transaction);
      },
      maxRetries: 3,
    );
    
    // Handle credit card transaction creation safely
    await ErrorUtils.safeExecute(
      () => _createCreditCardTransaction(transaction),
      operationName: 'Credit Card Transaction Creation',
    );
    
    notifyListeners();
    
  } catch (e) {
    ErrorUtils.logError(
      e,
      context: 'addTransaction',
      additionalData: {
        'transactionId': transaction.id,
        'accountId': transaction.accountId,
        'amount': transaction.amount,
      },
    );
    
    // Show user-friendly error message
    final userMessage = ErrorUtils.getUserFriendlyMessage(e);
    throw Exception(userMessage);
    
  } finally {
    _setLoading(false);
  }
}
```

### Example 2: Transfer with Comprehensive Error Handling

```dart
Future<void> addTransfer({
  required String fromAccountId,
  required String toAccountId,
  required double amount,
  required String description,
}) async {
  _setLoading(true);
  
  try {
    // Validate transfer data
    final validationError = ErrorUtils.validateTransfer(
      amount: amount,
      fromAccountId: fromAccountId,
      toAccountId: toAccountId,
      description: description,
    );
    
    if (validationError != null) {
      throw Exception(validationError);
    }
    
    // Execute multiple operations safely
    final results = await ErrorUtils.executeMultiple([
      () => _createExpenseTransaction(fromAccountId, amount, description),
      () => _createIncomeTransaction(toAccountId, amount, description),
      () => _updateAccountBalances(fromAccountId, toAccountId, amount),
    ], operationName: 'Transfer Operations');
    
    // Check if any critical operations failed
    if (results.any((result) => result == null)) {
      throw Exception('Transfer operation failed');
    }
    
    // Handle credit card transactions safely
    await ErrorUtils.safeExecute(
      () => _createCreditCardTransactions(fromAccountId, toAccountId, amount),
      operationName: 'Credit Card Transfer Records',
    );
    
    notifyListeners();
    
  } catch (e) {
    final severity = ErrorUtils.getErrorSeverity(e);
    final formattedMessage = ErrorUtils.formatErrorForDisplay(e);
    
    ErrorUtils.logError(
      e,
      context: 'addTransfer',
      additionalData: {
        'fromAccountId': fromAccountId,
        'toAccountId': toAccountId,
        'amount': amount,
        'severity': severity.toString(),
      },
    );
    
    // Handle based on severity
    switch (severity) {
      case ErrorSeverity.critical:
        // Show critical error dialog
        _showCriticalErrorDialog(formattedMessage);
        break;
      case ErrorSeverity.high:
        // Show error snackbar
        _showErrorSnackBar(formattedMessage);
        break;
      case ErrorSeverity.medium:
        // Show warning
        _showWarning(formattedMessage);
        break;
      case ErrorSeverity.low:
        // Show info message
        _showInfo(formattedMessage);
        break;
    }
    
    rethrow;
    
  } finally {
    _setLoading(false);
  }
}
```

### Example 3: UI Error Handling

```dart
class TransactionForm extends StatefulWidget {
  @override
  _TransactionFormState createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _submitTransaction() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final transaction = Transaction(
        // ... transaction data
      );

      await context.read<TransactionProviderHive>().addTransaction(transaction);
      
      // Success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transaction added successfully'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context);
      
    } catch (e) {
      final userMessage = ErrorUtils.getUserFriendlyMessage(e);
      final severity = ErrorUtils.getErrorSeverity(e);
      
      setState(() {
        _errorMessage = userMessage;
      });
      
      // Log error with context
      ErrorUtils.logError(
        e,
        context: 'TransactionForm.submitTransaction',
        additionalData: {
          'formData': _getFormData(),
        },
      );
      
      // Show appropriate error UI
      _showErrorUI(severity, userMessage);
      
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorUI(ErrorSeverity severity, String message) {
    switch (severity) {
      case ErrorSeverity.critical:
        _showCriticalErrorDialog(message);
        break;
      case ErrorSeverity.high:
        _showErrorSnackBar(message);
        break;
      case ErrorSeverity.medium:
        _showWarningSnackBar(message);
        break;
      case ErrorSeverity.low:
        _showInfoSnackBar(message);
        break;
    }
  }

  void _showCriticalErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Critical Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: _submitTransaction,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Form fields...
          
          if (_errorMessage != null)
            Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                ],
              ),
            ),
          
          ElevatedButton(
            onPressed: _isLoading ? null : _submitTransaction,
            child: _isLoading
                ? CircularProgressIndicator()
                : Text('Submit Transaction'),
          ),
        ],
      ),
    );
  }
}
```

### Example 4: Error Recovery in Credit Card Operations

```dart
Future<void> _handleCreditCardTransactionError(
  Transaction transaction,
  dynamic error,
) async {
  final severity = ErrorUtils.getErrorSeverity(error);
  
  if (severity == ErrorSeverity.critical) {
    // Critical error - abort operation
    throw Exception('Credit card operation failed: ${error.toString()}');
  }
  
  if (severity == ErrorSeverity.high) {
    // High severity - try recovery
    final recovered = await ErrorUtils.retryOperation(
      () => _createCreditCardTransaction(transaction),
      maxRetries: 2,
    );
    
    if (!recovered) {
      // Recovery failed - log and continue without credit card record
      ErrorUtils.logError(
        error,
        context: 'CreditCardTransactionRecovery',
        additionalData: {
          'transactionId': transaction.id,
          'recoveryAttempted': true,
        },
      );
    }
  }
  
  // Medium/Low severity - log and continue
  ErrorUtils.logError(
    error,
    context: 'CreditCardTransaction',
    additionalData: {
      'transactionId': transaction.id,
      'severity': severity.toString(),
    },
  );
}
```

## Best Practices

### 1. Always Use ErrorUtils for Validation
```dart
// Good
final error = ErrorUtils.validateTransaction(/* ... */);
if (error != null) throw Exception(error);

// Bad
if (amount <= 0) throw Exception('Invalid amount');
```

### 2. Log Errors with Context
```dart
// Good
ErrorUtils.logError(
  e,
  context: 'addTransaction',
  additionalData: {'transactionId': transaction.id},
);

// Bad
print('Error: $e');
```

### 3. Use Appropriate Error Severity
```dart
// Good
final severity = ErrorUtils.getErrorSeverity(e);
switch (severity) {
  case ErrorSeverity.critical:
    // Handle critical error
    break;
  // ...
}

// Bad
// Always treat all errors the same way
```

### 4. Provide User-Friendly Messages
```dart
// Good
final userMessage = ErrorUtils.getUserFriendlyMessage(e);
showErrorSnackBar(userMessage);

// Bad
showErrorSnackBar(e.toString());
```

### 5. Use Safe Execution for Non-Critical Operations
```dart
// Good
await ErrorUtils.safeExecute(
  () => _createCreditCardTransaction(transaction),
  operationName: 'Credit Card Transaction Creation',
);

// Bad
try {
  await _createCreditCardTransaction(transaction);
} catch (e) {
  // Ignore error
}
```

This error handling system will help you maintain a robust and user-friendly application with proper error recovery and logging capabilities.
