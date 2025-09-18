import 'package:equatable/equatable.dart';
import '../models/transaction.dart';
import '../models/account.dart';
import '../models/category.dart' as app_category;

abstract class ExpenseState extends Equatable {
  const ExpenseState();

  @override
  List<Object?> get props => [];
}

class ExpenseInitial extends ExpenseState {
  const ExpenseInitial();
}

class ExpenseLoading extends ExpenseState {
  const ExpenseLoading();
}

class ExpenseLoaded extends ExpenseState {
  final List<Transaction> expenses;
  final List<Account> accounts;
  final List<app_category.Category> categories;
  final double totalExpenses;
  final double monthlyExpenses;

  const ExpenseLoaded({
    required this.expenses,
    required this.accounts,
    required this.categories,
    required this.totalExpenses,
    required this.monthlyExpenses,
  });

  @override
  List<Object?> get props => [
        expenses,
        accounts,
        categories,
        totalExpenses,
        monthlyExpenses,
      ];
}

class ExpenseError extends ExpenseState {
  final String message;

  const ExpenseError(this.message);

  @override
  List<Object?> get props => [message];
}
