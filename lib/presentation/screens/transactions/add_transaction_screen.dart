import 'package:flutter/material.dart';
import '../../../data/models/transaction.dart';
import '../../widgets/transaction_form/transaction_form_screen.dart';

/// Add Transaction Screen - Redirects to the new refactored form
/// Author: Pown Kumar - Founder of Korelium
/// Date: September 18, 2025

class AddTransactionScreen extends StatelessWidget {
  final Transaction? transaction;
  final TransactionType? initialType;

  const AddTransactionScreen({super.key, this.transaction, this.initialType});

  @override
  Widget build(BuildContext context) {
    return TransactionFormScreen(
      transaction: transaction,
      initialType: initialType,
    );
  }
}