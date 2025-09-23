// File location: lib/data/models/credit_card.dart
// Purpose: Credit card data model for managing credit card accounts
// Author: Pown Kumar - Founder of Korelium
// Date: December 19, 2024

import 'package:hive/hive.dart';

part 'credit_card.g.dart';

/// Credit card model representing credit card account details
/// Contains all necessary data for credit card management and tracking
@HiveType(typeId: 6)
class CreditCard extends HiveObject {
  /// Unique identifier for the credit card
  @HiveField(0)
  final String id;
  
  /// ID of the associated account
  @HiveField(1)
  final String accountId;
  
  /// Display name of the credit card
  @HiveField(2)
  final String cardName;
  
  /// Last four digits of the card number
  @HiveField(3)
  final String lastFourDigits;
  
  /// Bank or issuer name
  @HiveField(4)
  final String bankName;
  
  /// Credit limit of the card
  @HiveField(5)
  final double creditLimit;
  
  /// Current balance (amount owed)
  @HiveField(6)
  final double currentBalance;
  
  /// Interest rate (annual percentage rate)
  @HiveField(7)
  final double interestRate;
  
  /// Day of month when payment is due (1-31)
  @HiveField(8)
  final int dueDay;
  
  /// Minimum payment amount
  @HiveField(9)
  final double minimumPayment;
  
  /// Date when the credit card was created
  @HiveField(10)
  final DateTime createdAt;
  
  /// Date of last payment made
  @HiveField(11)
  final DateTime? lastPaymentDate;
  
  /// Whether the credit card is active
  @HiveField(12)
  final bool isActive;
  
  /// Optional notes about the credit card
  @HiveField(13)
  final String? notes;

  /// Constructor for CreditCard model
  CreditCard({
    required this.id,
    required this.accountId,
    required this.cardName,
    required this.lastFourDigits,
    required this.bankName,
    required this.creditLimit,
    required this.currentBalance,
    required this.interestRate,
    required this.dueDay,
    required this.minimumPayment,
    required this.createdAt,
    this.lastPaymentDate,
    this.isActive = true,
    this.notes,
  });

  /// Convert CreditCard to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountId': accountId,
      'cardName': cardName,
      'lastFourDigits': lastFourDigits,
      'bankName': bankName,
      'creditLimit': creditLimit,
      'currentBalance': currentBalance,
      'interestRate': interestRate,
      'dueDay': dueDay,
      'minimumPayment': minimumPayment,
      'createdAt': createdAt.toIso8601String(),
      'lastPaymentDate': lastPaymentDate?.toIso8601String(),
      'isActive': isActive,
      'notes': notes,
    };
  }

  /// Create CreditCard from JSON data
  factory CreditCard.fromJson(Map<String, dynamic> json) {
    return CreditCard(
      id: json['id'] ?? '',
      accountId: json['accountId'] ?? '',
      cardName: json['cardName'] ?? 'Unknown Card',
      lastFourDigits: json['lastFourDigits'] ?? '0000',
      bankName: json['bankName'] ?? 'Unknown Bank',
      creditLimit: (json['creditLimit'] as num?)?.toDouble() ?? 0.0,
      currentBalance: (json['currentBalance'] as num?)?.toDouble() ?? 0.0,
      interestRate: (json['interestRate'] as num?)?.toDouble() ?? 0.0,
      dueDay: json['dueDay'] ?? 1,
      minimumPayment: (json['minimumPayment'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      lastPaymentDate: json['lastPaymentDate'] != null 
          ? DateTime.tryParse(json['lastPaymentDate']) 
          : null,
      isActive: json['isActive'] ?? true,
      notes: json['notes'],
    );
  }

  /// Create a copy of this credit card with updated fields
  CreditCard copyWith({
    String? id,
    String? accountId,
    String? cardName,
    String? lastFourDigits,
    String? bankName,
    double? creditLimit,
    double? currentBalance,
    double? interestRate,
    int? dueDay,
    double? minimumPayment,
    DateTime? createdAt,
    DateTime? lastPaymentDate,
    bool? isActive,
    String? notes,
  }) {
    return CreditCard(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      cardName: cardName ?? this.cardName,
      lastFourDigits: lastFourDigits ?? this.lastFourDigits,
      bankName: bankName ?? this.bankName,
      creditLimit: creditLimit ?? this.creditLimit,
      currentBalance: currentBalance ?? this.currentBalance,
      interestRate: interestRate ?? this.interestRate,
      dueDay: dueDay ?? this.dueDay,
      minimumPayment: minimumPayment ?? this.minimumPayment,
      createdAt: createdAt ?? this.createdAt,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
    );
  }

  /// Calculate available credit
  /// Available Credit = Credit Limit - Current Balance
  double get availableCredit => creditLimit - currentBalance;

  /// Calculate credit utilization percentage
  /// Utilization = (Current Balance / Credit Limit) * 100
  double get creditUtilization => creditLimit > 0 ? (currentBalance / creditLimit) * 100 : 0.0;

  /// Check if credit limit is exceeded
  bool get isOverLimit => currentBalance > creditLimit;

  /// Check if payment is due soon (within 7 days)
  bool get isPaymentDueSoon {
    if (!isActive) return false;
    
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final nextMonth = DateTime(now.year, now.month + 1);
    
    // Calculate due date for current month
    DateTime dueDate;
    if (dueDay <= now.day) {
      // Due date has passed this month, check next month
      dueDate = DateTime(nextMonth.year, nextMonth.month, dueDay);
    } else {
      // Due date is this month
      dueDate = DateTime(currentMonth.year, currentMonth.month, dueDay);
    }
    
    final daysUntilDue = dueDate.difference(now).inDays;
    return daysUntilDue <= 7 && daysUntilDue >= 0;
  }

  /// Get days until payment is due
  int get daysUntilDue {
    if (!isActive) return 0;
    
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final nextMonth = DateTime(now.year, now.month + 1);
    
    // Calculate due date for current month
    DateTime dueDate;
    if (dueDay <= now.day) {
      // Due date has passed this month, check next month
      dueDate = DateTime(nextMonth.year, nextMonth.month, dueDay);
    } else {
      // Due date is this month
      dueDate = DateTime(currentMonth.year, currentMonth.month, dueDay);
    }
    
    return dueDate.difference(now).inDays;
  }

  /// Check if payment is overdue
  bool get isOverdue {
    if (!isActive) return false;
    
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final nextMonth = DateTime(now.year, now.month + 1);
    
    // Calculate due date for current month
    DateTime dueDate;
    if (dueDay <= now.day) {
      // Due date has passed this month, check next month
      dueDate = DateTime(nextMonth.year, nextMonth.month, dueDay);
    } else {
      // Due date is this month
      dueDate = DateTime(currentMonth.year, currentMonth.month, dueDay);
    }
    
    return now.isAfter(dueDate);
  }

  /// Get the next due date
  DateTime get nextDueDate {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final nextMonth = DateTime(now.year, now.month + 1);
    
    // Calculate due date for current month
    DateTime dueDate;
    if (dueDay <= now.day) {
      // Due date has passed this month, check next month
      dueDate = DateTime(nextMonth.year, nextMonth.month, dueDay);
    } else {
      // Due date is this month
      dueDate = DateTime(currentMonth.year, currentMonth.month, dueDay);
    }
    
    return dueDate;
  }

  /// Calculate suggested payment amount
  /// Suggests minimum payment or more if utilization is high
  double get suggestedPayment {
    if (currentBalance <= 0) return 0.0;
    
    // If utilization is high (>30%), suggest more than minimum
    if (creditUtilization > 30) {
      return (currentBalance * 0.1).clamp(minimumPayment, currentBalance);
    }
    
    // Otherwise suggest minimum payment
    return minimumPayment.clamp(0, currentBalance);
  }

  /// Get credit score impact based on utilization
  String get creditScoreImpact {
    if (creditUtilization <= 10) return 'Excellent';
    if (creditUtilization <= 30) return 'Good';
    if (creditUtilization <= 50) return 'Fair';
    if (creditUtilization <= 80) return 'Poor';
    return 'Very Poor';
  }

  /// Get display name with last four digits
  String get displayName => '$cardName ****$lastFourDigits';

  /// Get formatted credit limit
  String formattedCreditLimit(String currencySymbol) => '$currencySymbol${creditLimit.toStringAsFixed(2)}';

  /// Get formatted current balance
  String formattedCurrentBalance(String currencySymbol) => '$currencySymbol${currentBalance.toStringAsFixed(2)}';

  /// Get formatted available credit
  String formattedAvailableCredit(String currencySymbol) => '$currencySymbol${availableCredit.toStringAsFixed(2)}';

  /// Get formatted credit utilization (hides negative sign)
  String get formattedCreditUtilization => '${creditUtilization.abs().toStringAsFixed(1)}%';

  @override
  String toString() {
    return 'CreditCard(id: $id, cardName: $cardName, balance: $currentBalance, limit: $creditLimit)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CreditCard && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
