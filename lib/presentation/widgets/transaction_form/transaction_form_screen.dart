import 'package:flutter/material.dart';
import '../../../data/models/transaction.dart';
import 'widgets/compact_transaction_form.dart';

/// Modern Transaction Form Screen
/// Now uses compact layout for better user experience
/// Author: Pown Kumar - Founder of Korelium
/// Date: September 18, 2025

class TransactionFormScreen extends StatelessWidget {
  final Transaction? transaction;
  final TransactionType? initialType;

  const TransactionFormScreen({
    super.key,
    this.transaction,
    this.initialType,
  });

  @override
  Widget build(BuildContext context) {
    return CompactTransactionForm(
      transaction: transaction,
      initialType: initialType,
    );
  }
}
