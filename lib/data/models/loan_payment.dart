// File location: lib/data/models/loan_payment.dart
// Purpose: Loan payment data model for tracking loan payments
// Author: Pown Kumar - Founder of Korelium
// Date: September 24, 2025

import 'package:hive/hive.dart';

part 'loan_payment.g.dart';

/// Loan payment model representing individual loan payments
@HiveType(typeId: 15)
class LoanPayment extends HiveObject {
  /// Unique identifier for the payment
  @HiveField(0)
  final String id;
  
  /// ID of the associated loan
  @HiveField(1)
  final String loanId;
  
  /// Payment amount
  @HiveField(2)
  final double amount;
  
  /// Principal portion of the payment
  @HiveField(3)
  final double principalAmount;
  
  /// Interest portion of the payment
  @HiveField(4)
  final double interestAmount;
  
  /// Date when the payment was made
  @HiveField(5)
  final DateTime paymentDate;
  
  /// Due date for this payment
  @HiveField(6)
  final DateTime dueDate;
  
  /// Payment method used
  @HiveField(7)
  final PaymentMethod paymentMethod;
  
  /// Account ID used for the payment
  @HiveField(8)
  final String? accountId;
  
  /// Transaction ID if linked to a transaction
  @HiveField(9)
  final String? transactionId;
  
  /// Payment status
  @HiveField(10)
  final PaymentStatus status;
  
  /// Additional notes about the payment
  @HiveField(11)
  final String? notes;
  
  /// Whether this is an extra payment
  @HiveField(12)
  final bool isExtraPayment;
  
  /// Date when the payment was created
  @HiveField(13)
  final DateTime createdAt;

  /// Constructor for LoanPayment model
  LoanPayment({
    required this.id,
    required this.loanId,
    required this.amount,
    required this.principalAmount,
    required this.interestAmount,
    required this.paymentDate,
    required this.dueDate,
    required this.paymentMethod,
    this.accountId,
    this.transactionId,
    this.status = PaymentStatus.completed,
    this.notes,
    this.isExtraPayment = false,
    required this.createdAt,
  });

  /// Convert LoanPayment to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'loanId': loanId,
      'amount': amount,
      'principalAmount': principalAmount,
      'interestAmount': interestAmount,
      'paymentDate': paymentDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'paymentMethod': paymentMethod.toString().split('.').last,
      'accountId': accountId,
      'transactionId': transactionId,
      'status': status.toString().split('.').last,
      'notes': notes,
      'isExtraPayment': isExtraPayment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create LoanPayment from JSON data
  factory LoanPayment.fromJson(Map<String, dynamic> json) {
    return LoanPayment(
      id: json['id'] ?? '',
      loanId: json['loanId'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      principalAmount: (json['principalAmount'] as num?)?.toDouble() ?? 0.0,
      interestAmount: (json['interestAmount'] as num?)?.toDouble() ?? 0.0,
      paymentDate: DateTime.tryParse(json['paymentDate'] ?? '') ?? DateTime.now(),
      dueDate: DateTime.tryParse(json['dueDate'] ?? '') ?? DateTime.now(),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.toString().split('.').last == json['paymentMethod'],
        orElse: () => PaymentMethod.bankTransfer,
      ),
      accountId: json['accountId'],
      transactionId: json['transactionId'],
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => PaymentStatus.completed,
      ),
      notes: json['notes'],
      isExtraPayment: json['isExtraPayment'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  /// Create a copy of this loan payment with updated fields
  LoanPayment copyWith({
    String? id,
    String? loanId,
    double? amount,
    double? principalAmount,
    double? interestAmount,
    DateTime? paymentDate,
    DateTime? dueDate,
    PaymentMethod? paymentMethod,
    String? accountId,
    String? transactionId,
    PaymentStatus? status,
    String? notes,
    bool? isExtraPayment,
    DateTime? createdAt,
  }) {
    return LoanPayment(
      id: id ?? this.id,
      loanId: loanId ?? this.loanId,
      amount: amount ?? this.amount,
      principalAmount: principalAmount ?? this.principalAmount,
      interestAmount: interestAmount ?? this.interestAmount,
      paymentDate: paymentDate ?? this.paymentDate,
      dueDate: dueDate ?? this.dueDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      accountId: accountId ?? this.accountId,
      transactionId: transactionId ?? this.transactionId,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      isExtraPayment: isExtraPayment ?? this.isExtraPayment,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Check if payment is overdue
  bool get isOverdue {
    return DateTime.now().isAfter(dueDate) && status != PaymentStatus.completed;
  }

  /// Check if payment is due soon (within 7 days)
  bool get isDueSoon {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    return difference <= 7 && difference >= 0 && status != PaymentStatus.completed;
  }

  /// Get days until due date
  int get daysUntilDue {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    return difference;
  }

  /// Get formatted payment amount
  String get formattedAmount {
    return '\$${amount.toStringAsFixed(2)}';
  }

  /// Get formatted principal amount
  String get formattedPrincipalAmount {
    return '\$${principalAmount.toStringAsFixed(2)}';
  }

  /// Get formatted interest amount
  String get formattedInterestAmount {
    return '\$${interestAmount.toStringAsFixed(2)}';
  }

  @override
  String toString() {
    return 'LoanPayment(id: $id, loanId: $loanId, amount: $amount, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoanPayment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Enum representing payment methods
@HiveType(typeId: 16)
enum PaymentMethod {
  /// Bank transfer
  @HiveField(0)
  bankTransfer,
  
  /// Credit card
  @HiveField(1)
  creditCard,
  
  /// Cash
  @HiveField(2)
  cash,
  
  /// Check
  @HiveField(3)
  check,
  
  /// Automatic payment
  @HiveField(4)
  automatic,
  
  /// Online payment
  @HiveField(5)
  online,
  
  /// Other payment method
  @HiveField(6)
  other,
}

/// Enum representing payment status
@HiveType(typeId: 17)
enum PaymentStatus {
  /// Payment is pending
  @HiveField(0)
  pending,
  
  /// Payment is completed
  @HiveField(1)
  completed,
  
  /// Payment failed
  @HiveField(2)
  failed,
  
  /// Payment is overdue
  @HiveField(3)
  overdue,
  
  /// Payment is cancelled
  @HiveField(4)
  cancelled,
}

/// Extension to get display names for payment methods
extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.check:
        return 'Check';
      case PaymentMethod.automatic:
        return 'Automatic Payment';
      case PaymentMethod.online:
        return 'Online Payment';
      case PaymentMethod.other:
        return 'Other';
    }
  }
}

/// Extension to get display names for payment status
extension PaymentStatusExtension on PaymentStatus {
  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.overdue:
        return 'Overdue';
      case PaymentStatus.cancelled:
        return 'Cancelled';
    }
  }
}
