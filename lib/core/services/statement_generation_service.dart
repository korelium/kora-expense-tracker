// File location: lib/core/services/statement_generation_service.dart
// Purpose: Service for generating credit card statements based on billing cycles
// Author: Pown Kumar - Founder of Korelium
// Date: September 23, 2025

import 'package:flutter/foundation.dart';
import '../../data/models/credit_card.dart';
import '../../data/models/credit_card_statement.dart';
import '../../data/models/transaction.dart';
import '../../data/services/hive_database_helper.dart';

/// Service for generating credit card statements
/// Handles billing cycle calculations and statement data generation
class StatementGenerationService {
  final HiveDatabaseHelper _databaseHelper = HiveDatabaseHelper();

  /// Generate statement for a credit card for a specific month
  /// Returns null if statement already exists for that period
  Future<CreditCardStatement?> generateStatement({
    required String creditCardId,
    required int year,
    required int month,
  }) async {
    try {
      // Get credit card data
      final creditCard = await _getCreditCard(creditCardId);
      if (creditCard == null) {
        debugPrint('Credit card not found: $creditCardId');
        return null;
      }

      // Check if statement already exists for this period
      final existingStatement = await _getExistingStatement(creditCardId, year, month);
      if (existingStatement != null) {
        debugPrint('Statement already exists for $year-$month');
        return existingStatement;
      }

      // Calculate billing cycle dates
      final cycleDates = _calculateBillingCycleDates(
        creditCard.statementGenerationDay,
        year,
        month,
      );

      // Get transactions for the billing cycle
      final transactions = await _getTransactionsForCycle(
        creditCardId,
        cycleDates['start']!,
        cycleDates['end']!,
      );

      // Calculate statement data
      final statementData = await _calculateStatementData(
        creditCard,
        transactions,
        cycleDates,
      );

      // Create statement
      final statement = CreditCardStatement(
        id: '${creditCardId}_${year}_${month.toString().padLeft(2, '0')}',
        creditCardId: creditCardId,
        statementDate: cycleDates['statement']!,
        cycleStartDate: cycleDates['start']!,
        cycleEndDate: cycleDates['end']!,
        dueDate: cycleDates['due']!,
        previousBalance: statementData['previousBalance']!,
        totalPurchases: statementData['totalPurchases']!,
        totalPayments: statementData['totalPayments']!,
        totalFees: statementData['totalFees']!,
        totalInterest: statementData['totalInterest']!,
        newBalance: statementData['newBalance']!,
        minimumPayment: statementData['minimumPayment']!,
        creditLimit: creditCard.creditLimit,
        availableCredit: statementData['availableCredit']!,
        creditUtilization: statementData['creditUtilization']!,
        transactionIds: statementData['transactionIds']!,
        status: StatementStatus.generated,
        generatedAt: DateTime.now(),
      );

      // Save statement to database
      await _saveStatement(statement);

      debugPrint('Statement generated successfully for $creditCardId');
      return statement;
    } catch (e) {
      debugPrint('Error generating statement: $e');
      return null;
    }
  }

  /// Generate statements for all active credit cards for current month
  Future<List<CreditCardStatement>> generateCurrentMonthStatements() async {
    try {
      final creditCards = await _getActiveCreditCards();
      final currentDate = DateTime.now();
      final statements = <CreditCardStatement>[];

      for (final creditCard in creditCards) {
        final statement = await generateStatement(
          creditCardId: creditCard.id,
          year: currentDate.year,
          month: currentDate.month,
        );
        
        if (statement != null) {
          statements.add(statement);
        }
      }

      return statements;
    } catch (e) {
      debugPrint('Error generating current month statements: $e');
      return [];
    }
  }

  /// Get all statements for a credit card
  Future<List<CreditCardStatement>> getStatementsForCard(String creditCardId) async {
    try {
      final statementsBox = await _databaseHelper.creditCardStatementsBox;
      final statements = statementsBox.values
          .cast<CreditCardStatement>()
          .where((statement) => statement.creditCardId == creditCardId)
          .toList();
      
      // Sort by statement date (newest first)
      statements.sort((a, b) => b.statementDate.compareTo(a.statementDate));
      return statements;
    } catch (e) {
      debugPrint('Error getting statements for card: $e');
      return [];
    }
  }

  /// Get latest statement for a credit card
  Future<CreditCardStatement?> getLatestStatement(String creditCardId) async {
    try {
      final statements = await getStatementsForCard(creditCardId);
      return statements.isNotEmpty ? statements.first : null;
    } catch (e) {
      debugPrint('Error getting latest statement: $e');
      return null;
    }
  }

  /// Calculate billing cycle dates based on statement generation day
  Map<String, DateTime> _calculateBillingCycleDates(
    int statementGenerationDay,
    int year,
    int month,
  ) {
    // Statement generation date for the specified month
    final statementDate = DateTime(year, month, statementGenerationDay);
    
    // Billing cycle start date (previous month's statement date + 1 day)
    final cycleStartDate = DateTime(
      statementDate.month == 1 ? statementDate.year - 1 : statementDate.year,
      statementDate.month == 1 ? 12 : statementDate.month - 1,
      statementGenerationDay,
    ).add(const Duration(days: 1));
    
    // Billing cycle end date (statement generation date)
    final cycleEndDate = statementDate;
    
    // Due date (statement date + grace period, default 21 days)
    final dueDate = statementDate.add(const Duration(days: 21));
    
    return {
      'statement': statementDate,
      'start': cycleStartDate,
      'end': cycleEndDate,
      'due': dueDate,
    };
  }

  /// Get transactions for a specific billing cycle
  Future<List<Transaction>> _getTransactionsForCycle(
    String creditCardId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // Get credit card to find its associated account ID
      final creditCard = await _getCreditCard(creditCardId);
      if (creditCard == null) {
        debugPrint('Credit card not found for transaction filtering: $creditCardId');
        return [];
      }

      final transactionsBox = await _databaseHelper.transactionsBox;
      final transactions = transactionsBox.values
          .cast<Transaction>()
          .where((transaction) {
            // Filter by account ID (credit cards have associated accounts)
            if (transaction.accountId != creditCard.accountId) return false;
            
            // Filter by date range
            final transactionDate = transaction.date;
            return transactionDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
                   transactionDate.isBefore(endDate.add(const Duration(days: 1)));
          })
          .toList();
      
      // Sort by date (oldest first)
      transactions.sort((a, b) => a.date.compareTo(b.date));
      
      debugPrint('Found ${transactions.length} transactions for credit card $creditCardId in period ${startDate.toIso8601String()} to ${endDate.toIso8601String()}');
      return transactions;
    } catch (e) {
      debugPrint('Error getting transactions for cycle: $e');
      return [];
    }
  }

  /// Calculate statement data from transactions
  Future<Map<String, dynamic>> _calculateStatementData(
    CreditCard creditCard,
    List<Transaction> transactions,
    Map<String, DateTime> cycleDates,
  ) async {
    // Get previous statement for previous balance
    final previousStatement = await _getPreviousStatement(
      creditCard.id,
      cycleDates['start']!,
    );

    double previousBalance = previousStatement?.newBalance ?? 0.0;
    double totalPurchases = 0.0;
    double totalPayments = 0.0;
    double totalFees = 0.0;
    double totalInterest = 0.0;
    final List<String> transactionIds = [];

    debugPrint('Calculating statement data for ${transactions.length} transactions');
    debugPrint('Previous balance: $previousBalance');

    // Process transactions
    for (final transaction in transactions) {
      transactionIds.add(transaction.id);
      
      debugPrint('Processing transaction: ${transaction.description} - ${transaction.amount} (${transaction.type})');
      
      if (transaction.type == TransactionType.expense) {
        totalPurchases += transaction.amount;
      } else if (transaction.type == TransactionType.income) {
        totalPayments += transaction.amount;
      }
      
      // TODO: Add fee and interest calculation logic
      // This would require additional transaction categorization
    }

    // Calculate new balance
    final newBalance = previousBalance + totalPurchases - totalPayments + totalFees + totalInterest;
    
    // Calculate available credit
    final availableCredit = creditCard.creditLimit - newBalance;
    
    // Calculate credit utilization
    final creditUtilization = creditCard.creditLimit > 0 
        ? (newBalance / creditCard.creditLimit) * 100 
        : 0.0;

    // Calculate minimum payment
    double minimumPayment = 0.0;
    if (creditCard.minimumPaymentFixedAmount != null) {
      minimumPayment = creditCard.minimumPaymentFixedAmount!;
    } else {
      minimumPayment = (newBalance * creditCard.minimumPaymentPercentage / 100);
    }

    debugPrint('Statement calculation results:');
    debugPrint('  Previous Balance: $previousBalance');
    debugPrint('  Total Purchases: $totalPurchases');
    debugPrint('  Total Payments: $totalPayments');
    debugPrint('  New Balance: $newBalance');
    debugPrint('  Minimum Payment: $minimumPayment');

    return {
      'previousBalance': previousBalance,
      'totalPurchases': totalPurchases,
      'totalPayments': totalPayments,
      'totalFees': totalFees,
      'totalInterest': totalInterest,
      'newBalance': newBalance,
      'minimumPayment': minimumPayment,
      'availableCredit': availableCredit,
      'creditUtilization': creditUtilization,
      'transactionIds': transactionIds,
    };
  }

  /// Get credit card by ID
  Future<CreditCard?> _getCreditCard(String creditCardId) async {
    try {
      final creditCardsBox = await _databaseHelper.creditCardsBox;
      return creditCardsBox.get(creditCardId);
    } catch (e) {
      debugPrint('Error getting credit card: $e');
      return null;
    }
  }

  /// Get active credit cards
  Future<List<CreditCard>> _getActiveCreditCards() async {
    try {
      final creditCardsBox = await _databaseHelper.creditCardsBox;
      return creditCardsBox.values
          .cast<CreditCard>()
          .where((card) => card.isActive)
          .toList();
    } catch (e) {
      debugPrint('Error getting active credit cards: $e');
      return [];
    }
  }

  /// Get existing statement for a period
  Future<CreditCardStatement?> _getExistingStatement(
    String creditCardId,
    int year,
    int month,
  ) async {
    try {
      final statementsBox = await _databaseHelper.creditCardStatementsBox;
      final statementId = '${creditCardId}_${year}_${month.toString().padLeft(2, '0')}';
      return statementsBox.get(statementId);
    } catch (e) {
      debugPrint('Error getting existing statement: $e');
      return null;
    }
  }

  /// Get previous statement for previous balance calculation
  Future<CreditCardStatement?> _getPreviousStatement(
    String creditCardId,
    DateTime currentCycleStart,
  ) async {
    try {
      final statements = await getStatementsForCard(creditCardId);
      
      // Find the most recent statement before current cycle start
      for (final statement in statements) {
        if (statement.statementDate.isBefore(currentCycleStart)) {
          return statement;
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('Error getting previous statement: $e');
      return null;
    }
  }

  /// Save statement to database
  Future<void> _saveStatement(CreditCardStatement statement) async {
    try {
      final statementsBox = await _databaseHelper.creditCardStatementsBox;
      await statementsBox.put(statement.id, statement);
    } catch (e) {
      debugPrint('Error saving statement: $e');
    }
  }

  /// Update statement status (e.g., when payment is made)
  Future<void> updateStatementStatus(
    String statementId,
    StatementStatus status, {
    double? paymentAmount,
  }) async {
    try {
      final statementsBox = await _databaseHelper.creditCardStatementsBox;
      final statement = statementsBox.get(statementId);
      
      if (statement != null) {
        final updatedStatement = statement.copyWith(
          status: status,
          paidAt: status == StatementStatus.paid ? DateTime.now() : statement.paidAt,
          paymentAmount: paymentAmount ?? statement.paymentAmount,
        );
        
        await statementsBox.put(statementId, updatedStatement);
      }
    } catch (e) {
      debugPrint('Error updating statement status: $e');
    }
  }

  /// Delete statement
  Future<void> deleteStatement(String statementId) async {
    try {
      final statementsBox = await _databaseHelper.creditCardStatementsBox;
      await statementsBox.delete(statementId);
    } catch (e) {
      debugPrint('Error deleting statement: $e');
    }
  }
}
