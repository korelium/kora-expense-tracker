import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'expense_event.dart';
import 'expense_state.dart';
import '../models/transaction.dart';
import '../models/account.dart';
import '../models/category.dart' as app_category;

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  ExpenseBloc() : super(const ExpenseInitial()) {
    on<LoadExpenses>(_onLoadExpenses);
    on<AddExpense>(_onAddExpense);
    on<UpdateExpense>(_onUpdateExpense);
    on<DeleteExpense>(_onDeleteExpense);
  }

  Future<void> _onLoadExpenses(LoadExpenses event, Emitter<ExpenseState> emit) async {
    emit(const ExpenseLoading());
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load expenses
      final expensesJson = prefs.getString('expenses');
      List<Transaction> expenses = [];
      if (expensesJson != null) {
        final List<dynamic> expensesList = json.decode(expensesJson);
        expenses = expensesList
            .map((json) => Transaction.fromJson(json))
            .where((transaction) => transaction.type == TransactionType.expense)
            .toList();
      }

      // Load accounts
      final accountsJson = prefs.getString('accounts');
      List<Account> accounts = [];
      if (accountsJson != null) {
        final List<dynamic> accountsList = json.decode(accountsJson);
        accounts = accountsList.map((json) => Account.fromJson(json)).toList();
      }

      // Load categories
      final categoriesJson = prefs.getString('categories');
      List<app_category.Category> categories = [];
      if (categoriesJson != null) {
        final List<dynamic> categoriesList = json.decode(categoriesJson);
        categories = categoriesList
            .map((json) => app_category.Category.fromJson(json))
            .where((category) => category.type == app_category.CategoryType.expense)
            .toList();
      }

      // Calculate totals
      final totalExpenses = expenses.fold(0.0, (sum, expense) => sum + expense.amount);
      
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);
      
      final monthlyExpenses = expenses
          .where((expense) => 
              expense.date.isAfter(startOfMonth) && 
              expense.date.isBefore(endOfMonth))
          .fold(0.0, (sum, expense) => sum + expense.amount);

      emit(ExpenseLoaded(
        expenses: expenses,
        accounts: accounts,
        categories: categories,
        totalExpenses: totalExpenses,
        monthlyExpenses: monthlyExpenses,
      ));
    } catch (e) {
      emit(ExpenseError('Failed to load expenses: $e'));
    }
  }

  Future<void> _onAddExpense(AddExpense event, Emitter<ExpenseState> emit) async {
    try {
      if (state is ExpenseLoaded) {
        final currentState = state as ExpenseLoaded;
        
        if (event.expense.type != TransactionType.expense) {
          emit(ExpenseError('Transaction must be of type expense'));
          return;
        }

        final updatedExpenses = List<Transaction>.from(currentState.expenses)
          ..add(event.expense);

        await _saveExpenses(updatedExpenses);

        // Recalculate totals
        final totalExpenses = updatedExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
        
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 0);
        
        final monthlyExpenses = updatedExpenses
            .where((expense) => 
                expense.date.isAfter(startOfMonth) && 
                expense.date.isBefore(endOfMonth))
            .fold(0.0, (sum, expense) => sum + expense.amount);

        emit(ExpenseLoaded(
          expenses: updatedExpenses,
          accounts: currentState.accounts,
          categories: currentState.categories,
          totalExpenses: totalExpenses,
          monthlyExpenses: monthlyExpenses,
        ));
      }
    } catch (e) {
      emit(ExpenseError('Failed to add expense: $e'));
    }
  }

  Future<void> _onUpdateExpense(UpdateExpense event, Emitter<ExpenseState> emit) async {
    try {
      if (state is ExpenseLoaded) {
        final currentState = state as ExpenseLoaded;
        
        if (event.expense.type != TransactionType.expense) {
          emit(ExpenseError('Transaction must be of type expense'));
          return;
        }

        final updatedExpenses = List<Transaction>.from(currentState.expenses);
        final index = updatedExpenses.indexWhere((expense) => expense.id == event.expense.id);
        
        if (index != -1) {
          updatedExpenses[index] = event.expense;
          await _saveExpenses(updatedExpenses);

          // Recalculate totals
          final totalExpenses = updatedExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
          
          final now = DateTime.now();
          final startOfMonth = DateTime(now.year, now.month, 1);
          final endOfMonth = DateTime(now.year, now.month + 1, 0);
          
          final monthlyExpenses = updatedExpenses
              .where((expense) => 
                  expense.date.isAfter(startOfMonth) && 
                  expense.date.isBefore(endOfMonth))
              .fold(0.0, (sum, expense) => sum + expense.amount);

          emit(ExpenseLoaded(
            expenses: updatedExpenses,
            accounts: currentState.accounts,
            categories: currentState.categories,
            totalExpenses: totalExpenses,
            monthlyExpenses: monthlyExpenses,
          ));
        }
      }
    } catch (e) {
      emit(ExpenseError('Failed to update expense: $e'));
    }
  }

  Future<void> _onDeleteExpense(DeleteExpense event, Emitter<ExpenseState> emit) async {
    try {
      if (state is ExpenseLoaded) {
        final currentState = state as ExpenseLoaded;
        
        final updatedExpenses = currentState.expenses
            .where((expense) => expense.id != event.expenseId)
            .toList();

        await _saveExpenses(updatedExpenses);

        // Recalculate totals
        final totalExpenses = updatedExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
        
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 0);
        
        final monthlyExpenses = updatedExpenses
            .where((expense) => 
                expense.date.isAfter(startOfMonth) && 
                expense.date.isBefore(endOfMonth))
            .fold(0.0, (sum, expense) => sum + expense.amount);

        emit(ExpenseLoaded(
          expenses: updatedExpenses,
          accounts: currentState.accounts,
          categories: currentState.categories,
          totalExpenses: totalExpenses,
          monthlyExpenses: monthlyExpenses,
        ));
      }
    } catch (e) {
      emit(ExpenseError('Failed to delete expense: $e'));
    }
  }

  Future<void> _saveExpenses(List<Transaction> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    final expensesJson = json.encode(
      expenses.map((e) => e.toJson()).toList(),
    );
    await prefs.setString('expenses', expensesJson);
  }
}
