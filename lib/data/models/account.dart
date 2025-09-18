// File location: lib/data/models/account.dart
// Purpose: Account data model for managing different types of financial accounts
// Author: Pown Kumar - Founder of Korelium
// Date: September 18, 2025

import 'package:hive/hive.dart';

part 'account.g.dart';

/// Account model representing different types of financial accounts
/// Supports both assets (bank, cash, investment) and liabilities (credit card)
@HiveType(typeId: 4)
class Account extends HiveObject {
  /// Unique identifier for the account
  @HiveField(0)
  final String id;
  
  /// Display name of the account
  @HiveField(1)
  final String name;
  
  /// Current balance of the account
  /// For assets: positive balance = money available
  /// For liabilities: positive balance = debt owed
  @HiveField(2)
  final double balance;
  
  /// Type of account (bank, cash, credit card, etc.)
  @HiveField(3)
  final AccountType type;
  
  /// Optional description or notes about the account
  @HiveField(4)
  final String? description;

  /// Constructor for Account model
  Account({
    required this.id,
    required this.name,
    required this.balance,
    required this.type,
    this.description,
  });

  /// Convert Account to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'type': type.toString().split('.').last,
      'description': description,
    };
  }

  /// Create Account from JSON data
  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Account',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      type: AccountType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => AccountType.bank, // Default to bank if not found
      ),
      description: json['description'],
    );
  }

  /// Create a copy of this account with updated fields
  Account copyWith({
    String? id,
    String? name,
    double? balance,
    AccountType? type,
    String? description,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      type: type ?? this.type,
      description: description ?? this.description,
    );
  }

  /// Check if this account is a liability (debt)
  /// Since we only have Cash and Bank (both assets), this always returns false
  bool get isLiability => false;

  /// Check if this account is an asset (money owned)
  /// Cash and Bank accounts are both considered assets
  bool get isAsset => !isLiability;

  /// Get the effective balance for calculations
  /// For assets: returns positive balance
  /// For liabilities: returns negative balance (debt)
  double get effectiveBalance => isLiability ? -balance : balance;

  @override
  String toString() {
    return 'Account(id: $id, name: $name, type: $type, balance: $balance)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Account && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Enum representing different types of financial accounts
/// Categorizes accounts into assets and liabilities
@HiveType(typeId: 1)
enum AccountType {
  /// Bank account - traditional checking/savings account (Asset)
  @HiveField(0)
  bank,
  
  /// Cash account - physical cash or petty cash (Asset)
  @HiveField(1)
  cash,
}
