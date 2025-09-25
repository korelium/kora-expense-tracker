// File location: lib/data/providers/statement_provider.dart
// Purpose: Provider for managing credit card statement state and operations
// Author: Pown Kumar - Founder of Korelium
// Date: September 23, 2025

import 'package:flutter/material.dart';
import '../models/credit_card_statement.dart';
import '../../core/services/statement_generation_service.dart';

/// Provider for managing credit card statement state and operations
/// Handles statement generation, retrieval, and status updates
class StatementProvider extends ChangeNotifier {
  final StatementGenerationService _statementService = StatementGenerationService();
  
  List<CreditCardStatement> _statements = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<CreditCardStatement> get statements => List.unmodifiable(_statements);
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  /// Get statements for a specific credit card
  List<CreditCardStatement> getStatementsForCard(String creditCardId) {
    return _statements.where((statement) => statement.creditCardId == creditCardId).toList();
  }
  
  /// Get latest statement for a credit card
  CreditCardStatement? getLatestStatement(String creditCardId) {
    final cardStatements = getStatementsForCard(creditCardId);
    return cardStatements.isNotEmpty ? cardStatements.first : null;
  }
  
  /// Get overdue statements
  List<CreditCardStatement> get overdueStatements {
    return _statements.where((statement) => statement.isOverdue).toList();
  }
  
  /// Get statements due soon (within 7 days)
  List<CreditCardStatement> get statementsDueSoon {
    return _statements.where((statement) => statement.isDueSoon).toList();
  }
  
  /// Get paid statements
  List<CreditCardStatement> get paidStatements {
    return _statements.where((statement) => statement.status == StatementStatus.paid).toList();
  }
  
  /// Get generated statements (not yet paid)
  List<CreditCardStatement> get generatedStatements {
    return _statements.where((statement) => statement.status == StatementStatus.generated).toList();
  }

  /// Initialize and load all statements
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _loadAllStatements();
      debugPrint('StatementProvider initialized with ${_statements.length} statements');
    } catch (e) {
      _setError('Failed to initialize statements: $e');
      debugPrint('Error initializing StatementProvider: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load all statements from database
  Future<void> _loadAllStatements() async {
    try {
      // This would need to be implemented to get all statements
      // For now, we'll start with an empty list
      _statements = [];
      notifyListeners();
    } catch (e) {
      _setError('Failed to load statements: $e');
    }
  }

  /// Generate statement for a specific credit card and month
  Future<CreditCardStatement?> generateStatement({
    required String creditCardId,
    required int year,
    required int month,
  }) async {
    _setLoading(true);
    try {
      final statement = await _statementService.generateStatement(
        creditCardId: creditCardId,
        year: year,
        month: month,
      );
      
      if (statement != null) {
        _statements.add(statement);
        _statements.sort((a, b) => b.statementDate.compareTo(a.statementDate));
        notifyListeners();
        debugPrint('Statement generated successfully: ${statement.id}');
      }
      
      return statement;
    } catch (e) {
      _setError('Failed to generate statement: $e');
      debugPrint('Error generating statement: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Generate statements for all active credit cards for current month
  Future<List<CreditCardStatement>> generateCurrentMonthStatements() async {
    _setLoading(true);
    try {
      final statements = await _statementService.generateCurrentMonthStatements();
      
      // Add new statements to the list
      for (final statement in statements) {
        if (!_statements.any((s) => s.id == statement.id)) {
          _statements.add(statement);
        }
      }
      
      _statements.sort((a, b) => b.statementDate.compareTo(a.statementDate));
      notifyListeners();
      
      debugPrint('Generated ${statements.length} statements for current month');
      return statements;
    } catch (e) {
      _setError('Failed to generate current month statements: $e');
      debugPrint('Error generating current month statements: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  /// Load statements for a specific credit card
  Future<void> loadStatementsForCard(String creditCardId) async {
    _setLoading(true);
    try {
      final statements = await _statementService.getStatementsForCard(creditCardId);
      
      // Remove existing statements for this card
      _statements.removeWhere((s) => s.creditCardId == creditCardId);
      
      // Add new statements
      _statements.addAll(statements);
      _statements.sort((a, b) => b.statementDate.compareTo(a.statementDate));
      
      notifyListeners();
      debugPrint('Loaded ${statements.length} statements for card: $creditCardId');
    } catch (e) {
      _setError('Failed to load statements for card: $e');
      debugPrint('Error loading statements for card: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Update statement status (e.g., when payment is made)
  Future<void> updateStatementStatus(
    String statementId,
    StatementStatus status, {
    double? paymentAmount,
  }) async {
    try {
      await _statementService.updateStatementStatus(
        statementId,
        status,
        paymentAmount: paymentAmount,
      );
      
      // Update local statement
      final index = _statements.indexWhere((s) => s.id == statementId);
      if (index != -1) {
        _statements[index] = _statements[index].copyWith(
          status: status,
          paidAt: status == StatementStatus.paid ? DateTime.now() : _statements[index].paidAt,
          paymentAmount: paymentAmount ?? _statements[index].paymentAmount,
        );
        notifyListeners();
      }
      
      debugPrint('Statement status updated: $statementId -> ${status.name}');
    } catch (e) {
      _setError('Failed to update statement status: $e');
      debugPrint('Error updating statement status: $e');
    }
  }

  /// Delete statement
  Future<void> deleteStatement(String statementId) async {
    try {
      await _statementService.deleteStatement(statementId);
      
      // Remove from local list
      _statements.removeWhere((s) => s.id == statementId);
      notifyListeners();
      
      debugPrint('Statement deleted: $statementId');
    } catch (e) {
      _setError('Failed to delete statement: $e');
      debugPrint('Error deleting statement: $e');
    }
  }

  /// Refresh all statements
  Future<void> refresh() async {
    await _loadAllStatements();
  }

  /// Get statement by ID
  CreditCardStatement? getStatementById(String statementId) {
    try {
      return _statements.firstWhere((s) => s.id == statementId);
    } catch (e) {
      return null;
    }
  }

  /// Get statements for a specific year
  List<CreditCardStatement> getStatementsForYear(int year) {
    return _statements.where((statement) => statement.statementDate.year == year).toList();
  }

  /// Get statements for a specific month and year
  List<CreditCardStatement> getStatementsForMonth(int year, int month) {
    return _statements.where((statement) => 
      statement.statementDate.year == year && 
      statement.statementDate.month == month
    ).toList();
  }

  /// Get total outstanding balance across all statements
  double get totalOutstandingBalance {
    return _statements
        .where((s) => s.status != StatementStatus.paid)
        .fold(0.0, (sum, statement) => sum + statement.newBalance);
  }

  /// Get total minimum payment due across all statements
  double get totalMinimumPaymentDue {
    return _statements
        .where((s) => s.status != StatementStatus.paid)
        .fold(0.0, (sum, statement) => sum + statement.minimumPayment);
  }

  /// Get statements count by status
  Map<StatementStatus, int> get statementsCountByStatus {
    final Map<StatementStatus, int> counts = {};
    
    for (final status in StatementStatus.values) {
      counts[status] = _statements.where((s) => s.status == status).length;
    }
    
    return counts;
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error state
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
