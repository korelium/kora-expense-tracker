// File location: lib/data/models/credit_card_transaction.dart
// Purpose: Credit card transaction data model for tracking credit card transactions
// Author: Pown Kumar - Founder of Korelium
// Date: December 19, 2024

import 'package:hive/hive.dart';

part 'credit_card_transaction.g.dart';

/// Credit card transaction model representing individual credit card transactions
/// Links to both the credit card and the main transaction system
@HiveType(typeId: 7)
class CreditCardTransaction extends HiveObject {
  /// Unique identifier for the credit card transaction
  @HiveField(0)
  final String id;
  
  /// ID of the associated credit card
  @HiveField(1)
  final String creditCardId;
  
  /// ID of the associated main transaction
  @HiveField(2)
  final String transactionId;
  
  /// ID of the category this transaction belongs to
  @HiveField(3)
  final String categoryId;
  
  /// Amount of the transaction
  @HiveField(4)
  final double amount;
  
  /// Description of the transaction
  @HiveField(5)
  final String description;
  
  /// Date when the transaction occurred
  @HiveField(6)
  final DateTime transactionDate;
  
  /// Date when the transaction was posted to the account
  @HiveField(7)
  final DateTime postingDate;
  
  /// Type of credit card transaction
  @HiveField(8)
  final CreditCardTransactionType type;
  
  /// Name of the merchant (optional)
  @HiveField(9)
  final String? merchantName;
  
  /// Location where the transaction occurred (optional)
  @HiveField(10)
  final String? location;
  
  /// Whether the transaction is pending
  @HiveField(11)
  final bool isPending;
  
  /// Path to receipt image (optional)
  @HiveField(12)
  final String? receiptImagePath;
  
  /// Additional notes about the transaction
  @HiveField(13)
  final String? notes;

  /// Constructor for CreditCardTransaction model
  CreditCardTransaction({
    required this.id,
    required this.creditCardId,
    required this.transactionId,
    required this.categoryId,
    required this.amount,
    required this.description,
    required this.transactionDate,
    required this.postingDate,
    required this.type,
    this.merchantName,
    this.location,
    this.isPending = false,
    this.receiptImagePath,
    this.notes,
  });

  /// Convert CreditCardTransaction to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creditCardId': creditCardId,
      'transactionId': transactionId,
      'categoryId': categoryId,
      'amount': amount,
      'description': description,
      'transactionDate': transactionDate.toIso8601String(),
      'postingDate': postingDate.toIso8601String(),
      'type': type.toString().split('.').last,
      'merchantName': merchantName,
      'location': location,
      'isPending': isPending,
      'receiptImagePath': receiptImagePath,
      'notes': notes,
    };
  }

  /// Create CreditCardTransaction from JSON data
  factory CreditCardTransaction.fromJson(Map<String, dynamic> json) {
    return CreditCardTransaction(
      id: json['id'] ?? '',
      creditCardId: json['creditCardId'] ?? '',
      transactionId: json['transactionId'] ?? '',
      categoryId: json['categoryId'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] ?? '',
      transactionDate: DateTime.tryParse(json['transactionDate'] ?? '') ?? DateTime.now(),
      postingDate: DateTime.tryParse(json['postingDate'] ?? '') ?? DateTime.now(),
      type: CreditCardTransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => CreditCardTransactionType.purchase,
      ),
      merchantName: json['merchantName'],
      location: json['location'],
      isPending: json['isPending'] ?? false,
      receiptImagePath: json['receiptImagePath'],
      notes: json['notes'],
    );
  }

  /// Create a copy of this credit card transaction with updated fields
  CreditCardTransaction copyWith({
    String? id,
    String? creditCardId,
    String? transactionId,
    String? categoryId,
    double? amount,
    String? description,
    DateTime? transactionDate,
    DateTime? postingDate,
    CreditCardTransactionType? type,
    String? merchantName,
    String? location,
    bool? isPending,
    String? receiptImagePath,
    String? notes,
  }) {
    return CreditCardTransaction(
      id: id ?? this.id,
      creditCardId: creditCardId ?? this.creditCardId,
      transactionId: transactionId ?? this.transactionId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      transactionDate: transactionDate ?? this.transactionDate,
      postingDate: postingDate ?? this.postingDate,
      type: type ?? this.type,
      merchantName: merchantName ?? this.merchantName,
      location: location ?? this.location,
      isPending: isPending ?? this.isPending,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      notes: notes ?? this.notes,
    );
  }

  /// Check if this is a purchase transaction
  bool get isPurchase => type == CreditCardTransactionType.purchase;

  /// Check if this is a payment transaction
  bool get isPayment => type == CreditCardTransactionType.payment;

  /// Check if this is an interest charge
  bool get isInterest => type == CreditCardTransactionType.interest;

  /// Check if this is a fee
  bool get isFee => type == CreditCardTransactionType.fee;

  /// Check if this is a refund
  bool get isRefund => type == CreditCardTransactionType.refund;

  /// Check if this is a cash advance
  bool get isCashAdvance => type == CreditCardTransactionType.cashAdvance;

  /// Get formatted amount with sign
  String get formattedAmount {
    final sign = isPayment || isRefund ? '+' : '-';
    return '$sign${amount.abs().toStringAsFixed(2)}';
  }

  /// Get display name for the transaction
  String get displayName {
    if (merchantName != null && merchantName!.isNotEmpty) {
      return merchantName!;
    }
    return description;
  }

  /// Get location display
  String get locationDisplay {
    if (location != null && location!.isNotEmpty) {
      return location!;
    }
    return '';
  }

  @override
  String toString() {
    return 'CreditCardTransaction(id: $id, type: $type, amount: $amount, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CreditCardTransaction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Enum representing different types of credit card transactions
@HiveType(typeId: 8)
enum CreditCardTransactionType {
  /// Purchase transaction - buying goods or services
  @HiveField(0)
  purchase,
  
  /// Payment transaction - paying down the balance
  @HiveField(1)
  payment,
  
  /// Interest charge - interest on outstanding balance
  @HiveField(2)
  interest,
  
  /// Fee transaction - annual fees, late fees, etc.
  @HiveField(3)
  fee,
  
  /// Refund transaction - money returned to the card
  @HiveField(4)
  refund,
  
  /// Cash advance - withdrawing cash from the card
  @HiveField(5)
  cashAdvance,
}
