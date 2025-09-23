// File location: lib/data/providers/bill_provider.dart
// Purpose: Provider for managing credit card bills and statements
// Author: Pown Kumar - Founder of Korelium
// Date: September 23, 2025

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/bill.dart';
import '../models/credit_card.dart';
import '../models/credit_card_transaction.dart';
import '../services/bill_generation_service.dart';
import '../services/hive_database_helper.dart';
import '../../core/error_handling/error_handler.dart';

/// Provider for managing credit card bills and statements
class BillProvider extends ChangeNotifier {
  final HiveDatabaseHelper _databaseHelper = HiveDatabaseHelper();
  final BillGenerationService _billService = BillGenerationService();
  
  List<Bill> _bills = [];
  bool _isLoading = false;
  String? _error;

  /// Get all bills
  List<Bill> get bills => _bills;

  /// Get bills for a specific credit card
  List<Bill> getBillsForCreditCard(String creditCardId) {
    return _bills.where((bill) => bill.creditCardId == creditCardId).toList();
  }

  /// Get latest bill for a credit card
  Bill? getLatestBillForCreditCard(String creditCardId) {
    final creditCardBills = getBillsForCreditCard(creditCardId);
    if (creditCardBills.isEmpty) return null;
    
    creditCardBills.sort((a, b) => b.billDate.compareTo(a.billDate));
    return creditCardBills.first;
  }

  /// Get pending bills (not paid)
  List<Bill> get pendingBills {
    return _bills.where((bill) => !bill.isPaid).toList();
  }

  /// Get overdue bills
  List<Bill> get overdueBills {
    return _bills.where((bill) => bill.isOverdue).toList();
  }

  /// Get bills due soon (within 3 days)
  List<Bill> get billsDueSoon {
    return _bills.where((bill) => bill.isDueSoon).toList();
  }

  /// Check if loading
  bool get isLoading => _isLoading;

  /// Get error message
  String? get error => _error;

  /// Initialize the provider and load bills
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _loadBills();
      _error = null;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error initializing BillProvider: $e');
      }
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Load bills from database
  Future<void> _loadBills() async {
    try {
      final billsBox = await _databaseHelper.billsBox;
      _bills = billsBox.values.toList();
      _bills.sort((a, b) => b.billDate.compareTo(a.billDate));
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error loading bills: $e');
      }
      rethrow;
    }
  }

  /// Generate a new bill for a credit card
  Future<Bill> generateBill({
    required String creditCardId,
    required CreditCard creditCard,
    required List<CreditCardTransaction> transactions,
    DateTime? statementPeriodStart,
    DateTime? statementPeriodEnd,
    String? notes,
  }) async {
    _setLoading(true);
    try {
      // Default to last 30 days if no period specified
      final endDate = statementPeriodEnd ?? DateTime.now();
      final startDate = statementPeriodStart ?? endDate.subtract(const Duration(days: 30));

      // Generate bill
      final bill = await _billService.generateBill(
        creditCardId: creditCardId,
        creditCard: creditCard,
        transactions: transactions,
        statementPeriodStart: startDate,
        statementPeriodEnd: endDate,
        notes: notes,
      );

      // Save to database
      await _saveBill(bill);
      
      // Add to local list
      _bills.insert(0, bill);
      
      _error = null;
      notifyListeners();
      return bill;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error generating bill: $e');
      }
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Save bill to database
  Future<void> _saveBill(Bill bill) async {
    try {
      final billsBox = await _databaseHelper.billsBox;
      await billsBox.put(bill.id, bill);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error saving bill: $e');
      }
      rethrow;
    }
  }

  /// Update bill status
  Future<void> updateBillStatus(String billId, BillStatus status) async {
    try {
      final billIndex = _bills.indexWhere((bill) => bill.id == billId);
      if (billIndex == -1) return;

      final updatedBill = _bills[billIndex].copyWith(status: status);
      _bills[billIndex] = updatedBill;

      // Save to database
      await _saveBill(updatedBill);
      
      notifyListeners();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error updating bill status: $e');
      }
      _error = e.toString();
    }
  }

  /// Mark bill as paid
  Future<void> markBillAsPaid(String billId, double paymentAmount) async {
    try {
      final billIndex = _bills.indexWhere((bill) => bill.id == billId);
      if (billIndex == -1) return;

      final updatedBill = _bills[billIndex].copyWith(
        status: BillStatus.paid,
        paymentDate: DateTime.now(),
        paymentAmount: paymentAmount,
      );
      
      _bills[billIndex] = updatedBill;

      // Save to database
      await _saveBill(updatedBill);
      
      notifyListeners();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error marking bill as paid: $e');
      }
      _error = e.toString();
    }
  }

  /// Delete bill
  Future<void> deleteBill(String billId) async {
    try {
      // Remove from local list
      _bills.removeWhere((bill) => bill.id == billId);

      // Remove from database
      final billsBox = await _databaseHelper.billsBox;
      await billsBox.delete(billId);
      
      notifyListeners();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error deleting bill: $e');
      }
      _error = e.toString();
    }
  }

  /// Refresh bills
  Future<void> refresh() async {
    await initialize();
  }

  /// Check for bills that need status updates
  Future<void> updateBillStatuses() async {
    try {
      bool hasChanges = false;
      
      for (int i = 0; i < _bills.length; i++) {
        final bill = _bills[i];
        BillStatus newStatus = bill.status;
        
        // Update status based on current date
        if (bill.status == BillStatus.pending && bill.isDueSoon) {
          newStatus = BillStatus.dueSoon;
        } else if (bill.status != BillStatus.paid && bill.isOverdue) {
          newStatus = BillStatus.overdue;
        }
        
        if (newStatus != bill.status) {
          _bills[i] = bill.copyWith(status: newStatus);
          await _saveBill(_bills[i]);
          hasChanges = true;
        }
      }
      
      if (hasChanges) {
        notifyListeners();
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error updating bill statuses: $e');
      }
    }
  }

  /// Get bill statistics
  Map<String, dynamic> getBillStatistics() {
    final totalBills = _bills.length;
    final paidBills = _bills.where((bill) => bill.isPaid).length;
    final pendingBills = _bills.where((bill) => bill.status == BillStatus.pending).length;
    final overdueBills = _bills.where((bill) => bill.isOverdue).length;
    final dueSoonBills = _bills.where((bill) => bill.isDueSoon).length;
    
    final totalAmount = _bills.fold(0.0, (sum, bill) => sum + bill.newBalance);
    final paidAmount = _bills.where((bill) => bill.isPaid).fold(0.0, (sum, bill) => sum + bill.newBalance);
    final pendingAmount = _bills.where((bill) => !bill.isPaid).fold(0.0, (sum, bill) => sum + bill.newBalance);
    
    return {
      'totalBills': totalBills,
      'paidBills': paidBills,
      'pendingBills': pendingBills,
      'overdueBills': overdueBills,
      'dueSoonBills': dueSoonBills,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'pendingAmount': pendingAmount,
    };
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
