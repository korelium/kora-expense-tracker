// File location: lib/data/models/bill.dart
// Purpose: Bill data model for credit card statements
// Author: Pown Kumar - Founder of Korelium
// Date: September 23, 2025

import 'package:hive/hive.dart';

part 'bill.g.dart';

/// Bill model for credit card statements
@HiveType(typeId: 11)
class Bill extends HiveObject {
  /// Unique identifier for the bill
  @HiveField(0)
  final String id;
  
  /// Credit card ID this bill belongs to
  @HiveField(1)
  final String creditCardId;
  
  /// Bill generation date
  @HiveField(2)
  final DateTime billDate;
  
  /// Due date (15 days after bill date by default)
  @HiveField(3)
  final DateTime dueDate;
  
  /// Statement period start date
  @HiveField(4)
  final DateTime statementPeriodStart;
  
  /// Statement period end date
  @HiveField(5)
  final DateTime statementPeriodEnd;
  
  /// Previous balance
  @HiveField(6)
  final double previousBalance;
  
  /// Total payments made during the period
  @HiveField(7)
  final double totalPayments;
  
  /// Total purchases made during the period
  @HiveField(8)
  final double totalPurchases;
  
  /// Total interest charged
  @HiveField(9)
  final double totalInterest;
  
  /// Total fees charged
  @HiveField(10)
  final double totalFees;
  
  /// New balance after all transactions
  @HiveField(11)
  final double newBalance;
  
  /// Minimum payment required
  @HiveField(12)
  final double minimumPayment;
  
  /// Available credit after new balance
  @HiveField(13)
  final double availableCredit;
  
  /// Bill status
  @HiveField(14)
  final BillStatus status;
  
  /// Payment date (null if not paid)
  @HiveField(15)
  final DateTime? paymentDate;
  
  /// Payment amount (null if not paid)
  @HiveField(16)
  final double? paymentAmount;
  
  /// Bill file path (PDF location)
  @HiveField(17)
  final String? filePath;
  
  /// Notes or additional information
  @HiveField(18)
  final String? notes;

  Bill({
    required this.id,
    required this.creditCardId,
    required this.billDate,
    required this.dueDate,
    required this.statementPeriodStart,
    required this.statementPeriodEnd,
    required this.previousBalance,
    required this.totalPayments,
    required this.totalPurchases,
    required this.totalInterest,
    required this.totalFees,
    required this.newBalance,
    required this.minimumPayment,
    required this.availableCredit,
    required this.status,
    this.paymentDate,
    this.paymentAmount,
    this.filePath,
    this.notes,
  });

  /// Create a copy of this bill with updated fields
  Bill copyWith({
    String? id,
    String? creditCardId,
    DateTime? billDate,
    DateTime? dueDate,
    DateTime? statementPeriodStart,
    DateTime? statementPeriodEnd,
    double? previousBalance,
    double? totalPayments,
    double? totalPurchases,
    double? totalInterest,
    double? totalFees,
    double? newBalance,
    double? minimumPayment,
    double? availableCredit,
    BillStatus? status,
    DateTime? paymentDate,
    double? paymentAmount,
    String? filePath,
    String? notes,
  }) {
    return Bill(
      id: id ?? this.id,
      creditCardId: creditCardId ?? this.creditCardId,
      billDate: billDate ?? this.billDate,
      dueDate: dueDate ?? this.dueDate,
      statementPeriodStart: statementPeriodStart ?? this.statementPeriodStart,
      statementPeriodEnd: statementPeriodEnd ?? this.statementPeriodEnd,
      previousBalance: previousBalance ?? this.previousBalance,
      totalPayments: totalPayments ?? this.totalPayments,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      totalInterest: totalInterest ?? this.totalInterest,
      totalFees: totalFees ?? this.totalFees,
      newBalance: newBalance ?? this.newBalance,
      minimumPayment: minimumPayment ?? this.minimumPayment,
      availableCredit: availableCredit ?? this.availableCredit,
      status: status ?? this.status,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      filePath: filePath ?? this.filePath,
      notes: notes ?? this.notes,
    );
  }

  /// Check if bill is overdue
  bool get isOverdue => status == BillStatus.overdue;

  /// Check if bill is due soon (within 3 days)
  bool get isDueSoon {
    final now = DateTime.now();
    final daysUntilDue = dueDate.difference(now).inDays;
    return daysUntilDue <= 3 && daysUntilDue >= 0 && status != BillStatus.paid;
  }

  /// Check if bill is paid
  bool get isPaid => status == BillStatus.paid;

  /// Get days until due date
  int get daysUntilDue {
    final now = DateTime.now();
    return dueDate.difference(now).inDays;
  }

  /// Get formatted bill period
  String get formattedPeriod {
    final startMonth = statementPeriodStart.month.toString().padLeft(2, '0');
    final startDay = statementPeriodStart.day.toString().padLeft(2, '0');
    final endMonth = statementPeriodEnd.month.toString().padLeft(2, '0');
    final endDay = statementPeriodEnd.day.toString().padLeft(2, '0');
    return '$startMonth/$startDay - $endMonth/$endDay';
  }

  /// Get formatted due date
  String get formattedDueDate {
    final month = dueDate.month.toString().padLeft(2, '0');
    final day = dueDate.day.toString().padLeft(2, '0');
    final year = dueDate.year.toString();
    return '$month/$day/$year';
  }

  /// Get formatted bill date
  String get formattedBillDate {
    final month = billDate.month.toString().padLeft(2, '0');
    final day = billDate.day.toString().padLeft(2, '0');
    final year = billDate.year.toString();
    return '$month/$day/$year';
  }

  @override
  String toString() {
    return 'Bill(id: $id, creditCardId: $creditCardId, billDate: $billDate, dueDate: $dueDate, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Bill && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Bill status enum
@HiveType(typeId: 12)
enum BillStatus {
  @HiveField(0)
  pending,    // Bill generated, waiting for due date
  
  @HiveField(1)
  dueSoon,    // Due within 3 days
  
  @HiveField(2)
  overdue,    // Past due date, not paid
  
  @HiveField(3)
  paid,       // Payment received
  
  @HiveField(4)
  cancelled,  // Bill cancelled
}
