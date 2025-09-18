// File location: lib/presentation/screens/analytics/analytics_screen.dart
// Purpose: Analytics screen for financial insights and data visualization
// Author: Pown Kumar - Founder of Korelium
// Date: September 18, 2025

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../data/providers/currency_provider.dart';
import '../../../data/providers/transaction_provider_hive.dart';
import '../../../data/models/category.dart' as app_category;

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<CurrencyProvider, TransactionProviderHive>(
      builder: (context, currencyProvider, transactionProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Analytics'),
            backgroundColor: Theme.of(context).colorScheme.surface,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            elevation: 0,
          ),
          body: transactionProvider.transactions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Icon(
                          Icons.analytics_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No Analytics Available',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add some transactions to see your financial insights',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : _buildAnalyticsContent(context, currencyProvider, transactionProvider),
        );
      },
    );
  }

  /// Build comprehensive analytics content
  Widget _buildAnalyticsContent(BuildContext context, CurrencyProvider currencyProvider, TransactionProviderHive transactionProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Financial Overview Cards
          _buildFinancialOverview(context, currencyProvider, transactionProvider),
          const SizedBox(height: 20),

          // Charts Section
          _buildChartsSection(context, currencyProvider, transactionProvider),
          const SizedBox(height: 20),

          // Category Analysis
          _buildCategoryAnalysis(context, currencyProvider, transactionProvider),
          const SizedBox(height: 20),

          // Monthly Trends
          _buildMonthlyTrends(context, currencyProvider, transactionProvider),
          const SizedBox(height: 20),

          // Financial Insights
          _buildFinancialInsights(context, currencyProvider, transactionProvider),
        ],
      ),
    );
  }

  /// Build financial overview cards
  Widget _buildFinancialOverview(BuildContext context, CurrencyProvider currencyProvider, TransactionProviderHive transactionProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Financial Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildOverviewCard(
                context,
                'Total Balance',
                currencyProvider.formatAmount(transactionProvider.totalBalance),
                Icons.account_balance_wallet,
                const Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOverviewCard(
                context,
                'Total Income',
                currencyProvider.formatAmount(transactionProvider.totalIncome),
                Icons.trending_up,
                const Color(0xFF10B981),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildOverviewCard(
                context,
                'Total Expenses',
                currencyProvider.formatAmount(transactionProvider.totalExpense),
                Icons.trending_down,
                const Color(0xFFEF4444),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOverviewCard(
                context,
                'Savings Rate',
                '${_calculateSavingsRate(transactionProvider)}%',
                Icons.savings,
                _getSavingsColor(transactionProvider),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build charts section
  Widget _buildChartsSection(BuildContext context, CurrencyProvider currencyProvider, TransactionProviderHive transactionProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Spending Analysis',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        // Monthly spending chart
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly Spending Trend',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildMonthlySpendingChart(context, transactionProvider),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build category analysis
  Widget _buildCategoryAnalysis(BuildContext context, CurrencyProvider currencyProvider, TransactionProviderHive transactionProvider) {
    final categoryData = _getCategorySpendingData(transactionProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category Breakdown',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 300,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Expense Distribution',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: categoryData.isEmpty
                      ? Center(
                          child: Text(
                            'No expense data available',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        )
                      : _buildPieChart(context, categoryData),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Category list
        ...categoryData.take(5).map((data) => _buildCategoryItem(context, data, currencyProvider)).toList(),
      ],
    );
  }

  /// Build monthly trends
  Widget _buildMonthlyTrends(BuildContext context, CurrencyProvider currencyProvider, TransactionProviderHive transactionProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monthly Trends',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Income vs Expenses',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildIncomeExpenseChart(context, transactionProvider),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build financial insights
  Widget _buildFinancialInsights(BuildContext context, CurrencyProvider currencyProvider, TransactionProviderHive transactionProvider) {
    final insights = _generateFinancialInsights(transactionProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Financial Insights',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        ...insights.map((insight) => _buildInsightCard(context, insight)).toList(),
      ],
    );
  }

  /// Build overview card
  Widget _buildOverviewCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Build monthly spending chart
  Widget _buildMonthlySpendingChart(BuildContext context, TransactionProviderHive transactionProvider) {
    final monthlyData = _getMonthlySpendingData(transactionProvider);
    
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                if (value.toInt() < months.length) {
                  return Text(
                    months[value.toInt()],
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: monthlyData,
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  /// Build pie chart
  Widget _buildPieChart(BuildContext context, List<CategorySpendingData> data) {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 60,
        sections: data.map((item) {
          return PieChartSectionData(
            color: item.color,
            value: item.amount,
            title: '${item.percentage.toStringAsFixed(1)}%',
            radius: 80,
            titleStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Build income vs expense chart
  Widget _buildIncomeExpenseChart(BuildContext context, TransactionProviderHive transactionProvider) {
    final data = _getIncomeExpenseData(transactionProvider);
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: data.map((e) => e.income > e.expense ? e.income : e.expense).reduce((a, b) => a > b ? a : b) * 1.2,
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                if (value.toInt() < months.length) {
                  return Text(
                    months[value.toInt()],
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: item.income,
                color: const Color(0xFF10B981),
                width: 8,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
              BarChartRodData(
                toY: item.expense,
                color: const Color(0xFFEF4444),
                width: 8,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  /// Build category item
  Widget _buildCategoryItem(BuildContext context, CategorySpendingData data, CurrencyProvider currencyProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: data.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              data.categoryName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Text(
            currencyProvider.formatAmount(data.amount),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  /// Build insight card
  Widget _buildInsightCard(BuildContext context, FinancialInsight insight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: insight.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: insight.color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(insight.icon, color: insight.color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Calculate savings rate
  int _calculateSavingsRate(TransactionProviderHive transactionProvider) {
    if (transactionProvider.totalIncome == 0) return 0;
    final savings = transactionProvider.totalIncome - transactionProvider.totalExpense;
    return ((savings / transactionProvider.totalIncome) * 100).round();
  }

  /// Get savings color based on rate
  Color _getSavingsColor(TransactionProviderHive transactionProvider) {
    final rate = _calculateSavingsRate(transactionProvider);
    if (rate >= 20) return const Color(0xFF10B981);
    if (rate >= 10) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  /// Get monthly spending data
  List<FlSpot> _getMonthlySpendingData(TransactionProviderHive transactionProvider) {
    final now = DateTime.now();
    final List<FlSpot> spots = [];
    
    for (int i = 11; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final monthExpenses = transactionProvider.transactions
          .where((t) => 
              t.type.toString().contains('expense') &&
              t.date.year == date.year &&
              t.date.month == date.month)
          .fold(0.0, (sum, t) => sum + t.amount);
      
      spots.add(FlSpot((11 - i).toDouble(), monthExpenses));
    }
    
    return spots;
  }

  /// Get category spending data
  List<CategorySpendingData> _getCategorySpendingData(TransactionProviderHive transactionProvider) {
    final Map<String, double> categoryTotals = {};
    final Map<String, String> categoryNames = {};
    final Map<String, Color> categoryColors = {};
    
    for (final transaction in transactionProvider.transactions) {
      if (transaction.type.toString().contains('expense')) {
        final category = transactionProvider.getCategory(transaction.categoryId);
        if (category != null) {
          final categoryName = category.name;
          categoryTotals[categoryName] = (categoryTotals[categoryName] ?? 0) + transaction.amount;
          categoryNames[categoryName] = categoryName;
          categoryColors[categoryName] = _getCategoryColor(category);
        }
      }
    }
    
    final total = categoryTotals.values.fold(0.0, (sum, amount) => sum + amount);
    
    return categoryTotals.entries.map((entry) {
      final percentage = total > 0 ? (entry.value / total) * 100 : 0.0;
      return CategorySpendingData(
        categoryName: entry.key,
        amount: entry.value,
        percentage: percentage,
        color: categoryColors[entry.key] ?? const Color(0xFF6B7280),
      );
    }).toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
  }

  /// Get income vs expense data
  List<IncomeExpenseData> _getIncomeExpenseData(TransactionProviderHive transactionProvider) {
    final now = DateTime.now();
    final List<IncomeExpenseData> data = [];
    
    for (int i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final monthIncome = transactionProvider.transactions
          .where((t) => 
              t.type.toString().contains('income') &&
              t.date.year == date.year &&
              t.date.month == date.month)
          .fold(0.0, (sum, t) => sum + t.amount);
      
      final monthExpense = transactionProvider.transactions
          .where((t) => 
              t.type.toString().contains('expense') &&
              t.date.year == date.year &&
              t.date.month == date.month)
          .fold(0.0, (sum, t) => sum + t.amount);
      
      data.add(IncomeExpenseData(
        month: date.month,
        income: monthIncome,
        expense: monthExpense,
      ));
    }
    
    return data;
  }

  /// Generate financial insights
  List<FinancialInsight> _generateFinancialInsights(TransactionProviderHive transactionProvider) {
    final insights = <FinancialInsight>[];
    final savingsRate = _calculateSavingsRate(transactionProvider);
    
    // Savings rate insight
    if (savingsRate >= 20) {
      insights.add(FinancialInsight(
        title: 'Excellent Savings Rate!',
        description: 'You\'re saving ${savingsRate}% of your income. Keep up the great work!',
        icon: Icons.thumb_up,
        color: const Color(0xFF10B981),
      ));
    } else if (savingsRate >= 10) {
      insights.add(FinancialInsight(
        title: 'Good Savings Rate',
        description: 'You\'re saving ${savingsRate}% of your income. Consider increasing it to 20% for better financial health.',
        icon: Icons.trending_up,
        color: const Color(0xFFF59E0B),
      ));
    } else if (savingsRate < 0) {
      insights.add(FinancialInsight(
        title: 'Spending Alert',
        description: 'You\'re spending more than you earn. Consider reviewing your expenses.',
        icon: Icons.warning,
        color: const Color(0xFFEF4444),
      ));
    }
    
    // Transaction count insight
    if (transactionProvider.transactions.length > 50) {
      insights.add(FinancialInsight(
        title: 'Active Tracker',
        description: 'You\'ve recorded ${transactionProvider.transactions.length} transactions. Great job staying organized!',
        icon: Icons.receipt_long,
        color: const Color(0xFF3B82F6),
      ));
    }
    
    return insights;
  }

  /// Get category color
  Color _getCategoryColor(app_category.Category category) {
    try {
      return Color(int.parse((category.color ?? '#6B7280').replaceAll('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF6B7280);
    }
  }
}

/// Data classes for analytics
class CategorySpendingData {
  final String categoryName;
  final double amount;
  final double percentage;
  final Color color;

  CategorySpendingData({
    required this.categoryName,
    required this.amount,
    required this.percentage,
    required this.color,
  });
}

class IncomeExpenseData {
  final int month;
  final double income;
  final double expense;

  IncomeExpenseData({
    required this.month,
    required this.income,
    required this.expense,
  });
}

class FinancialInsight {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  FinancialInsight({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
