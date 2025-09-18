// File location: lib/presentation/screens/home/home_screen.dart
// Purpose: Main home screen with dashboard, tabs, and financial overview
// Author: Pown Kumar - Founder of Korelium
// Date: September 18, 2025

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Data layer imports
import '../../../data/providers/currency_provider.dart';
import '../../../data/providers/transaction_provider.dart';
import '../../../data/models/transaction.dart';
import '../../../data/models/account.dart';
import '../../../data/models/category.dart' as app_category;

// Widget imports
import '../../widgets/common/currency_selector.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/theme_toggle.dart';
import '../../widgets/common/dashboard_widgets.dart';
import '../../widgets/charts/mini_charts.dart';

// Utility imports
import '../../../core/utils/financial_calculator.dart';

// Screen imports
import '../accounts/accounts_screen.dart';
import '../analytics/analytics_screen.dart';
import '../more/more_screen.dart';
import '../transactions/expense_list_screen.dart';
import '../transactions/add_expense_screen.dart';

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

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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


  @override
  Widget build(BuildContext context) {
    return Consumer2<CurrencyProvider, TransactionProvider>(
      builder: (context, currencyProvider, transactionProvider, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            title: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/korelium-logo.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet,
                            color: Colors.white,
                            size: 20,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Kora Expense Tracker'),
              ],
            ),
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
              : Column(
                  children: [
          // Header with Greeting & Balance
          Container(
            margin: const EdgeInsets.all(16),
            constraints: const BoxConstraints(minHeight: 80, maxHeight: 90),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF6366F1), // Indigo
                  Color(0xFF8B5CF6), // Purple
                  Color(0xFFEC4899), // Pink
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _getGreeting(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context).colorScheme.onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    'Total Balance',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    currencyProvider.formatAmount(transactionProvider.totalBalance),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context).colorScheme.onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Icon(
                                Icons.account_balance_wallet,
                                color: Theme.of(context).colorScheme.onPrimary,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
          // Tabs within the home screen - Enhanced
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.15),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Transactions'),
                Tab(text: 'Analytics'),
              ],
            ),
          ),
                    
                    // Tab content
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Overview Tab
                          _buildOverviewTab(context, currencyProvider, transactionProvider),
                          // Transactions Tab
                          const ExpenseListScreen(),
                          // Analytics Tab
                          const AnalyticsScreen(),
                        ],
                      ),
                    ),
                  ],
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _showAddTransactionDialog(context);
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

        Widget _buildOverviewTab(BuildContext context, CurrencyProvider currencyProvider, TransactionProvider transactionProvider) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
                 // 3-Card Layout: Income, Expenses, Assets
                 Row(
                   children: [
                     // Income Card - More Compact
                     Expanded(
                       child: Container(
                         constraints: const BoxConstraints(minHeight: 60, maxHeight: 65),
                         decoration: BoxDecoration(
                           gradient: const LinearGradient(
                             colors: [Color(0xFF10B981), Color(0xFF059669)],
                             begin: Alignment.topLeft,
                             end: Alignment.bottomRight,
                           ),
                           borderRadius: BorderRadius.circular(12),
                           boxShadow: [
                             BoxShadow(
                               color: const Color(0xFF10B981).withValues(alpha: 0.25),
                               blurRadius: 6,
                               offset: const Offset(0, 3),
                             ),
                           ],
                         ),
                         child: Padding(
                           padding: const EdgeInsets.all(8),
                           child: Row(
                             children: [
                               Container(
                                 padding: const EdgeInsets.all(6),
                                 decoration: BoxDecoration(
                                   color: Colors.white.withValues(alpha: 0.2),
                                   borderRadius: BorderRadius.circular(8),
                                 ),
                                 child: const Icon(Icons.trending_up, color: Colors.white, size: 16),
                               ),
                               const SizedBox(width: 8),
                               Expanded(
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   mainAxisAlignment: MainAxisAlignment.center,
                                   children: [
                                     const Text(
                                       'Income',
                                       style: TextStyle(
                                         color: Colors.white,
                                         fontSize: 10,
                                         fontWeight: FontWeight.w500,
                                       ),
                                     ),
                                     Text(
                                       currencyProvider.formatAmount(transactionProvider.totalIncome),
                                       style: const TextStyle(
                                         color: Colors.white,
                                         fontSize: 12,
                                         fontWeight: FontWeight.bold,
                                       ),
                                       maxLines: 1,
                                       overflow: TextOverflow.ellipsis,
                                     ),
                                   ],
                                 ),
                               ),
                             ],
                           ),
                         ),
                       ),
                     ),
                     const SizedBox(width: 12),
                     // Expenses Card - More Compact
                     Expanded(
                       child: Container(
                         constraints: const BoxConstraints(minHeight: 60, maxHeight: 65),
                         decoration: BoxDecoration(
                           gradient: const LinearGradient(
                             colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                             begin: Alignment.topLeft,
                             end: Alignment.bottomRight,
                           ),
                           borderRadius: BorderRadius.circular(12),
                           boxShadow: [
                             BoxShadow(
                               color: const Color(0xFFEF4444).withValues(alpha: 0.25),
                               blurRadius: 6,
                               offset: const Offset(0, 3),
                             ),
                           ],
                         ),
                         child: Padding(
                           padding: const EdgeInsets.all(8),
                           child: Row(
                             children: [
                               Container(
                                 padding: const EdgeInsets.all(6),
                                 decoration: BoxDecoration(
                                   color: Colors.white.withValues(alpha: 0.2),
                                   borderRadius: BorderRadius.circular(8),
                                 ),
                                 child: const Icon(Icons.trending_down, color: Colors.white, size: 16),
                               ),
                               const SizedBox(width: 8),
                               Expanded(
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   mainAxisAlignment: MainAxisAlignment.center,
                                   children: [
                                     const Text(
                                       'Expenses',
                                       style: TextStyle(
                                         color: Colors.white,
                                         fontSize: 10,
                                         fontWeight: FontWeight.w500,
                                       ),
                                     ),
                                     Text(
                                       currencyProvider.formatAmount(transactionProvider.totalExpense),
                                       style: const TextStyle(
                                         color: Colors.white,
                                         fontSize: 12,
                                         fontWeight: FontWeight.bold,
                                       ),
                                       maxLines: 1,
                                       overflow: TextOverflow.ellipsis,
                                     ),
                                   ],
                                 ),
                               ),
                             ],
                           ),
                         ),
                       ),
                     ),
                     const SizedBox(width: 12),
                     // Assets Card - More Compact
                     Expanded(
                       child: Container(
                         constraints: const BoxConstraints(minHeight: 60, maxHeight: 65),
                         decoration: BoxDecoration(
                           gradient: const LinearGradient(
                             colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                             begin: Alignment.topLeft,
                             end: Alignment.bottomRight,
                           ),
                           borderRadius: BorderRadius.circular(12),
                           boxShadow: [
                             BoxShadow(
                               color: const Color(0xFF6366F1).withValues(alpha: 0.25),
                               blurRadius: 6,
                               offset: const Offset(0, 3),
                             ),
                           ],
                         ),
                         child: Padding(
                           padding: const EdgeInsets.all(8),
                           child: Row(
                             children: [
                               Container(
                                 padding: const EdgeInsets.all(6),
                                 decoration: BoxDecoration(
                                   color: Colors.white.withValues(alpha: 0.2),
                                   borderRadius: BorderRadius.circular(8),
                                 ),
                                 child: const Icon(Icons.account_balance, color: Colors.white, size: 16),
                               ),
                               const SizedBox(width: 8),
                               Expanded(
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   mainAxisAlignment: MainAxisAlignment.center,
                                   children: [
                                     const Text(
                                       'Assets',
                                       style: TextStyle(
                                         color: Colors.white,
                                         fontSize: 10,
                                         fontWeight: FontWeight.w500,
                                       ),
                                     ),
                                     Text(
                                       currencyProvider.formatAmount(transactionProvider.totalBalance),
                                       style: const TextStyle(
                                         color: Colors.white,
                                         fontSize: 12,
                                         fontWeight: FontWeight.bold,
                                       ),
                                       maxLines: 1,
                                       overflow: TextOverflow.ellipsis,
                                     ),
                                   ],
                                 ),
                               ),
                             ],
                           ),
                         ),
                       ),
                     ),
                   ],
                 ),
          const SizedBox(height: 20),
          
          // Financial Insight
          InsightCard(
            insight: FinancialCalculator.getFinancialInsight(transactionProvider.transactions),
            icon: Icons.lightbulb_outline,
            color: const Color(0xFF3B82F6),
          ),
        ],
      ),
    );
  }


  void _showAddTransactionDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddExpenseScreen(),
      ),
    );
  }


}
