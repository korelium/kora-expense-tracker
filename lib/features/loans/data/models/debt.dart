import 'package:hive/hive.dart';
part 'debt.g.dart';

@HiveType(typeId: 20)
class Debt extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String personName; // Who you owe money to or who owes you
  
  @HiveField(2)
  final double amount; // Total amount
  
  @HiveField(3)
  final double paidAmount; // Amount already paid
  
  @HiveField(4)
  final DateTime date; // When the debt was created
  
  @HiveField(5)
  final String? description; // Optional description
  
  @HiveField(6)
  final bool isYouOwe; // true = you owe them, false = they owe you
  
  @HiveField(7)
  final String? linkedAccountId; // Account used for payments
  
  @HiveField(8)
  final bool isPaidOff; // Is the debt fully paid
  
  @HiveField(9)
  final DateTime createdAt;
  
  @HiveField(10)
  final DateTime updatedAt;

  Debt({
    required this.id,
    required this.personName,
    required this.amount,
    this.paidAmount = 0.0,
    required this.date,
    this.description,
    required this.isYouOwe,
    this.linkedAccountId,
    this.isPaidOff = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get remaining amount
  double get remainingAmount => amount - paidAmount;
  
  /// Get percentage paid
  double get percentagePaid => amount > 0 ? (paidAmount / amount) * 100 : 0.0;
  
  /// Check if debt is fully paid
  bool get isFullyPaid => remainingAmount <= 0;

  Debt copyWith({
    String? id,
    String? personName,
    double? amount,
    double? paidAmount,
    DateTime? date,
    String? description,
    bool? isYouOwe,
    String? linkedAccountId,
    bool? isPaidOff,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Debt(
      id: id ?? this.id,
      personName: personName ?? this.personName,
      amount: amount ?? this.amount,
      paidAmount: paidAmount ?? this.paidAmount,
      date: date ?? this.date,
      description: description ?? this.description,
      isYouOwe: isYouOwe ?? this.isYouOwe,
      linkedAccountId: linkedAccountId ?? this.linkedAccountId,
      isPaidOff: isPaidOff ?? this.isPaidOff,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Debt(id: $id, personName: $personName, amount: $amount, paidAmount: $paidAmount, isYouOwe: $isYouOwe)';
  }
}

@HiveType(typeId: 21)
class DebtPayment extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String debtId;
  
  @HiveField(2)
  final double amount;
  
  @HiveField(3)
  final DateTime paymentDate;
  
  @HiveField(4)
  final String? description;
  
  @HiveField(5)
  final String? linkedAccountId;
  
  @HiveField(6)
  final DateTime createdAt;
  
  @HiveField(7)
  final List<String> proofImages;
  
  @HiveField(8)
  final String? transactionType; // 'payment' or 'give_money'

  DebtPayment({
    required this.id,
    required this.debtId,
    required this.amount,
    required this.paymentDate,
    this.description,
    this.linkedAccountId,
    required this.createdAt,
    this.proofImages = const [],
    this.transactionType,
  });

  DebtPayment copyWith({
    String? id,
    String? debtId,
    double? amount,
    DateTime? paymentDate,
    String? description,
    String? linkedAccountId,
    DateTime? createdAt,
    List<String>? proofImages,
    String? transactionType,
  }) {
    return DebtPayment(
      id: id ?? this.id,
      debtId: debtId ?? this.debtId,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      description: description ?? this.description,
      linkedAccountId: linkedAccountId ?? this.linkedAccountId,
      createdAt: createdAt ?? this.createdAt,
      proofImages: proofImages ?? this.proofImages,
      transactionType: transactionType ?? this.transactionType,
    );
  }

  @override
  String toString() {
    return 'DebtPayment(id: $id, debtId: $debtId, amount: $amount, paymentDate: $paymentDate)';
  }
}
