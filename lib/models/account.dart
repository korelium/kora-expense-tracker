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
      id: json['id'],
      name: json['name'],
      balance: (json['balance'] as num).toDouble(),
      type: AccountType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      description: json['description'],
    );
  }
}

enum AccountType {
  bank,
  cash,
  creditCard,
  investment,
}
