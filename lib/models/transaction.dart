class Transaction {
  final String id;
  final String accountId;
  final String categoryId;
  final double amount;
  final String description;
  final DateTime date;
  final TransactionType type;

  Transaction({
    required this.id,
    required this.accountId,
    required this.categoryId,
    required this.amount,
    required this.description,
    required this.date,
    required this.type,
  });

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

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      accountId: json['accountId'],
      categoryId: json['categoryId'],
      amount: (json['amount'] as num).toDouble(),
      description: json['description'],
      date: DateTime.parse(json['date']),
      type: TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
    );
  }
}

enum TransactionType {
  income,
  expense,
}
