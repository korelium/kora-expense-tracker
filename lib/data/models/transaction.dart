// File location: lib/data/models/transaction.dart
// Purpose: Transaction data model for income and expense tracking
// Author: Pown Kumar - Founder of Korelium
// Date: September 18, 2025

import 'package:hive/hive.dart';

part 'transaction.g.dart';

/// Transaction model representing financial transactions (income/expense)
/// Contains all necessary data for tracking money flow in the app
@HiveType(typeId: 3)
class Transaction extends HiveObject {
  /// Unique identifier for the transaction
  @HiveField(0)
  final String id;
  
  /// ID of the account this transaction belongs to
  @HiveField(1)
  final String accountId;
  
  /// ID of the category this transaction belongs to
  @HiveField(2)
  final String categoryId;
  
  /// ID of the subcategory this transaction belongs to (optional)
  @HiveField(3)
  final String? subcategoryId;
  
  /// Amount of money involved in the transaction
  @HiveField(4)
  final double amount;
  
  /// Description or note about the transaction
  @HiveField(5)
  final String description;
  
  /// Date when the transaction occurred
  @HiveField(6)
  final DateTime date;
  
  /// Type of transaction (income or expense)
  @HiveField(7)
  final TransactionType type;
  
  /// Path to receipt image (optional)
  @HiveField(8)
  final String? receiptImagePath;

  /// Constructor for Transaction model
  Transaction({
    required this.id,
    required this.accountId,
    required this.categoryId,
    this.subcategoryId,
    required this.amount,
    required this.description,
    required this.date,
    required this.type,
    this.receiptImagePath,
  });

  /// Convert Transaction to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountId': accountId,
      'categoryId': categoryId,
      'subcategoryId': subcategoryId,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'type': type.toString().split('.').last,
      'receiptImagePath': receiptImagePath,
    };
  }

  /// Create Transaction from JSON data
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? '',
      accountId: json['accountId'] ?? '',
      categoryId: json['categoryId'] ?? '',
      subcategoryId: json['subcategoryId'],
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      type: TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => TransactionType.expense, // Default to expense if not found
      ),
      receiptImagePath: json['receiptImagePath'],
    );
  }

  /// Create a copy of this transaction with updated fields
  Transaction copyWith({
    String? id,
    String? accountId,
    String? categoryId,
    String? subcategoryId,
    double? amount,
    String? description,
    DateTime? date,
    TransactionType? type,
    String? receiptImagePath,
  }) {
    return Transaction(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      type: type ?? this.type,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
    );
  }

  @override
  String toString() {
    return 'Transaction(id: $id, type: $type, amount: $amount, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Enum representing the type of transaction
/// Used to categorize financial activities
@HiveType(typeId: 0)
enum TransactionType {
  /// Income transaction - money coming in
  @HiveField(0)
  income,
  
  /// Expense transaction - money going out
  @HiveField(1)
  expense,
}
