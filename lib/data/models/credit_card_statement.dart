// File location: lib/data/models/credit_card_statement.dart
// Purpose: Credit card statement model for storing monthly statement data
// Author: Pown Kumar - Founder of Korelium
// Date: September 23, 2025

import 'package:hive/hive.dart';
import 'transaction.dart';

part 'credit_card_statement.g.dart';

/// Credit card statement model representing monthly billing statement
/// Contains all necessary data for statement display and management
@HiveType(typeId: 10)
class CreditCardStatement extends HiveObject {
  /// Unique identifier for the statement
  @HiveField(0)
  final String id;
  
  /// ID of the associated credit card
  @HiveField(1)
  final String creditCardId;
  
  /// Statement generation date
  @HiveField(2)
  final DateTime statementDate;
  
  /// Billing cycle start date
  @HiveField(3)
  final DateTime cycleStartDate;
  
  /// Billing cycle end date
  @HiveField(4)
  final DateTime cycleEndDate;
  
  /// Due date for payment
  @HiveField(5)
  final DateTime dueDate;
  
  /// Previous balance (from last statement)
  @HiveField(6)
  final double previousBalance;
  
  /// Total purchases during the cycle
  @HiveField(7)
  final double totalPurchases;
  
  /// Total payments made during the cycle
  @HiveField(8)
  final double totalPayments;
  
  /// Total fees and charges
  @HiveField(9)
  final double totalFees;
  
  /// Total interest charged
  @HiveField(10)
  final double totalInterest;
  
  /// New balance (current balance)
  @HiveField(11)
  final double newBalance;
  
  /// Minimum payment due
  @HiveField(12)
  final double minimumPayment;
  
  /// Credit limit at statement time
  @HiveField(13)
  final double creditLimit;
  
  /// Available credit at statement time
  @HiveField(14)
  final double availableCredit;
  
  /// Credit utilization percentage
  @HiveField(15)
  final double creditUtilization;
  
  /// List of transaction IDs in this statement
  @HiveField(16)
  final List<String> transactionIds;
  
  /// Statement status (generated, paid, overdue)
  @HiveField(17)
  final StatementStatus status;
  
  /// Date when statement was generated
  @HiveField(18)
  final DateTime generatedAt;
  
  /// Date when payment was made (if paid)
  @HiveField(19)
  final DateTime? paidAt;
  
  /// Payment amount (if paid)
  @HiveField(20)
  final double? paymentAmount;

  /// Constructor for CreditCardStatement model
  CreditCardStatement({
    required this.id,
    required this.creditCardId,
    required this.statementDate,
    required this.cycleStartDate,
    required this.cycleEndDate,
    required this.dueDate,
    required this.previousBalance,
    required this.totalPurchases,
    required this.totalPayments,
    required this.totalFees,
    required this.totalInterest,
    required this.newBalance,
    required this.minimumPayment,
    required this.creditLimit,
    required this.availableCredit,
    required this.creditUtilization,
    required this.transactionIds,
    required this.status,
    required this.generatedAt,
    this.paidAt,
    this.paymentAmount,
  });

  /// Convert CreditCardStatement to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creditCardId': creditCardId,
      'statementDate': statementDate.toIso8601String(),
      'cycleStartDate': cycleStartDate.toIso8601String(),
      'cycleEndDate': cycleEndDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'previousBalance': previousBalance,
      'totalPurchases': totalPurchases,
      'totalPayments': totalPayments,
      'totalFees': totalFees,
      'totalInterest': totalInterest,
      'newBalance': newBalance,
      'minimumPayment': minimumPayment,
      'creditLimit': creditLimit,
      'availableCredit': availableCredit,
      'creditUtilization': creditUtilization,
      'transactionIds': transactionIds,
      'status': status.name,
      'generatedAt': generatedAt.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
      'paymentAmount': paymentAmount,
    };
  }

  /// Create CreditCardStatement from JSON data
  factory CreditCardStatement.fromJson(Map<String, dynamic> json) {
    return CreditCardStatement(
      id: json['id'] ?? '',
      creditCardId: json['creditCardId'] ?? '',
      statementDate: DateTime.tryParse(json['statementDate'] ?? '') ?? DateTime.now(),
      cycleStartDate: DateTime.tryParse(json['cycleStartDate'] ?? '') ?? DateTime.now(),
      cycleEndDate: DateTime.tryParse(json['cycleEndDate'] ?? '') ?? DateTime.now(),
      dueDate: DateTime.tryParse(json['dueDate'] ?? '') ?? DateTime.now(),
      previousBalance: (json['previousBalance'] as num?)?.toDouble() ?? 0.0,
      totalPurchases: (json['totalPurchases'] as num?)?.toDouble() ?? 0.0,
      totalPayments: (json['totalPayments'] as num?)?.toDouble() ?? 0.0,
      totalFees: (json['totalFees'] as num?)?.toDouble() ?? 0.0,
      totalInterest: (json['totalInterest'] as num?)?.toDouble() ?? 0.0,
      newBalance: (json['newBalance'] as num?)?.toDouble() ?? 0.0,
      minimumPayment: (json['minimumPayment'] as num?)?.toDouble() ?? 0.0,
      creditLimit: (json['creditLimit'] as num?)?.toDouble() ?? 0.0,
      availableCredit: (json['availableCredit'] as num?)?.toDouble() ?? 0.0,
      creditUtilization: (json['creditUtilization'] as num?)?.toDouble() ?? 0.0,
      transactionIds: List<String>.from(json['transactionIds'] ?? []),
      status: StatementStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => StatementStatus.generated,
      ),
      generatedAt: DateTime.tryParse(json['generatedAt'] ?? '') ?? DateTime.now(),
      paidAt: json['paidAt'] != null ? DateTime.tryParse(json['paidAt']) : null,
      paymentAmount: (json['paymentAmount'] as num?)?.toDouble(),
    );
  }

  /// Create a copy of this statement with updated fields
  CreditCardStatement copyWith({
    String? id,
    String? creditCardId,
    DateTime? statementDate,
    DateTime? cycleStartDate,
    DateTime? cycleEndDate,
    DateTime? dueDate,
    double? previousBalance,
    double? totalPurchases,
    double? totalPayments,
    double? totalFees,
    double? totalInterest,
    double? newBalance,
    double? minimumPayment,
    double? creditLimit,
    double? availableCredit,
    double? creditUtilization,
    List<String>? transactionIds,
    StatementStatus? status,
    DateTime? generatedAt,
    DateTime? paidAt,
    double? paymentAmount,
  }) {
    return CreditCardStatement(
      id: id ?? this.id,
      creditCardId: creditCardId ?? this.creditCardId,
      statementDate: statementDate ?? this.statementDate,
      cycleStartDate: cycleStartDate ?? this.cycleStartDate,
      cycleEndDate: cycleEndDate ?? this.cycleEndDate,
      dueDate: dueDate ?? this.dueDate,
      previousBalance: previousBalance ?? this.previousBalance,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      totalPayments: totalPayments ?? this.totalPayments,
      totalFees: totalFees ?? this.totalFees,
      totalInterest: totalInterest ?? this.totalInterest,
      newBalance: newBalance ?? this.newBalance,
      minimumPayment: minimumPayment ?? this.minimumPayment,
      creditLimit: creditLimit ?? this.creditLimit,
      availableCredit: availableCredit ?? this.availableCredit,
      creditUtilization: creditUtilization ?? this.creditUtilization,
      transactionIds: transactionIds ?? this.transactionIds,
      status: status ?? this.status,
      generatedAt: generatedAt ?? this.generatedAt,
      paidAt: paidAt ?? this.paidAt,
      paymentAmount: paymentAmount ?? this.paymentAmount,
    );
  }

  /// Check if statement is overdue
  bool get isOverdue {
    if (status == StatementStatus.paid) return false;
    return DateTime.now().isAfter(dueDate);
  }

  /// Check if statement is due soon (within 7 days)
  bool get isDueSoon {
    if (status == StatementStatus.paid) return false;
    final daysUntilDue = dueDate.difference(DateTime.now()).inDays;
    return daysUntilDue <= 7 && daysUntilDue >= 0;
  }

  /// Get days until due date
  int get daysUntilDue {
    if (status == StatementStatus.paid) return 0;
    return dueDate.difference(DateTime.now()).inDays;
  }

  /// Get statement period as formatted string
  String get statementPeriod {
    final startMonth = cycleStartDate.month;
    final startYear = cycleStartDate.year;
    final endMonth = cycleEndDate.month;
    final endYear = cycleEndDate.year;
    
    if (startYear == endYear) {
      return '${_getMonthName(startMonth)} - ${_getMonthName(endMonth)} $startYear';
    } else {
      return '${_getMonthName(startMonth)} $startYear - ${_getMonthName(endMonth)} $endYear';
    }
  }

  /// Get month name from month number
  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  /// Get formatted statement date
  String get formattedStatementDate {
    return '${statementDate.day} ${_getMonthName(statementDate.month)} ${statementDate.year}';
  }

  /// Get formatted due date
  String get formattedDueDate {
    return '${dueDate.day} ${_getMonthName(dueDate.month)} ${dueDate.year}';
  }

  /// Get status display text
  String get statusText {
    switch (status) {
      case StatementStatus.generated:
        return 'Generated';
      case StatementStatus.paid:
        return 'Paid';
      case StatementStatus.overdue:
        return 'Overdue';
    }
  }

  /// Get status color
  String get statusColor {
    switch (status) {
      case StatementStatus.generated:
        return 'blue';
      case StatementStatus.paid:
        return 'green';
      case StatementStatus.overdue:
        return 'red';
    }
  }

  @override
  String toString() {
    return 'CreditCardStatement(id: $id, creditCardId: $creditCardId, statementDate: $statementDate, newBalance: $newBalance)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CreditCardStatement && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Statement status enum
@HiveType(typeId: 9)
enum StatementStatus {
  @HiveField(0)
  generated,
  
  @HiveField(1)
  paid,
  
  @HiveField(2)
  overdue,
}
