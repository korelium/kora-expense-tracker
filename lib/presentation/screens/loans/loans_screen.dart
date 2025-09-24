// File location: lib/presentation/screens/loans/loans_screen.dart
// Purpose: Main loans screen for managing loans and loan payments
// Author: Pown Kumar - Founder of Korelium
// Date: September 24, 2025

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/loan_provider.dart';
import '../../../data/providers/currency_provider.dart';
import '../../../data/models/loan.dart';
import '../../../data/models/loan_payment.dart';
import '../../../core/theme/app_theme.dart';

class LoansScreen extends StatefulWidget {
  const LoansScreen({super.key});

  @override
  State<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize loan provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LoanProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loans'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navigate to add loan screen - Planned for Phase 4 (Deep Refactoring)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Add loan functionality coming soon!'),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer2<LoanProvider, CurrencyProvider>(
        builder: (context, loanProvider, currencyProvider, child) {
          if (loanProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final loans = loanProvider.activeLoans;
          final analytics = loanProvider.getLoanAnalytics();

          if (loans.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () => loanProvider.refresh(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAnalyticsSection(analytics, currencyProvider),
                  const SizedBox(height: 24),
                  _buildLoansList(loans, currencyProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No Loans Yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first loan to start tracking payments and balances.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Navigate to add loan screen - Planned for Phase 4 (Deep Refactoring)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Add loan functionality coming soon!'),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Loan'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsSection(Map<String, dynamic> analytics, CurrencyProvider currencyProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Loan Overview',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildAnalyticsCard(
                'Total Balance',
                '${currencyProvider.currencySymbol}${analytics['totalBalance'].toStringAsFixed(2)}',
                Icons.account_balance_wallet,
                Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAnalyticsCard(
                'Monthly Payments',
                '${currencyProvider.currencySymbol}${analytics['totalMonthlyPayments'].toStringAsFixed(2)}',
                Icons.payment,
                Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildAnalyticsCard(
                'Active Loans',
                '${analytics['totalLoans']}',
                Icons.list_alt,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAnalyticsCard(
                'Avg Interest Rate',
                '${analytics['averageInterestRate'].toStringAsFixed(2)}%',
                Icons.trending_up,
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnalyticsCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoansList(List<Loan> loans, CurrencyProvider currencyProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Loans',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        ...loans.map((loan) => _buildLoanCard(loan, currencyProvider)),
      ],
    );
  }

  Widget _buildLoanCard(Loan loan, CurrencyProvider currencyProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getLoanIcon(loan.type),
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loan.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      loan.type.displayName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  _handleLoanAction(value, loan);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'view',
                    child: Text('View Details'),
                  ),
                  const PopupMenuItem(
                    value: 'payment',
                    child: Text('Make Payment'),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildLoanInfo(
                  'Current Balance',
                  '${currencyProvider.currencySymbol}${loan.currentBalance.toStringAsFixed(2)}',
                ),
              ),
              Expanded(
                child: _buildLoanInfo(
                  'Monthly Payment',
                  '${currencyProvider.currencySymbol}${loan.monthlyPayment.toStringAsFixed(2)}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildLoanInfo(
                  'Interest Rate',
                  '${loan.interestRate.toStringAsFixed(2)}%',
                ),
              ),
              Expanded(
                child: _buildLoanInfo(
                  'Progress',
                  '${loan.progressPercentage.toStringAsFixed(1)}%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: loan.progressPercentage / 100,
            backgroundColor: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoanInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  IconData _getLoanIcon(LoanType type) {
    switch (type) {
      case LoanType.personal:
        return Icons.account_balance_wallet;
      case LoanType.mortgage:
        return Icons.home;
      case LoanType.auto:
        return Icons.directions_car;
      case LoanType.student:
        return Icons.school;
      case LoanType.business:
        return Icons.business;
      case LoanType.homeEquity:
        return Icons.home_work;
      case LoanType.creditLine:
        return Icons.credit_card;
      case LoanType.other:
        return Icons.account_balance;
    }
  }

  void _handleLoanAction(String action, Loan loan) {
    switch (action) {
      case 'view':
        // TODO: Navigate to loan details screen - Planned for Phase 4 (Deep Refactoring)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Loan details functionality coming soon!'),
          ),
        );
        break;
      case 'payment':
        // TODO: Show payment dialog - Planned for Phase 4 (Deep Refactoring)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment functionality coming soon!'),
          ),
        );
        break;
      case 'edit':
        // TODO: Navigate to edit loan screen - Planned for Phase 4 (Deep Refactoring)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Edit loan functionality coming soon!'),
          ),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(loan);
        break;
    }
  }

  void _showDeleteConfirmation(Loan loan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Loan'),
        content: Text('Are you sure you want to delete "${loan.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<LoanProvider>().deleteLoan(loan.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${loan.name} deleted successfully'),
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
