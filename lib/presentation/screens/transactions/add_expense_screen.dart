import 'package:flutter/material.dart';
import '../../../data/models/transaction.dart';
import 'add_transaction_screen.dart';

/// Legacy Add Expense Screen
/// Redirects to the new Add Transaction Screen
/// Author: Pown Kumar - Founder of Korelium
/// Date: September 18, 2025

class AddExpenseScreen extends StatelessWidget {
  final Transaction? expense;
  final TransactionType? initialType;

  const AddExpenseScreen({super.key, this.expense, this.initialType});

  @override
  Widget build(BuildContext context) {
    return AddTransactionScreen(
      transaction: expense,
      initialType: initialType,
    );
  }
}