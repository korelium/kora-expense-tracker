import 'package:flutter/material.dart';
import '../widgets/debt_form.dart';
import '../../data/models/debt.dart';

/// Edit Debt Screen - Full page for editing existing debts
/// Author: Pown Kumar - Founder of Korelium
/// Date: September 23, 2025

class EditDebtScreen extends StatelessWidget {
  final Debt debt;

  const EditDebtScreen({
    super.key,
    required this.debt,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Edit Debt',
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
      body: DebtForm(
        debt: debt,
        isEditing: true,
      ),
    );
  }
}
