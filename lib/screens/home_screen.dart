import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/expense_provider.dart';
import '../widgets/currency_selector.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/theme_toggle.dart';
import '../widgets/dashboard_widgets.dart';
import '../widgets/mini_charts.dart';
import '../utils/financial_calculator.dart';
import 'accounts_screen.dart';
import 'analytics_screen.dart';
import 'more_screen.dart';
import 'expense_list_screen.dart';
import 'expense_analytics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeContent(),
    const AccountsScreen(),
    const AnalyticsScreen(),
    const MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            label: 'Accounts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning!';
    } else if (hour < 17) {
      return 'Good Afternoon!';
    } else {
      return 'Good Evening!';
    }
  }

  String _getHealthStatus(int score) {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    return 'Needs Attention';
  }

  Color _getHealthColor(int score) {
    if (score >= 80) return const Color(0xFF10B981); // Green
    if (score >= 60) return const Color(0xFF3B82F6); // Blue
    if (score >= 40) return const Color(0xFFF59E0B); // Yellow
    return const Color(0xFFEF4444); // Red
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<CurrencyProvider, TransactionProvider, ExpenseProvider>(
      builder: (context, currencyProvider, transactionProvider, expenseProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Kora Expense Tracker'),
            actions: [
              IconButton(
                icon: const Icon(Icons.currency_exchange),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const CurrencySelector(),
                  );
                },
              ),
              const ThemeToggle(isCompact: true),
              const SizedBox(width: 8),
            ],
          ),
          body: transactionProvider.transactions.isEmpty
              ? const EmptyStateWidget()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Enhanced Header with Greeting & Balance
                      Container(
                        height: 70,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _getGreeting(),
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Theme.of(context).colorScheme.onPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Total Balance',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      currencyProvider.formatAmount(transactionProvider.totalBalance),
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Theme.of(context).colorScheme.onPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Icon(
                                  Icons.account_balance_wallet,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Financial Health Score & Key Metrics
                      Row(
                        children: [
                          Expanded(
                            child: MetricCard(
                              title: 'Financial Health',
                              value: '${FinancialCalculator.calculateFinancialHealthScore(transactionProvider.transactions)}/100',
                              subtitle: _getHealthStatus(FinancialCalculator.calculateFinancialHealthScore(transactionProvider.transactions)),
                              icon: Icons.health_and_safety,
                              color: _getHealthColor(FinancialCalculator.calculateFinancialHealthScore(transactionProvider.transactions)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: MetricCard(
                              title: 'Savings Rate',
                              value: '${FinancialCalculator.calculateSavingsRate(transactionProvider.transactions).toStringAsFixed(1)}%',
                              subtitle: 'This month',
                              icon: Icons.savings,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Income vs Expenses
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF22C55E).withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    const Icon(Icons.trending_up, color: Colors.white, size: 20),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'Income',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          currencyProvider.formatAmount(transactionProvider.totalIncome),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    const Icon(Icons.trending_down, color: Colors.white, size: 20),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'Expenses',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          currencyProvider.formatAmount(transactionProvider.totalExpense),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Financial Insight
                      InsightCard(
                        insight: FinancialCalculator.getFinancialInsight(transactionProvider.transactions),
                        icon: Icons.lightbulb_outline,
                        color: const Color(0xFF3B82F6),
                      ),
                      const SizedBox(height: 16),
                      
                      // Top Categories
                      CategoryBreakdownCard(
                        categories: FinancialCalculator.getTopCategories(transactionProvider.transactions),
                        currencySymbol: currencyProvider.currencySymbol,
                      ),
                      const SizedBox(height: 16),
                      
                      // Mini Analytics Charts
                      Text(
                        'Analytics',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: MiniLineChart(
                              transactions: transactionProvider.transactions,
                              currencySymbol: currencyProvider.currencySymbol,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: MiniPieChart(
                              categories: FinancialCalculator.getTopCategories(transactionProvider.transactions),
                              currencySymbol: currencyProvider.currencySymbol,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      MiniBarChart(
                        transactions: transactionProvider.transactions,
                        currencySymbol: currencyProvider.currencySymbol,
                      ),
                      const SizedBox(height: 16),
                      
                      // Quick Actions
                      Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      QuickActionCard(
                        title: 'Add Expense',
                        subtitle: 'Record a new expense',
                        icon: Icons.add_circle_outline,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ExpenseListScreen(),
                            ),
                          );
                        },
                        color: const Color(0xFFEF4444),
                      ),
                      const SizedBox(height: 8),
                      QuickActionCard(
                        title: 'View Analytics',
                        subtitle: 'Detailed spending analysis',
                        icon: Icons.analytics_outlined,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ExpenseAnalyticsScreen(),
                            ),
                          );
                        },
                        color: const Color(0xFF3B82F6),
                      ),
                      const SizedBox(height: 16),
                      
                      // Recent Transactions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Transactions',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ExpenseListScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'View All',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...transactionProvider.transactions
                          .take(3)
                          .map((transaction) => Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  leading: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: transaction.type.toString().contains('income')
                                          ? const Color(0xFF22C55E).withValues(alpha: 0.1)
                                          : const Color(0xFFEF4444).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      transaction.type.toString().contains('income')
                                          ? Icons.arrow_upward
                                          : Icons.arrow_downward,
                                      color: transaction.type.toString().contains('income')
                                          ? const Color(0xFF22C55E)
                                          : const Color(0xFFEF4444),
                                      size: 18,
                                    ),
                                  ),
                                  title: Text(
                                    transaction.description,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).colorScheme.onSurface,
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                      fontSize: 12,
                                    ),
                                  ),
                                  trailing: Text(
                                    currencyProvider.formatAmount(transaction.amount),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: transaction.type.toString().contains('income')
                                          ? const Color(0xFF22C55E)
                                          : const Color(0xFFEF4444),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              )),
                    ],
                  ),
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExpenseListScreen(),
                ),
              );
            },
            child: const Icon(Icons.receipt_long),
          ),
        );
      },
    );
  }
}
