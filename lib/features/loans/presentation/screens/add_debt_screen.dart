import 'package:flutter/material.dart';
import '../widgets/debt_form.dart';

/// Add Debt Screen - Full page for creating new debts
/// Author: Pown Kumar - Founder of Korelium
/// Date: September 23, 2025

class AddDebtScreen extends StatelessWidget {
  final bool defaultIsYouOwe;

  const AddDebtScreen({
    super.key,
    this.defaultIsYouOwe = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          defaultIsYouOwe ? 'Add New Debt' : 'Add Money Owed to You',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: DebtForm(defaultIsYouOwe: defaultIsYouOwe),
    );
  }
}
