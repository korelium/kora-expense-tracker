class Account {
  final String id;
  final String name;
  final double balance;
  final AccountType type;
  final String? description;

  Account({
    required this.id,
    required this.name,
    required this.balance,
    required this.type,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'type': type.toString().split('.').last,
      'description': description,
    };
  }

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
}

enum AccountType {
  bank,
  cash,
  creditCard, // This is a liability
  investment,
  liability, // General liability account
}
