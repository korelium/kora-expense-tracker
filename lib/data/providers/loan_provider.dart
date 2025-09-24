// File location: lib/data/providers/loan_provider.dart
// Purpose: Provider for managing loans and loan payments
// Author: Pown Kumar - Founder of Korelium
// Date: September 24, 2025

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/loan.dart';
import '../models/loan_payment.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../services/hive_database_helper.dart';

/// Provider for managing loans and loan payments
class LoanProvider extends ChangeNotifier {
  final HiveDatabaseHelper _databaseHelper = HiveDatabaseHelper();
  
  // ===== PRIVATE FIELDS =====
  bool _isLoading = false;
  List<Loan> _loans = [];
  List<LoanPayment> _loanPayments = [];

  // ===== GETTERS =====
  bool get isLoading => _isLoading;
  List<Loan> get loans => _loans;
  List<LoanPayment> get loanPayments => _loanPayments;
  
  /// Get active loans only
  List<Loan> get activeLoans => _loans.where((loan) => loan.isActive).toList();
  
  /// Get overdue loans
  List<Loan> get overdueLoans => _loans.where((loan) => loan.isOverdue).toList();
  
  /// Get loans due soon (within 7 days)
  List<Loan> get loansDueSoon => _loans.where((loan) => loan.daysUntilNextPayment <= 7 && loan.daysUntilNextPayment >= 0).toList();
  
  /// Get total outstanding loan balance
  double get totalOutstandingBalance {
    return activeLoans.fold(0.0, (sum, loan) => sum + loan.currentBalance);
  }
  
  /// Get total monthly loan payments
  double get totalMonthlyPayments {
    return activeLoans.fold(0.0, (sum, loan) => sum + loan.monthlyPayment);
  }

  // ===== INITIALIZATION =====
  
  /// Initialize the loan provider
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _loadLoans();
      await _loadLoanPayments();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing loan provider: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  // ===== LOAN METHODS =====
  
  /// Add a new loan
  Future<void> addLoan(Loan loan) async {
    _setLoading(true);
    try {
      await _databaseHelper.addLoan(loan);
      await _loadLoans();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error adding loan: $e');
      }
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Update an existing loan
  Future<void> updateLoan(Loan loan) async {
    _setLoading(true);
    try {
      final updatedLoan = loan.copyWith(updatedAt: DateTime.now());
      await _databaseHelper.updateLoan(updatedLoan);
      await _loadLoans();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error updating loan: $e');
      }
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a loan
  Future<void> deleteLoan(String loanId) async {
    _setLoading(true);
    try {
      await _databaseHelper.deleteLoan(loanId);
      await _loadLoans();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting loan: $e');
      }
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Get loan by ID
  Loan? getLoan(String loanId) {
    try {
      return _loans.firstWhere((loan) => loan.id == loanId);
    } catch (e) {
      return null;
    }
  }

  /// Get loans by type
  List<Loan> getLoansByType(LoanType type) {
    return _loans.where((loan) => loan.type == type).toList();
  }

  /// Calculate loan payment breakdown
  Map<String, double> calculatePaymentBreakdown(Loan loan, double paymentAmount) {
    final interestAmount = (loan.currentBalance * loan.interestRate / 100) / 12;
    final principalAmount = paymentAmount - interestAmount;
    
    return {
      'principal': principalAmount,
      'interest': interestAmount,
      'total': paymentAmount,
    };
  }

  // ===== LOAN PAYMENT METHODS =====
  
  /// Add a loan payment
  Future<void> addLoanPayment(LoanPayment payment) async {
    _setLoading(true);
    try {
      await _databaseHelper.addLoanPayment(payment);
      
      // Update the loan balance
      final loan = getLoan(payment.loanId);
      if (loan != null) {
        final newBalance = loan.currentBalance - payment.principalAmount;
        final updatedLoan = loan.copyWith(
          currentBalance: newBalance,
          nextPaymentDate: _calculateNextPaymentDate(loan, payment.paymentDate),
          updatedAt: DateTime.now(),
        );
        await updateLoan(updatedLoan);
      }
      
      await _loadLoanPayments();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error adding loan payment: $e');
      }
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Update a loan payment
  Future<void> updateLoanPayment(LoanPayment payment) async {
    _setLoading(true);
    try {
      await _databaseHelper.updateLoanPayment(payment);
      await _loadLoanPayments();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error updating loan payment: $e');
      }
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a loan payment
  Future<void> deleteLoanPayment(String paymentId) async {
    _setLoading(true);
    try {
      final payment = getLoanPayment(paymentId);
      if (payment != null) {
        // Reverse the loan balance update
        final loan = getLoan(payment.loanId);
        if (loan != null) {
          final newBalance = loan.currentBalance + payment.principalAmount;
          final updatedLoan = loan.copyWith(
            currentBalance: newBalance,
            updatedAt: DateTime.now(),
          );
          await updateLoan(updatedLoan);
        }
      }
      
      await _databaseHelper.deleteLoanPayment(paymentId);
      await _loadLoanPayments();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting loan payment: $e');
      }
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Get loan payment by ID
  LoanPayment? getLoanPayment(String paymentId) {
    try {
      return _loanPayments.firstWhere((payment) => payment.id == paymentId);
    } catch (e) {
      return null;
    }
  }

  /// Get payments for a specific loan
  List<LoanPayment> getPaymentsForLoan(String loanId) {
    return _loanPayments.where((payment) => payment.loanId == loanId).toList();
  }

  /// Get payments by status
  List<LoanPayment> getPaymentsByStatus(PaymentStatus status) {
    return _loanPayments.where((payment) => payment.status == status).toList();
  }

  /// Get overdue payments
  List<LoanPayment> get overduePayments {
    return _loanPayments.where((payment) => payment.isOverdue).toList();
  }

  /// Get payments due soon
  List<LoanPayment> get paymentsDueSoon {
    return _loanPayments.where((payment) => payment.isDueSoon).toList();
  }

  // ===== UTILITY METHODS =====
  
  /// Make a loan payment and create corresponding transaction
  Future<void> makeLoanPayment({
    required String loanId,
    required double amount,
    required String accountId,
    required PaymentMethod paymentMethod,
    String? notes,
    bool isExtraPayment = false,
  }) async {
    _setLoading(true);
    try {
      final loan = getLoan(loanId);
      if (loan == null) {
        throw Exception('Loan not found');
      }

      // Calculate payment breakdown
      final breakdown = calculatePaymentBreakdown(loan, amount);
      
      // Create loan payment
      final payment = LoanPayment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        loanId: loanId,
        amount: amount,
        principalAmount: breakdown['principal']!,
        interestAmount: breakdown['interest']!,
        paymentDate: DateTime.now(),
        dueDate: loan.nextPaymentDate,
        paymentMethod: paymentMethod,
        accountId: accountId,
        status: PaymentStatus.completed,
        notes: notes,
        isExtraPayment: isExtraPayment,
        createdAt: DateTime.now(),
      );

      // Create corresponding transaction
      final transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_loan',
        accountId: accountId,
        categoryId: 'loan_payment', // We'll need to create this category
        amount: amount,
        type: TransactionType.expense,
        description: 'Loan payment - ${loan.name}',
        date: DateTime.now(),
      );

      // Add both payment and transaction
      await addLoanPayment(payment);
      // Note: We would need to add the transaction through TransactionProviderHive
      // This would require dependency injection or a different architecture
      
    } catch (e) {
      if (kDebugMode) {
        print('Error making loan payment: $e');
      }
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Calculate next payment date
  DateTime _calculateNextPaymentDate(Loan loan, DateTime currentPaymentDate) {
    // Add one month to the current payment date
    final nextMonth = DateTime(
      currentPaymentDate.year,
      currentPaymentDate.month + 1,
      currentPaymentDate.day,
    );
    return nextMonth;
  }

  /// Get loan analytics
  Map<String, dynamic> getLoanAnalytics() {
    final activeLoans = this.activeLoans;
    final totalBalance = totalOutstandingBalance;
    final totalMonthly = totalMonthlyPayments;
    
    // Calculate average interest rate
    final avgInterestRate = activeLoans.isEmpty 
        ? 0.0 
        : activeLoans.fold(0.0, (sum, loan) => sum + loan.interestRate) / activeLoans.length;
    
    // Calculate total interest paid
    final totalInterestPaid = activeLoans.fold(0.0, (sum, loan) => sum + loan.totalInterestPaid);
    
    // Calculate total interest over term
    final totalInterestOverTerm = activeLoans.fold(0.0, (sum, loan) => sum + loan.totalInterestOverTerm);
    
    return {
      'totalLoans': activeLoans.length,
      'totalBalance': totalBalance,
      'totalMonthlyPayments': totalMonthly,
      'averageInterestRate': avgInterestRate,
      'totalInterestPaid': totalInterestPaid,
      'totalInterestOverTerm': totalInterestOverTerm,
      'overdueLoans': overdueLoans.length,
      'loansDueSoon': loansDueSoon.length,
    };
  }

  // ===== PRIVATE METHODS =====
  
  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Load loans from database
  Future<void> _loadLoans() async {
    try {
      _loans = await _databaseHelper.getLoans();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading loans: $e');
      }
      _loans = [];
    }
  }

  /// Load loan payments from database
  Future<void> _loadLoanPayments() async {
    try {
      _loanPayments = await _databaseHelper.getLoanPayments();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading loan payments: $e');
      }
      _loanPayments = [];
    }
  }

  /// Refresh data
  Future<void> refresh() async {
    await initialize();
  }
}
