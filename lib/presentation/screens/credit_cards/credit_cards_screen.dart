// File location: lib/presentation/screens/credit_cards/credit_cards_screen.dart
// Purpose: Main credit cards screen showing all credit cards
// Author: Pown Kumar - Founder of Korelium
// Date: September 23, 2025

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/credit_card_provider.dart';
import '../../../data/providers/currency_provider.dart';
import '../../../data/providers/transaction_provider_hive.dart';
import '../../../data/models/credit_card.dart';
import '../../../core/theme/app_theme.dart';
import 'add_credit_card_screen.dart';
import 'credit_card_details_screen.dart';

/// Main credit cards screen
/// Shows all credit cards with their balances and quick actions
class CreditCardsScreen extends StatefulWidget {
  const CreditCardsScreen({super.key});

  @override
  State<CreditCardsScreen> createState() => _CreditCardsScreenState();
}

class _CreditCardsScreenState extends State<CreditCardsScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Credit Cards',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryBlue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _navigateToAddCreditCard(context),
            tooltip: 'Add Credit Card',
          ),
        ],
      ),
      body: Consumer2<CreditCardProvider, CurrencyProvider>(
        builder: (context, creditCardProvider, currencyProvider, child) {
          if (creditCardProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryBlue,
              ),
            );
          }

          if (creditCardProvider.error != null) {
            return _buildErrorWidget(creditCardProvider.error!);
          }

          if (creditCardProvider.creditCards.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () => creditCardProvider.refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCards(creditCardProvider, currencyProvider),
                  const SizedBox(height: 24),
                  _buildCreditCardsList(creditCardProvider, currencyProvider),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddCreditCard(context),
        backgroundColor: AppTheme.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryCards(CreditCardProvider creditCardProvider, CurrencyProvider currencyProvider) {
    return Column(
      children: [
        // Overall Credit Card Overview Card
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryBlue.withValues(alpha: 0.1),
                AppTheme.primaryBlue.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.primaryBlue.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.credit_card,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Credit Card Overview',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        Text(
                          '${creditCardProvider.activeCreditCards.length} active cards',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Summary Stats
              Row(
                children: [
                  Expanded(
                    child: _buildOverviewItem(
                      'Total Credit Limit',
                      currencyProvider.formatAmount(creditCardProvider.totalCreditLimit),
                      Icons.account_balance,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildOverviewItem(
                      'Current Balance',
                      currencyProvider.formatAmount(creditCardProvider.totalCurrentBalance),
                      Icons.credit_card,
                      Colors.red,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: _buildOverviewItem(
                      'Available Credit',
                      currencyProvider.formatAmount(creditCardProvider.totalAvailableCredit),
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildOverviewItem(
                      'Overall Utilization',
                      '${creditCardProvider.overallCreditUtilization.toStringAsFixed(1)}%',
                      Icons.trending_up,
                      creditCardProvider.isOverallUtilizationHigh ? Colors.red : Colors.orange,
                    ),
                  ),
                ],
              ),
              
              // Warnings Section (Due Soon warnings hidden for now)
              if (creditCardProvider.isOverallUtilizationHigh || 
                  creditCardProvider.highUtilizationCardsCount > 0) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 12),
                
                // Overall Utilization Warning
                if (creditCardProvider.isOverallUtilizationHigh)
                  _buildWarningItem(
                    Icons.warning,
                    Colors.orange,
                    'Overall credit utilization is ${creditCardProvider.overallCreditUtilization.toStringAsFixed(1)}% (above 30% threshold)',
                  ),
                
                // High Utilization Cards Warning
                if (creditCardProvider.highUtilizationCardsCount > 0)
                  _buildWarningItem(
                    Icons.error_outline,
                    Colors.red,
                    '${creditCardProvider.highUtilizationCardsCount} card(s) exceed 30% utilization',
                  ),
                
                // Due Soon/Overdue Warning - HIDDEN FOR NOW
                // if (creditCardProvider.creditCardsWithDuePayments.isNotEmpty)
                //   _buildWarningItem(
                //     Icons.schedule,
                //     Colors.orange,
                //     '${creditCardProvider.creditCardsWithDuePayments.length} card(s) have payments due soon or overdue',
                //   ),
              ],
            ],
          ),
        ),
      ],
    );
  }



  Widget _buildOverviewItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningItem(IconData icon, Color color, String message) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditCardsList(CreditCardProvider creditCardProvider, CurrencyProvider currencyProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Credit Cards',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        ...creditCardProvider.creditCards.map((creditCard) => 
          _buildCompactCreditCardCard(creditCard, creditCardProvider, currencyProvider)
        ),
      ],
    );
  }

  Widget _buildCompactCreditCardCard(CreditCard creditCard, CreditCardProvider creditCardProvider, CurrencyProvider currencyProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _navigateToCreditCardDetails(context, creditCard),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and name
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.credit_card,
                      color: AppTheme.primaryBlue,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      creditCard.displayName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Delete button for credit card
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        _confirmDeleteCreditCard(context, creditCard);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete Credit Card'),
                          ],
                        ),
                      ),
                    ],
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.more_vert,
                        color: Colors.black54,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Bank name
              Text(
                creditCard.bankName,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              
              // Balance info
              _buildCompactBalanceInfo('Balance', creditCard.formattedCurrentBalance(currencyProvider.currencySymbol), Colors.red),
              const SizedBox(height: 4),
              _buildCompactBalanceInfo('Available', creditCard.formattedAvailableCredit(currencyProvider.currencySymbol), Colors.green),
              const SizedBox(height: 4),
              _buildCompactBalanceInfo('Credit Limit', creditCard.formattedCreditLimit(currencyProvider.currencySymbol), Colors.blue),
              const SizedBox(height: 4),
              _buildCompactBalanceInfo('Safe Limit (30%)', currencyProvider.formatAmount(creditCard.creditLimit * 0.3), Colors.orange),
              
              // Progress Bar for Utilization
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Credit Usage',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        creditCard.formattedCreditUtilization,
                        style: TextStyle(
                          fontSize: 10,
                          color: creditCard.creditUtilization.abs() > 30 ? Colors.red : Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: (creditCard.creditUtilization.abs() / 100).clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: creditCard.creditUtilization.abs() > 30 ? Colors.red : Colors.blue,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              // 30% Threshold Warning
              if (creditCard.creditUtilization.abs() > 30) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning, color: Colors.red.shade700, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        'High Utilization (${creditCard.creditUtilization.abs().toStringAsFixed(1)}%)',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Due date warning - HIDDEN FOR NOW
              // if (creditCard.isPaymentDueSoon || creditCard.isOverdue) ...[
              //   const SizedBox(height: 8),
              //   Container(
              //     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              //     decoration: BoxDecoration(
              //       color: creditCard.isOverdue ? Colors.red : Colors.orange,
              //       borderRadius: BorderRadius.circular(8),
              //     ),
              //     child: Text(
              //       creditCard.isOverdue ? 'Overdue' : 'Due Soon',
              //       style: TextStyle(
              //         color: Theme.of(context).colorScheme.surface,
              //         fontSize: 10,
              //         fontWeight: FontWeight.w600,
              //       ),
              //     ),
              //   ),
              // ],
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildCompactBalanceInfo(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }


  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.credit_card,
                size: 64,
                color: AppTheme.primaryBlue.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Credit Cards Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first credit card to start tracking your spending and payments',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _navigateToAddCreditCard(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Credit Card'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Credit Cards',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<CreditCardProvider>().refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAddCreditCard(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddCreditCardScreen(),
      ),
    );
  }

  void _navigateToCreditCardDetails(BuildContext context, CreditCard creditCard) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreditCardDetailsScreen(creditCard: creditCard),
      ),
    );
  }

  void _confirmDeleteCreditCard(BuildContext context, CreditCard creditCard) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Credit Card'),
        content: Text('Are you sure you want to delete "${creditCard.displayName}"? This will also delete the associated account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteCreditCard(context, creditCard);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCreditCard(BuildContext context, CreditCard creditCard) async {
    try {
      final creditCardProvider = Provider.of<CreditCardProvider>(context, listen: false);
      final transactionProvider = Provider.of<TransactionProviderHive>(context, listen: false);
      
      // Find the associated account
      final account = transactionProvider.accounts.firstWhere(
        (acc) => acc.id == creditCard.accountId,
        orElse: () => throw Exception('Associated account not found'),
      );
      
      // Delete credit card
      await creditCardProvider.deleteCreditCard(creditCard.id);
      
      // Delete associated account
      await transactionProvider.deleteAccount(account.id);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Credit card deleted successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting credit card: $e')),
        );
      }
    }
  }
}
