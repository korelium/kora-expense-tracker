// File location: lib/data/models/loan.dart
// Purpose: Loan data model for tracking loans and their payments
// Author: Pown Kumar - Founder of Korelium
// Date: September 24, 2025

import 'package:hive/hive.dart';

part 'loan.g.dart';

/// Loan model representing different types of loans
@HiveType(typeId: 13)
class Loan extends HiveObject {
  /// Unique identifier for the loan
  @HiveField(0)
  final String id;
  
  /// Name or description of the loan
  @HiveField(1)
  final String name;
  
  /// Type of loan (personal, mortgage, auto, student, etc.)
  @HiveField(2)
  final LoanType type;
  
  /// Original loan amount
  @HiveField(3)
  final double principalAmount;
  
  /// Current outstanding balance
  @HiveField(4)
  final double currentBalance;
  
  /// Annual interest rate (as percentage)
  @HiveField(5)
  final double interestRate;
  
  /// Loan term in months
  @HiveField(6)
  final int termMonths;
  
  /// Monthly payment amount
  @HiveField(7)
  final double monthlyPayment;
  
  /// Date when the loan was taken
  @HiveField(8)
  final DateTime startDate;
  
  /// Expected end date of the loan
  @HiveField(9)
  final DateTime endDate;
  
  /// Next payment due date
  @HiveField(10)
  final DateTime nextPaymentDate;
  
  /// Account ID associated with this loan (for payments)
  @HiveField(11)
  final String? accountId;
  
  /// Lender name or institution
  @HiveField(12)
  final String lender;
  
  /// Additional notes about the loan
  @HiveField(13)
  final String? notes;
  
  /// Whether the loan is active
  @HiveField(14)
  final bool isActive;
  
  /// Date when the loan was created
  @HiveField(15)
  final DateTime createdAt;
  
  /// Date when the loan was last updated
  @HiveField(16)
  final DateTime updatedAt;

  /// Constructor for Loan model
  Loan({
    required this.id,
    required this.name,
    required this.type,
    required this.principalAmount,
    required this.currentBalance,
    required this.interestRate,
    required this.termMonths,
    required this.monthlyPayment,
    required this.startDate,
    required this.endDate,
    required this.nextPaymentDate,
    this.accountId,
    required this.lender,
    this.notes,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert Loan to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'principalAmount': principalAmount,
      'currentBalance': currentBalance,
      'interestRate': interestRate,
      'termMonths': termMonths,
      'monthlyPayment': monthlyPayment,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'nextPaymentDate': nextPaymentDate.toIso8601String(),
      'accountId': accountId,
      'lender': lender,
      'notes': notes,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create Loan from JSON data
  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: LoanType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => LoanType.personal,
      ),
      principalAmount: (json['principalAmount'] as num?)?.toDouble() ?? 0.0,
      currentBalance: (json['currentBalance'] as num?)?.toDouble() ?? 0.0,
      interestRate: (json['interestRate'] as num?)?.toDouble() ?? 0.0,
      termMonths: json['termMonths'] ?? 0,
      monthlyPayment: (json['monthlyPayment'] as num?)?.toDouble() ?? 0.0,
      startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate'] ?? '') ?? DateTime.now(),
      nextPaymentDate: DateTime.tryParse(json['nextPaymentDate'] ?? '') ?? DateTime.now(),
      accountId: json['accountId'],
      lender: json['lender'] ?? '',
      notes: json['notes'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  /// Create a copy of this loan with updated fields
  Loan copyWith({
    String? id,
    String? name,
    LoanType? type,
    double? principalAmount,
    double? currentBalance,
    double? interestRate,
    int? termMonths,
    double? monthlyPayment,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? nextPaymentDate,
    String? accountId,
    String? lender,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Loan(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      principalAmount: principalAmount ?? this.principalAmount,
      currentBalance: currentBalance ?? this.currentBalance,
      interestRate: interestRate ?? this.interestRate,
      termMonths: termMonths ?? this.termMonths,
      monthlyPayment: monthlyPayment ?? this.monthlyPayment,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      nextPaymentDate: nextPaymentDate ?? this.nextPaymentDate,
      accountId: accountId ?? this.accountId,
      lender: lender ?? this.lender,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Calculate total interest paid so far
  double get totalInterestPaid {
    return principalAmount - currentBalance;
  }

  /// Calculate remaining payments
  int get remainingPayments {
    if (monthlyPayment <= 0) return 0;
    return (currentBalance / monthlyPayment).ceil();
  }

  /// Calculate total interest that will be paid over the loan term
  double get totalInterestOverTerm {
    return (monthlyPayment * termMonths) - principalAmount;
  }

  /// Calculate loan-to-value ratio (if applicable)
  double get loanToValueRatio {
    // This would need asset value, which we don't have in this model
    // Could be extended in the future
    return 0.0;
  }

  /// Check if loan is overdue
  bool get isOverdue {
    return DateTime.now().isAfter(nextPaymentDate) && isActive;
  }

  /// Get days until next payment
  int get daysUntilNextPayment {
    final now = DateTime.now();
    final difference = nextPaymentDate.difference(now).inDays;
    return difference;
  }

  /// Get loan progress percentage
  double get progressPercentage {
    if (principalAmount <= 0) return 0.0;
    return ((principalAmount - currentBalance) / principalAmount) * 100;
  }

  /// Get formatted interest rate
  String get formattedInterestRate {
    return '${interestRate.toStringAsFixed(2)}%';
  }

  /// Get formatted monthly payment
  String get formattedMonthlyPayment {
    return '\$${monthlyPayment.toStringAsFixed(2)}';
  }

  /// Get formatted current balance
  String get formattedCurrentBalance {
    return '\$${currentBalance.toStringAsFixed(2)}';
  }

  /// Get formatted principal amount
  String get formattedPrincipalAmount {
    return '\$${principalAmount.toStringAsFixed(2)}';
  }

  @override
  String toString() {
    return 'Loan(id: $id, name: $name, type: $type, balance: $currentBalance)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Loan && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Enum representing different types of loans
@HiveType(typeId: 14)
enum LoanType {
  /// Personal loan
  @HiveField(0)
  personal,
  
  /// Mortgage loan
  @HiveField(1)
  mortgage,
  
  /// Auto loan
  @HiveField(2)
  auto,
  
  /// Student loan
  @HiveField(3)
  student,
  
  /// Business loan
  @HiveField(4)
  business,
  
  /// Home equity loan
  @HiveField(5)
  homeEquity,
  
  /// Credit line
  @HiveField(6)
  creditLine,
  
  /// Other type of loan
  @HiveField(7)
  other,
}

/// Extension to get display names for loan types
extension LoanTypeExtension on LoanType {
  String get displayName {
    switch (this) {
      case LoanType.personal:
        return 'Personal Loan';
      case LoanType.mortgage:
        return 'Mortgage';
      case LoanType.auto:
        return 'Auto Loan';
      case LoanType.student:
        return 'Student Loan';
      case LoanType.business:
        return 'Business Loan';
      case LoanType.homeEquity:
        return 'Home Equity Loan';
      case LoanType.creditLine:
        return 'Credit Line';
      case LoanType.other:
        return 'Other';
    }
  }

  /// Get icon for loan type
  String get iconName {
    switch (this) {
      case LoanType.personal:
        return 'account_balance_wallet';
      case LoanType.mortgage:
        return 'home';
      case LoanType.auto:
        return 'directions_car';
      case LoanType.student:
        return 'school';
      case LoanType.business:
        return 'business';
      case LoanType.homeEquity:
        return 'home_work';
      case LoanType.creditLine:
        return 'credit_card';
      case LoanType.other:
        return 'account_balance';
    }
  }
}
