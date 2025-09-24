# Error Handling Quick Reference

## Common Error Messages & Solutions

### Transaction Errors

| Error Message | Cause | Solution |
|---------------|-------|----------|
| `"Transaction not found"` | Trying to update/delete non-existent transaction | Check transaction ID, refresh data |
| `"Account not found"` | Account was deleted or doesn't exist | Verify account exists, refresh accounts |
| `"Transaction amount must be greater than 0"` | Invalid amount entered | Enter positive amount |
| `"Insufficient balance. This would result in a negative balance of X.XX"` | Not enough funds for transaction | Check account balance, reduce amount |
| `"Category not found"` | Category was deleted | Select valid category, refresh categories |

### Transfer Errors

| Error Message | Cause | Solution |
|---------------|-------|----------|
| `"Transfer amount must be greater than 0"` | Invalid transfer amount | Enter positive amount |
| `"Cannot transfer to the same account"` | Source and destination are same | Select different accounts |
| `"Transfer description cannot be empty"` | Missing description | Add transfer description |
| `"Source account not found"` | Source account deleted | Select valid source account |
| `"Destination account not found"` | Destination account deleted | Select valid destination account |
| `"Insufficient balance in source account. Available: X.XX, Required: Y.YY"` | Not enough funds | Check balance, reduce amount |

### Credit Card Errors

| Error Message | Cause | Solution |
|---------------|-------|----------|
| `"Credit card not found"` | Credit card deleted | Refresh credit cards, check account |
| `"Failed to create credit card transaction"` | Database issue | Check database, retry operation |
| `"Credit card balance update failed"` | Sync issue | Refresh credit card provider |

### System Errors

| Error Message | Cause | Solution |
|---------------|-------|----------|
| `"Database not initialized"` | Hive setup issue | Restart app, check initialization |
| `"Failed to load data"` | Database corruption | Clear app data, restart |
| `"Provider not initialized"` | State management issue | Refresh providers, restart app |

## Quick Fixes

### 1. Data Not Updating
```dart
// Refresh all providers
context.read<TransactionProviderHive>().refresh();
context.read<CreditCardProvider>().refresh();
context.read<CurrencyProvider>().refresh();
```

### 2. Balance Inconsistencies
```dart
// Recalculate balances
await transactionProvider.fixNegativeBalances();
await creditCardProvider.refresh();
```

### 3. UI Not Refreshing
```dart
// Force UI update
setState(() {});
// Or use provider refresh
context.read<TransactionProviderHive>().notifyListeners();
```

### 4. Database Issues
```dart
// Clear and reinitialize
await Hive.deleteFromDisk();
await Hive.initFlutter();
```

## Debug Commands

### Check Provider State
```dart
print('Transaction Provider Loading: ${transactionProvider.isLoading}');
print('Credit Card Provider Loading: ${creditCardProvider.isLoading}');
print('Transaction Count: ${transactionProvider.transactions.length}');
print('Account Count: ${transactionProvider.accounts.length}');
```

### Check Database State
```dart
final box = await Hive.openBox('transactions');
print('Database Size: ${box.length}');
print('Database Keys: ${box.keys.toList()}');
```

### Check Account Balances
```dart
for (final account in transactionProvider.accounts) {
  print('${account.name}: ${account.balance}');
}
```

## Emergency Recovery

### 1. Reset All Data
```dart
// Clear all Hive boxes
await Hive.deleteFromDisk();
// Restart app
```

### 2. Fix Corrupted Data
```dart
// Remove invalid transactions
final validTransactions = transactions.where((t) => t.amount > 0).toList();
// Update database
```

### 3. Restore from Backup
```dart
// If you have backup data
await _restoreFromBackup(backupData);
```

## Prevention Tips

1. **Always validate input** before processing
2. **Check account existence** before transactions
3. **Verify sufficient balance** for asset accounts
4. **Handle credit card operations** gracefully
5. **Use proper error boundaries** in UI
6. **Log errors** for debugging
7. **Test error scenarios** regularly

## Contact Information

For critical errors or data loss:
- Check application logs
- Review error handling documentation
- Contact development team
- Report bug with error details
