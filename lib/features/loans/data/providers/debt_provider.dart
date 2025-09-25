import 'package:flutter/foundation.dart';
import '../models/debt.dart';
import '../services/debt_service.dart';
import '../../../../data/models/account.dart';

class DebtProvider extends ChangeNotifier {
  final DebtService _debtService = DebtService();
  
  List<Debt> _debts = [];
  List<Debt> _debtsYouOwe = [];
  List<Debt> _debtsOwedToYou = [];
  Map<String, double> _analytics = {};
  bool _isInitialized = false;

  // Getters
  List<Debt> get debts => _debts;
  List<Debt> get debtsYouOwe => _debtsYouOwe;
  List<Debt> get debtsOwedToYou => _debtsOwedToYou;
  Map<String, double> get analytics => _analytics;
  bool get isInitialized => _isInitialized;

  /// Initialize the debt provider
  Future<void> initialize() async {
    try {
      await _debtService.initialize();
      await _loadDebts();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error initializing debt provider: $e');
      _isInitialized = false;
    }
  }

  /// Load all debts from the service
  Future<void> _loadDebts() async {
    try {
      _debts = _debtService.getAllDebts();
      _debtsYouOwe = _debtService.getDebtsYouOwe();
      _debtsOwedToYou = _debtService.getDebtsOwedToYou();
      _analytics = _debtService.getDebtAnalytics();
    } catch (e) {
      print('Error loading debts: $e');
    }
  }

  /// Add a new debt
  Future<Debt?> addDebt({
    required String personName,
    required double amount,
    required bool isYouOwe,
    DateTime? date,
    String? description,
    String? linkedAccountId,
  }) async {
    try {
      final debt = await _debtService.addDebt(
        personName: personName,
        amount: amount,
        isYouOwe: isYouOwe,
        date: date,
        description: description,
        linkedAccountId: linkedAccountId,
      );
      
      await _loadDebts();
      notifyListeners();
      return debt;
    } catch (e) {
      print('Error adding debt: $e');
      return null;
    }
  }

  /// Update a debt
  Future<bool> updateDebt(Debt debt) async {
    try {
      await _debtService.updateDebt(debt);
      await _loadDebts();
      notifyListeners();
      return true;
    } catch (e) {
      print('Error updating debt: $e');
      return false;
    }
  }

  /// Delete a debt
  Future<bool> deleteDebt(String debtId) async {
    try {
      await _debtService.deleteDebt(debtId);
      await _loadDebts();
      notifyListeners();
      return true;
    } catch (e) {
      print('Error deleting debt: $e');
      return false;
    }
  }

  /// Add a payment to a debt (reduces debt amount)
  Future<DebtPayment?> addPayment({
    required String debtId,
    required double amount,
    DateTime? paymentDate,
    String? description,
    String? linkedAccountId,
  }) async {
    try {
      final payment = await _debtService.addPayment(
        debtId: debtId,
        amount: amount,
        paymentDate: paymentDate,
        description: description,
        linkedAccountId: linkedAccountId,
      );
      
      await _loadDebts();
      notifyListeners();
      return payment;
    } catch (e) {
      print('Error adding payment: $e');
      return null;
    }
  }

  /// Give money to someone (increases their debt to you)
  Future<DebtPayment?> giveMoney({
    required String debtId,
    required double amount,
    DateTime? paymentDate,
    String? description,
    String? linkedAccountId,
  }) async {
    try {
      final payment = await _debtService.giveMoney(
        debtId: debtId,
        amount: amount,
        paymentDate: paymentDate,
        description: description,
        linkedAccountId: linkedAccountId,
      );
      
      await _loadDebts();
      notifyListeners();
      return payment;
    } catch (e) {
      print('Error giving money: $e');
      return null;
    }
  }

  /// Receive money from someone (increases your debt to them)
  Future<DebtPayment?> receiveMoney({
    required String debtId,
    required double amount,
    DateTime? paymentDate,
    String? description,
    String? linkedAccountId,
  }) async {
    try {
      final payment = await _debtService.receiveMoney(
        debtId: debtId,
        amount: amount,
        paymentDate: paymentDate,
        description: description,
        linkedAccountId: linkedAccountId,
      );
      
      await _loadDebts();
      notifyListeners();
      return payment;
    } catch (e) {
      print('Error receiving money: $e');
      return null;
    }
  }

  /// Fix corrupted debt calculations
  Future<void> fixCorruptedDebts() async {
    try {
      await _debtService.fixCorruptedDebts();
      await _loadDebts();
      notifyListeners();
    } catch (e) {
      print('Error fixing corrupted debts: $e');
    }
  }

  /// Get payments for a debt
  List<DebtPayment> getPaymentsForDebt(String debtId) {
    try {
      return _debtService.getPaymentsForDebt(debtId);
    } catch (e) {
      print('Error getting payments for debt: $e');
      return [];
    }
  }

  /// Delete a payment
  Future<bool> deletePayment(String paymentId) async {
    try {
      await _debtService.deletePayment(paymentId);
      await _loadDebts();
      notifyListeners();
      return true;
    } catch (e) {
      print('Error deleting payment: $e');
      return false;
    }
  }

  /// Get debt by ID
  Debt? getDebtById(String id) {
    try {
      return _debtService.getDebtById(id);
    } catch (e) {
      print('Error getting debt by ID: $e');
      return null;
    }
  }

  /// Get all accounts
  List<Account> getAccounts() {
    try {
      return _debtService.getAccounts();
    } catch (e) {
      print('Error getting accounts: $e');
      return [];
    }
  }

  /// Refresh debts data
  Future<void> refresh() async {
    await _loadDebts();
    notifyListeners();
  }

  @override
  void dispose() {
    _debtService.close();
    super.dispose();
  }
}
