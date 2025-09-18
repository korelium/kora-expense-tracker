import 'package:equatable/equatable.dart';
import '../models/transaction.dart';

abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object?> get props => [];
}

class LoadExpenses extends ExpenseEvent {
  const LoadExpenses();
}

class AddExpense extends ExpenseEvent {
  final Transaction expense;

  const AddExpense(this.expense);

  @override
  List<Object?> get props => [expense];
}

class UpdateExpense extends ExpenseEvent {
  final Transaction expense;

  const UpdateExpense(this.expense);

  @override
  List<Object?> get props => [expense];
}

class DeleteExpense extends ExpenseEvent {
  final String expenseId;

  const DeleteExpense(this.expenseId);

  @override
  List<Object?> get props => [expenseId];
}
