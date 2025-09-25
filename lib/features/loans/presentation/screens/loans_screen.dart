import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../../../data/providers/currency_provider.dart';
import '../../data/providers/debt_provider.dart';
import '../../data/models/debt.dart';
import '../widgets/payment_form.dart';
import '../widgets/give_money_form.dart';
import '../widgets/receive_money_form.dart';
import 'add_debt_screen.dart';
import 'edit_debt_screen.dart';
import '../widgets/payment_proof_gallery.dart';

class LoansScreen extends StatefulWidget {
  const LoansScreen({super.key});

  @override
  State<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loans & Debts'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.build),
            onPressed: () => _fixCorruptedDebts(),
            tooltip: 'Fix Corrupted Data',
          ),
        ],
      ),
      body: Consumer2<DebtProvider, CurrencyProvider>(
        builder: (context, debtProvider, currencyProvider, child) {
          if (!debtProvider.isInitialized) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          return Column(
            children: [
              // Overall Summary Card
              _buildOverallSummaryCard(debtProvider, currencyProvider),
              
              // Tab Bar
              TabBar(
                controller: _tabController,
                labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                indicatorPadding: const EdgeInsets.symmetric(horizontal: 16),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.arrow_upward, color: Colors.red, size: 18),
                    text: 'I Owe',
                    height: 40,
                  ),
                  Tab(
                    icon: Icon(Icons.arrow_downward, color: Colors.green, size: 18),
                    text: 'Owed to Me',
                    height: 40,
                  ),
                ],
              ),
              
              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildIOweTab(debtProvider, currencyProvider),
                    _buildOwedToMeTab(debtProvider, currencyProvider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDebtDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildOverallSummaryCard(DebtProvider debtProvider, CurrencyProvider currencyProvider) {
    final analytics = debtProvider.analytics;
    final totalYouOwe = analytics['remainingYouOwe'] ?? 0.0;
    final totalOwedToYou = analytics['remainingOwedToYou'] ?? 0.0;
    final netDebt = analytics['netDebt'] ?? 0.0;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Overall Debt Summary',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'You Owe',
                  totalYouOwe,
                  Colors.red,
                  Icons.arrow_upward,
                  currencyProvider,
                ),
              ),
              Container(
                width: 1,
                height: 32,
                color: Colors.grey.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Owed to You',
                  totalOwedToYou,
                  Colors.green,
                  Icons.arrow_downward,
                  currencyProvider,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: netDebt >= 0 
                ? Colors.green.withValues(alpha: 0.2)
                : Colors.red.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  netDebt >= 0 ? Icons.trending_up : Icons.trending_down,
                  color: netDebt >= 0 ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Net: ${currencyProvider.formatAmount(netDebt.abs())}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: netDebt >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  netDebt >= 0 ? 'in your favor' : 'you owe more',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: netDebt >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String title,
    double amount,
    Color color,
    IconData icon,
    CurrencyProvider currencyProvider,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 3),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          currencyProvider.formatAmount(amount),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildIOweTab(DebtProvider debtProvider, CurrencyProvider currencyProvider) {
    final debts = debtProvider.debtsYouOwe;
    
    return _buildDebtsList(debts, true, currencyProvider);
  }

  Widget _buildOwedToMeTab(DebtProvider debtProvider, CurrencyProvider currencyProvider) {
    final debts = debtProvider.debtsOwedToYou;
    
    return _buildDebtsList(debts, false, currencyProvider);
  }



  Widget _buildDebtsList(List<Debt> debts, bool isYouOwe, CurrencyProvider currencyProvider) {
    if (debts.isEmpty) {
      return _buildEmptyState(isYouOwe);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: debts.length,
      itemBuilder: (context, index) {
        final debt = debts[index];
        return _buildDebtCard(debt, isYouOwe, currencyProvider);
      },
    );
  }

  Widget _buildDebtCard(Debt debt, bool isYouOwe, CurrencyProvider currencyProvider) {
    final amount = debt.amount;
    final paidAmount = debt.paidAmount;
    final remainingAmount = debt.remainingAmount;
    final percentagePaid = debt.percentagePaid;
    
    // Modern color scheme
    final primaryColor = isYouOwe ? const Color(0xFFE53E3E) : const Color(0xFF38A169);
    final lightColor = isYouOwe ? const Color(0xFFFED7D7) : const Color(0xFFC6F6D5);
    final darkColor = isYouOwe ? const Color(0xFF742A2A) : const Color(0xFF22543D);

    return Container(
      margin: const EdgeInsets.only(bottom: 6), 
      child: Material(
        elevation: 0,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _showDebtDetails(debt),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  lightColor.withValues(alpha: 0.3),
                  lightColor.withValues(alpha: 0.1),
                ],
              ),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    children: [
                      // Modern Avatar with gradient
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [primaryColor, primaryColor.withValues(alpha: 0.7)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          isYouOwe ? Icons.trending_up : Icons.trending_down,
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
                              debt.personName,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: darkColor,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              debt.description ?? 'No description',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: percentagePaid == 100 ? Colors.green : primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          percentagePaid == 100 ? 'Completed' : 'Active',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 6),
                  
                  // Amount Cards Row
                  Row(
                    children: [
                      // Total Amount Card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                currencyProvider.formatAmount(amount),
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: darkColor,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Paid Amount Card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Paid',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.green.shade700,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                currencyProvider.formatAmount(paidAmount),
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Remaining Amount Card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Remaining',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.red.shade700,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                currencyProvider.formatAmount(remainingAmount),
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 6),
                  
                  // Modern Progress Bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progress',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${percentagePaid.toStringAsFixed(1)}%',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: percentagePaid / 100,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [primaryColor, primaryColor.withValues(alpha: 0.7)],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 6),
                  
                  // Modern Action Buttons
                  Row(
                    children: [
                      // Primary Action Button
                      Expanded(
                        child: Container(
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [primaryColor, primaryColor.withValues(alpha: 0.8)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                if (debt.isYouOwe) {
                                  _showPaymentDialog(debt);
                                } else {
                                  _showGiveMoneyDialog(debt);
                                }
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.send_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    debt.isYouOwe ? 'Pay Money' : 'Give Money',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Secondary Action Button
                      Expanded(
                        child: Container(
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _showReceiveMoneyDialog(debt),
                              borderRadius: BorderRadius.circular(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.call_received_rounded,
                                    color: primaryColor,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    debt.isYouOwe ? 'Take More' : 'Get Money Back',
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isYouOwe) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isYouOwe ? Icons.arrow_upward : Icons.arrow_downward,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            isYouOwe ? 'No debts to pay' : 'No money owed to you',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isYouOwe 
              ? 'Add a debt when you borrow money from someone'
              : 'Add a debt when someone borrows money from you',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddDebtDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add Debt'),
          ),
        ],
      ),
    );
  }

  void _showAddDebtDialog() {
    // Determine default debt type based on current tab
    final isYouOwe = _tabController.index == 0;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddDebtScreen(defaultIsYouOwe: isYouOwe),
      ),
    );
  }

  void _showDebtDetails(Debt debt) {
    final currencyProvider = context.read<CurrencyProvider>();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header
              Consumer<DebtProvider>(
                builder: (context, debtProvider, child) {
                  final updatedDebt = debtProvider.getDebtById(debt.id) ?? debt;
                  
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          updatedDebt.isYouOwe 
                            ? Colors.red.withValues(alpha: 0.1)
                            : Colors.green.withValues(alpha: 0.1),
                          updatedDebt.isYouOwe 
                            ? Colors.red.withValues(alpha: 0.05)
                            : Colors.green.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: updatedDebt.isYouOwe 
                                ? Colors.red.withValues(alpha: 0.2)
                                : Colors.green.withValues(alpha: 0.2),
                              radius: 30,
                              child: Icon(
                                updatedDebt.isYouOwe ? Icons.arrow_upward : Icons.arrow_downward,
                                color: updatedDebt.isYouOwe ? Colors.red : Colors.green,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    updatedDebt.personName,
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    updatedDebt.isYouOwe ? 'You owe' : 'Owed to you',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: updatedDebt.isYouOwe ? Colors.red : Colors.green,
                                    ),
                                  ),
                                  if (updatedDebt.description != null)
                                    Text(
                                      updatedDebt.description!,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDetailCard(
                                'Total Amount',
                                currencyProvider.formatAmount(updatedDebt.amount),
                                Icons.account_balance_wallet,
                                Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildDetailCard(
                                'Remaining',
                                currencyProvider.formatAmount(updatedDebt.remainingAmount),
                                Icons.pending,
                                updatedDebt.isYouOwe ? Colors.red : Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: updatedDebt.percentagePaid / 100,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            updatedDebt.percentagePaid == 100 ? Colors.green : Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${updatedDebt.percentagePaid.toStringAsFixed(1)}% completed',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 16),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showEditDebtDialog(debt);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showDeleteConfirmation(debt);
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Payment History
              Expanded(
                child: Consumer<DebtProvider>(
                  builder: (context, debtProvider, child) {
                    final payments = debtProvider.getPaymentsForDebt(debt.id);
                    final updatedDebt = debtProvider.getDebtById(debt.id) ?? debt;
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment History (${payments.length})',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: payments.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.payment,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'No payments yet',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                controller: scrollController,
                                itemCount: payments.length,
                                itemBuilder: (context, index) {
                                  final payment = payments[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Payment Header
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                backgroundColor: Colors.green.withValues(alpha: 0.2),
                                                child: const Icon(Icons.payment, color: Colors.green),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      _getPaymentHistoryText(payment, updatedDebt),
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    Text(
                                                      _formatDate(payment.paymentDate),
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete, color: Colors.red),
                                                onPressed: () => _showDeletePaymentConfirmation(payment),
                                              ),
                                            ],
                                          ),
                                          
                                          // Description
                                          if (payment.description != null) ...[
                                            const SizedBox(height: 12),
                                            Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade50,
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: Colors.grey.shade200),
                                              ),
                                              child: Text(
                                                payment.description!,
                                                style: TextStyle(
                                                  color: Colors.grey[700],
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                          
                                          // Payment Proof Images
                                          if (payment.proofImages.isNotEmpty) ...[
                                            const SizedBox(height: 12),
                                            PaymentProofGallery(
                                              imagePaths: payment.proofImages,
                                              canEdit: false,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }



  void _showEditDebtDialog(Debt debt) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDebtScreen(debt: debt),
      ),
    );
  }

  void _showPaymentDialog(Debt debt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: PaymentForm(debt: debt),
        ),
      ),
    );
  }


  void _showDeletePaymentConfirmation(DebtPayment payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment'),
        content: const Text('Are you sure you want to delete this payment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final debtProvider = context.read<DebtProvider>();
              final success = await debtProvider.deletePayment(payment.id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment deleted successfully')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDeleteConfirmation(Debt debt) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Debt'),
        content: Text('Are you sure you want to delete the debt with ${debt.personName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final debtProvider = context.read<DebtProvider>();
              final success = await debtProvider.deleteDebt(debt.id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Debt deleted successfully')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showPaymentProofImages(Debt debt) {
    final debtProvider = context.read<DebtProvider>();
    final payments = debtProvider.getPaymentsForDebt(debt.id);
    
    // Collect all payment proof images
    final List<String> allImages = [];
    for (final payment in payments) {
      allImages.addAll(payment.proofImages);
    }
    
    if (allImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No payment proof images found')),
      );
      return;
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.image,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Proof Images',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'To: ${debt.personName} (${allImages.length} images)',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Images Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    controller: scrollController,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                    itemCount: allImages.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _showFullScreenImage(allImages[index]),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(allImages[index]),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.broken_image,
                                        color: Colors.grey,
                                        size: 32,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Failed to load',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullScreenImage(String imagePath) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              'Payment Proof',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.file(
                File(imagePath),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image,
                          color: Colors.white,
                          size: 64,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Failed to load image',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatBubble({
    required DebtPayment payment,
    required CurrencyProvider currencyProvider,
    required Debt updatedDebt,
  }) {
    // Determine if this is a received transaction (left side) or sent transaction (right side)
    final isReceived = payment.transactionType == 'receive_money';
    
    // Determine the transaction type and amount display
    String transactionText;
    String amountText;
    Color bubbleColor;
    Color textColor;
    IconData icon;
    
    if (payment.transactionType == 'receive_money') {
      // Taking more money (loan) - LEFT SIDE
      transactionText = 'Received money from ${updatedDebt.personName}';
      amountText = currencyProvider.formatAmount(payment.amount);
      bubbleColor = Colors.blue.shade100;
      textColor = Colors.blue.shade800;
      icon = Icons.call_received;
    } else if (payment.transactionType == 'give_money') {
      // Giving more money - RIGHT SIDE
      transactionText = 'Given money to ${updatedDebt.personName}';
      amountText = currencyProvider.formatAmount(payment.amount);
      bubbleColor = Colors.orange.shade100;
      textColor = Colors.orange.shade800;
      icon = Icons.send;
    } else {
      // Regular payment - RIGHT SIDE
      transactionText = 'Paid to ${updatedDebt.personName}';
      amountText = currencyProvider.formatAmount(payment.amount);
      bubbleColor = Colors.green.shade100;
      textColor = Colors.green.shade800;
      icon = Icons.payment;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isReceived ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (!isReceived) const Spacer(),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            child: Column(
              crossAxisAlignment: isReceived ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                // Chat bubble
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isReceived ? 4 : 18),
                      bottomRight: Radius.circular(isReceived ? 18 : 4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Transaction header
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 16, color: textColor),
                          const SizedBox(width: 6),
                          Text(
                            transactionText,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: textColor,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      
                      // Amount
                      Text(
                        amountText,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          fontSize: 16,
                        ),
                      ),
                      
                      // Description
                      if (payment.description != null && payment.description!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          payment.description!,
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Payment proof images
                if (payment.proofImages.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.6,
                    ),
                    child: PaymentProofGallery(
                      imagePaths: payment.proofImages,
                      canEdit: false,
                    ),
                  ),
                ],
                
                // Time and delete button
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(payment.paymentDate),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _showDeletePaymentConfirmation(payment),
                      child: Icon(
                        Icons.delete_outline,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isReceived) const Spacer(),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final paymentDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (paymentDate == today) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (paymentDate == yesterday) {
      return 'Yesterday ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  String _getPaymentHistoryText(DebtPayment payment, Debt debt) {
    final currencyProvider = context.read<CurrencyProvider>();
    final amount = currencyProvider.formatAmount(payment.amount);
    
    if (payment.transactionType == 'receive_money') {
      return 'Received $amount from ${debt.personName}';
    } else if (payment.transactionType == 'give_money') {
      return 'Given $amount to ${debt.personName}';
    } else {
      return 'Paid $amount to ${debt.personName}';
    }
  }

  void _showGiveMoneyDialog(Debt debt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.send, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Give Money',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'To: ${debt.personName}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Give Money Form
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: GiveMoneyForm(debt: debt),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReceiveMoneyDialog(Debt debt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.call_received, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Receive Money',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'From: ${debt.personName}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Receive Money Form
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: ReceiveMoneyForm(debt: debt),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _fixCorruptedDebts() async {
    final debtProvider = context.read<DebtProvider>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fix Corrupted Data'),
        content: const Text(
          'This will fix any corrupted debt calculations. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const AlertDialog(
                  content: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text('Fixing corrupted data...'),
                    ],
                  ),
                ),
              );
              
              await debtProvider.fixCorruptedDebts();
              
              if (context.mounted) {
                Navigator.pop(context); // Close loading dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Corrupted data has been fixed!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Fix'),
          ),
        ],
      ),
    );
  }
}
