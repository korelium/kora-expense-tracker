// File location: lib/data/models/transaction.dart
// Purpose: Transaction data model for income and expense tracking
// Author: Pown Kumar - Founder of Korelium
// Date: September 18, 2025

/// Transaction model representing financial transactions (income/expense)
/// Contains all necessary data for tracking money flow in the app
class Transaction {
  /// Unique identifier for the transaction
  final String id;
  
  /// ID of the account this transaction belongs to
  final String accountId;
  
  /// ID of the category this transaction belongs to
  final String categoryId;
  
  /// Amount of money involved in the transaction
  final double amount;
  
  /// Description or note about the transaction
  final String description;
  
  /// Date when the transaction occurred
  final DateTime date;
  
  /// Type of transaction (income or expense)
  final TransactionType type;

  /// Constructor for Transaction model
  Transaction({
    required this.id,
    required this.accountId,
    required this.categoryId,
    required this.amount,
    required this.description,
    required this.date,
    required this.type,
  });

  /// Convert Transaction to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountId': accountId,
      'categoryId': categoryId,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'type': type.toString().split('.').last,
    };
  }

  /// Create Transaction from JSON data
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? '',
      accountId: json['accountId'] ?? '',
      categoryId: json['categoryId'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      type: TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => TransactionType.expense, // Default to expense if not found
      ),
    );
  }

  /// Create a copy of this transaction with updated fields
  Transaction copyWith({
    String? id,
    String? accountId,
    String? categoryId,
    double? amount,
    String? description,
    DateTime? date,
    TransactionType? type,
  }) {
    return Transaction(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      type: type ?? this.type,
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
enum TransactionType {
  /// Income transaction - money coming in
  income,
  
  /// Expense transaction - money going out
  expense,
}
