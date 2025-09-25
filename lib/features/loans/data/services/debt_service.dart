import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/debt.dart';
import '../../../../data/models/account.dart';
import '../../../../data/services/hive_database_helper.dart';

class DebtService {
  static const String _debtsBoxName = 'debts';
  static const String _debtPaymentsBoxName = 'debt_payments';
  
  late Box<Debt> _debtsBox;
  late Box<DebtPayment> _debtPaymentsBox;
  late Box<Account> _accountsBox;
  
  final _uuid = const Uuid();

  /// Initialize the debt service
  Future<void> initialize() async {
    try {
      _debtsBox = await Hive.openBox<Debt>(_debtsBoxName);
      _debtPaymentsBox = await Hive.openBox<DebtPayment>(_debtPaymentsBoxName);
      _accountsBox = HiveDatabaseHelper().accountsBox;
    } catch (e) {
      print('Error initializing debt service: $e');
      rethrow;
    }
  }

  /// Get all debts
  List<Debt> getAllDebts() {
    try {
      return _debtsBox.values.toList();
    } catch (e) {
      print('Error getting all debts: $e');
      return [];
    }
  }

  /// Get debts where you owe money (isYouOwe = true) - including completed ones
  List<Debt> getDebtsYouOwe() {
    try {
      return _debtsBox.values.where((debt) => debt.isYouOwe).toList();
    } catch (e) {
      print('Error getting debts you owe: $e');
      return [];
    }
  }

  /// Get debts where others owe you money (isYouOwe = false) - including completed ones
  List<Debt> getDebtsOwedToYou() {
    try {
      return _debtsBox.values.where((debt) => !debt.isYouOwe).toList();
    } catch (e) {
      print('Error getting debts owed to you: $e');
      return [];
    }
  }

  /// Get debt by ID
  Debt? getDebtById(String id) {
    try {
      return _debtsBox.get(id);
    } catch (e) {
      print('Error getting debt by ID: $e');
      return null;
    }
  }

  /// Add a new debt
  Future<Debt> addDebt({
    required String personName,
    required double amount,
    required bool isYouOwe,
    DateTime? date,
    String? description,
    String? linkedAccountId,
  }) async {
    try {
      final now = DateTime.now();
      final debt = Debt(
        id: _uuid.v4(),
        personName: personName,
        amount: amount,
        paidAmount: 0.0,
        date: date ?? now,
        description: description,
        isYouOwe: isYouOwe,
        linkedAccountId: linkedAccountId,
        isPaidOff: false,
        createdAt: now,
        updatedAt: now,
      );

      await _debtsBox.put(debt.id, debt);

      // Update account balance if linked account is provided
      if (linkedAccountId != null) {
        final account = _accountsBox.get(linkedAccountId);
        if (account != null) {
          if (isYouOwe) {
            // When you owe money, it means you received the money, so add to your account
            final newBalance = account.balance + amount;
            final updatedAccount = account.copyWith(balance: newBalance);
            await _accountsBox.put(linkedAccountId, updatedAccount);
          } else {
            // When they owe you money, it means you already gave them money, so deduct from your account
            final newBalance = account.balance - amount;
            final updatedAccount = account.copyWith(balance: newBalance);
            await _accountsBox.put(linkedAccountId, updatedAccount);
          }
        }
      }

      return debt;
    } catch (e) {
      print('Error adding debt: $e');
      rethrow;
    }
  }

  /// Update a debt
  Future<Debt> updateDebt(Debt debt) async {
    try {
      // Get the original debt to compare changes
      final originalDebt = getDebtById(debt.id);
      
      final updatedDebt = debt.copyWith(updatedAt: DateTime.now());
      await _debtsBox.put(debt.id, updatedDebt);
      
      // Handle account balance changes if amount or linked account changed
      if (originalDebt != null && debt.linkedAccountId != null) {
        // If the amount changed, adjust account balance
        if (originalDebt.amount != debt.amount) {
          final amountDifference = debt.amount - originalDebt.amount;
          final account = _accountsBox.get(debt.linkedAccountId!);
          if (account != null) {
            if (debt.isYouOwe) {
              // When you owe money, add the difference to your account
              final newBalance = account.balance + amountDifference;
              final updatedAccount = account.copyWith(balance: newBalance);
              await _accountsBox.put(debt.linkedAccountId!, updatedAccount);
            } else {
              // When they owe you money, deduct the difference from your account
              final newBalance = account.balance - amountDifference;
              final updatedAccount = account.copyWith(balance: newBalance);
              await _accountsBox.put(debt.linkedAccountId!, updatedAccount);
            }
          }
        }
      }
      
      return updatedDebt;
    } catch (e) {
      print('Error updating debt: $e');
      rethrow;
    }
  }

  /// Delete a debt
  Future<void> deleteDebt(String debtId) async {
    try {
      // Get the debt before deleting to handle account balance reversal
      final debt = getDebtById(debtId);
      
      // Delete all payments for this debt first
      final payments = _debtPaymentsBox.values.where((payment) => payment.debtId == debtId).toList();
      for (final payment in payments) {
        await _debtPaymentsBox.delete(payment.id);
      }
      
      // Reverse account balance if this debt had a linked account
      if (debt != null && debt.linkedAccountId != null) {
        final account = _accountsBox.get(debt.linkedAccountId!);
        if (account != null) {
          if (debt.isYouOwe) {
            // When you owe money, subtract the original debt amount from account balance
            final newBalance = account.balance - debt.amount;
            final updatedAccount = account.copyWith(balance: newBalance);
            await _accountsBox.put(debt.linkedAccountId!, updatedAccount);
          } else {
            // When they owe you money, add the original debt amount back to account balance
            final newBalance = account.balance + debt.amount;
            final updatedAccount = account.copyWith(balance: newBalance);
            await _accountsBox.put(debt.linkedAccountId!, updatedAccount);
          }
        }
      }
      
      // Delete the debt
      await _debtsBox.delete(debtId);
    } catch (e) {
      print('Error deleting debt: $e');
      rethrow;
    }
  }

  /// Add a payment to a debt (reduces debt amount)
  Future<DebtPayment> addPayment({
    required String debtId,
    required double amount,
    DateTime? paymentDate,
    String? description,
    String? linkedAccountId,
  }) async {
    try {
      final debt = getDebtById(debtId);
      if (debt == null) {
        throw Exception('Debt not found');
      }

      final now = DateTime.now();
      final payment = DebtPayment(
        id: _uuid.v4(),
        debtId: debtId,
        amount: amount,
        paymentDate: paymentDate ?? now,
        description: description,
        linkedAccountId: linkedAccountId,
        createdAt: now,
        transactionType: 'payment',
      );

      // Add the payment
      await _debtPaymentsBox.put(payment.id, payment);

      // Update the debt's paid amount (reduces remaining debt)
      final newPaidAmount = debt.paidAmount + amount;
      final isPaidOff = newPaidAmount >= debt.amount;
      
      final updatedDebt = debt.copyWith(
        paidAmount: newPaidAmount,
        isPaidOff: isPaidOff,
        updatedAt: now,
      );
      
      await _debtsBox.put(debtId, updatedDebt);

      // Update account balance if linked account is provided
      if (linkedAccountId != null) {
        await _updateAccountBalance(linkedAccountId, amount, debt.isYouOwe);
      }

      return payment;
    } catch (e) {
      print('Error adding payment: $e');
      rethrow;
    }
  }

  /// Give money to someone (increases their debt to you)
  Future<DebtPayment> giveMoney({
    required String debtId,
    required double amount,
    DateTime? paymentDate,
    String? description,
    String? linkedAccountId,
  }) async {
    try {
      final debt = getDebtById(debtId);
      if (debt == null) {
        throw Exception('Debt not found');
      }

      final now = DateTime.now();
      final payment = DebtPayment(
        id: _uuid.v4(),
        debtId: debtId,
        amount: amount,
        paymentDate: paymentDate ?? now,
        description: description,
        linkedAccountId: linkedAccountId,
        createdAt: now,
        transactionType: 'give_money',
      );

      // Add the payment record
      await _debtPaymentsBox.put(payment.id, payment);

      // Update the debt's total amount (increases debt)
      final newTotalAmount = debt.amount + amount;
      final isPaidOff = debt.paidAmount >= newTotalAmount;
      
      final updatedDebt = debt.copyWith(
        amount: newTotalAmount,
        isPaidOff: isPaidOff,
        updatedAt: now,
      );
      
      await _debtsBox.put(debtId, updatedDebt);

      // Update account balance if linked account is provided
      if (linkedAccountId != null) {
        // When giving money, always deduct from your account
        final account = _accountsBox.get(linkedAccountId);
        if (account != null) {
          final newBalance = account.balance - amount;
          final updatedAccount = account.copyWith(balance: newBalance);
          await _accountsBox.put(linkedAccountId, updatedAccount);
        }
      }

      return payment;
    } catch (e) {
      print('Error giving money: $e');
      rethrow;
    }
  }

  /// Receive money from someone (increases your debt to them)
  Future<DebtPayment> receiveMoney({
    required String debtId,
    required double amount,
    DateTime? paymentDate,
    String? description,
    String? linkedAccountId,
  }) async {
    try {
      final debt = getDebtById(debtId);
      if (debt == null) {
        throw Exception('Debt not found');
      }

      final now = DateTime.now();
      final payment = DebtPayment(
        id: _uuid.v4(),
        debtId: debtId,
        amount: amount,
        paymentDate: paymentDate ?? now,
        description: description,
        linkedAccountId: linkedAccountId,
        createdAt: now,
        transactionType: 'receive_money',
      );

      // Add the payment record
      await _debtPaymentsBox.put(payment.id, payment);

      // Update the debt's total amount (increases debt)
      final newTotalAmount = debt.amount + amount;
      final isPaidOff = debt.paidAmount >= newTotalAmount;
      
      final updatedDebt = debt.copyWith(
        amount: newTotalAmount,
        isPaidOff: isPaidOff,
        updatedAt: now,
      );
      
      await _debtsBox.put(debtId, updatedDebt);

      // Update account balance if linked account is provided
      if (linkedAccountId != null) {
        // When receiving money, always add to your account
        final account = _accountsBox.get(linkedAccountId);
        if (account != null) {
          final newBalance = account.balance + amount;
          final updatedAccount = account.copyWith(balance: newBalance);
          await _accountsBox.put(linkedAccountId, updatedAccount);
        }
      }

      return payment;
    } catch (e) {
      print('Error receiving money: $e');
      rethrow;
    }
  }

  /// Get payments for a debt
  List<DebtPayment> getPaymentsForDebt(String debtId) {
    try {
      return _debtPaymentsBox.values
          .where((payment) => payment.debtId == debtId)
          .toList()
        ..sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
    } catch (e) {
      print('Error getting payments for debt: $e');
      return [];
    }
  }

  /// Delete a payment and completely undo the transaction
  Future<void> deletePayment(String paymentId) async {
    try {
      final payment = _debtPaymentsBox.get(paymentId);
      if (payment == null) return;

      final debt = getDebtById(payment.debtId);
      if (debt == null) return;

      // Remove the payment
      await _debtPaymentsBox.delete(paymentId);

      Debt updatedDebt;
      
      if (payment.transactionType == 'give_money' || payment.transactionType == 'receive_money') {
        // This was a "give money" or "receive money" transaction - reduce the total debt amount
        final newTotalAmount = debt.amount - payment.amount;
        final isPaidOff = debt.paidAmount >= newTotalAmount;
        
        updatedDebt = debt.copyWith(
          amount: newTotalAmount,
          isPaidOff: isPaidOff,
          updatedAt: DateTime.now(),
        );
      } else {
        // This was a regular payment (or old data with null transactionType) - reduce the paid amount
        final newPaidAmount = debt.paidAmount - payment.amount;
        final isPaidOff = newPaidAmount >= debt.amount;
        
        updatedDebt = debt.copyWith(
          paidAmount: newPaidAmount,
          isPaidOff: isPaidOff,
          updatedAt: DateTime.now(),
        );
      }
      
      await _debtsBox.put(payment.debtId, updatedDebt);

      // Update account balance - completely reverse the transaction
      if (payment.linkedAccountId != null) {
        if (payment.transactionType == 'give_money') {
          // Give money was deducted from account, so add it back
          await _updateAccountBalance(payment.linkedAccountId!, payment.amount, debt.isYouOwe);
        } else if (payment.transactionType == 'receive_money') {
          // Receive money was added to account, so deduct it back
          final account = _accountsBox.get(payment.linkedAccountId!);
          if (account != null) {
            final newBalance = account.balance - payment.amount;
            final updatedAccount = account.copyWith(balance: newBalance);
            await _accountsBox.put(payment.linkedAccountId!, updatedAccount);
          }
        } else {
          // Regular payment (or old data) was added to account, so deduct it back
          await _updateAccountBalance(payment.linkedAccountId!, -payment.amount, debt.isYouOwe);
        }
      }
    } catch (e) {
      print('Error deleting payment: $e');
      rethrow;
    }
  }

  /// Update account balance based on debt transaction
  Future<void> _updateAccountBalance(String accountId, double amount, bool isYouOwe) async {
    try {
      final account = _accountsBox.get(accountId);
      if (account == null) return;

      // If you owe money (isYouOwe = true), paying reduces your account balance
      // If others owe you (isYouOwe = false), receiving increases your account balance
      final balanceChange = isYouOwe ? -amount : amount;
      final newBalance = account.balance + balanceChange;

      final updatedAccount = account.copyWith(balance: newBalance);
      await _accountsBox.put(accountId, updatedAccount);
    } catch (e) {
      print('Error updating account balance: $e');
      rethrow;
    }
  }

  /// Fix corrupted debt calculations
  Future<void> fixCorruptedDebts() async {
    try {
      final allDebts = _debtsBox.values.toList();
      
      for (final debt in allDebts) {
        // Check if debt has invalid calculations
        if (debt.paidAmount > debt.amount || debt.remainingAmount < 0) {
          print('Fixing corrupted debt: ${debt.personName}');
          
          // Get all payments for this debt
          final payments = getPaymentsForDebt(debt.id);
          
          // Recalculate based on payment types
          double totalPaid = 0;
          double totalGiven = 0;
          
          for (final payment in payments) {
            if (payment.transactionType == 'give_money' || payment.transactionType == 'receive_money') {
              totalGiven += payment.amount;
            } else {
              // Old data with null transactionType or regular payments
              totalPaid += payment.amount;
            }
          }
          
          // Calculate the correct debt amount (original amount + money given)
          final originalAmount = debt.amount - totalGiven;
          
          // Fix the debt
          final correctTotalAmount = originalAmount + totalGiven;
          final fixedDebt = debt.copyWith(
            amount: correctTotalAmount,
            paidAmount: totalPaid,
            isPaidOff: totalPaid >= correctTotalAmount,
            updatedAt: DateTime.now(),
          );
          
          await _debtsBox.put(debt.id, fixedDebt);
        }
      }
    } catch (e) {
      print('Error fixing corrupted debts: $e');
    }
  }

  /// Get debt analytics
  Map<String, double> getDebtAnalytics() {
    try {
      final allDebts = getAllDebts();
      final debtsYouOwe = allDebts.where((debt) => debt.isYouOwe).toList();
      final debtsOwedToYou = allDebts.where((debt) => !debt.isYouOwe).toList();

      final totalYouOwe = debtsYouOwe.fold(0.0, (sum, debt) => sum + debt.amount);
      final totalPaidYouOwe = debtsYouOwe.fold(0.0, (sum, debt) => sum + debt.paidAmount);
      final remainingYouOwe = totalYouOwe - totalPaidYouOwe;

      final totalOwedToYou = debtsOwedToYou.fold(0.0, (sum, debt) => sum + debt.amount);
      final totalPaidOwedToYou = debtsOwedToYou.fold(0.0, (sum, debt) => sum + debt.paidAmount);
      final remainingOwedToYou = totalOwedToYou - totalPaidOwedToYou;

      return {
        'totalYouOwe': totalYouOwe,
        'paidYouOwe': totalPaidYouOwe,
        'remainingYouOwe': remainingYouOwe,
        'totalOwedToYou': totalOwedToYou,
        'paidOwedToYou': totalPaidOwedToYou,
        'remainingOwedToYou': remainingOwedToYou,
        'netDebt': remainingOwedToYou - remainingYouOwe, // Positive = you're owed more, Negative = you owe more
      };
    } catch (e) {
      print('Error getting debt analytics: $e');
      return {
        'totalYouOwe': 0.0,
        'paidYouOwe': 0.0,
        'remainingYouOwe': 0.0,
        'totalOwedToYou': 0.0,
        'paidOwedToYou': 0.0,
        'remainingOwedToYou': 0.0,
        'netDebt': 0.0,
      };
    }
  }

  /// Get all accounts for dropdown
  List<Account> getAccounts() {
    try {
      return _accountsBox.values.toList();
    } catch (e) {
      print('Error getting accounts: $e');
      return [];
    }
  }

  /// Close the service
  Future<void> close() async {
    try {
      await _debtsBox.close();
      await _debtPaymentsBox.close();
    } catch (e) {
      print('Error closing debt service: $e');
    }
  }
}
