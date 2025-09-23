import 'package:intl/intl.dart';
import '../../data/models/transaction.dart';

class FinancialCalculator {
  static double calculateSavingsRate(List<Transaction> transactions) {
    final totalIncome = transactions
        .where((t) => t.type.toString().contains('income'))
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final totalExpenses = transactions
        .where((t) => t.type.toString().contains('expense'))
        .fold(0.0, (sum, t) => sum + t.amount);
    
    if (totalIncome == 0) return 0.0;
    return ((totalIncome - totalExpenses) / totalIncome) * 100;
  }

  static double calculateMonthlyChange(List<Transaction> transactions) {
    final now = DateTime.now();
    final thisMonth = transactions.where((t) => 
        t.date.year == now.year && t.date.month == now.month);
    
    final lastMonth = transactions.where((t) => 
        t.date.year == now.year && t.date.month == now.month - 1);
    
    final thisMonthTotal = thisMonth.fold(0.0, (sum, t) => sum + t.amount);
    final lastMonthTotal = lastMonth.fold(0.0, (sum, t) => sum + t.amount);
    
    if (lastMonthTotal == 0) return 0.0;
    return ((thisMonthTotal - lastMonthTotal) / lastMonthTotal) * 100;
  }

  static int calculateFinancialHealthScore(List<Transaction> transactions) {
    final savingsRate = calculateSavingsRate(transactions);
    final monthlyChange = calculateMonthlyChange(transactions);
    
    int score = 50; // Base score
    
    // Savings rate scoring
    if (savingsRate >= 20) score += 30;
    else if (savingsRate >= 10) score += 20;
    else if (savingsRate >= 5) score += 10;
    else if (savingsRate < 0) score -= 20;
    
    // Monthly change scoring
    if (monthlyChange > 0) score += 10;
    else if (monthlyChange < -20) score -= 15;
    
    // Transaction frequency (more transactions = better tracking)
    if (transactions.length >= 20) score += 10;
    else if (transactions.length >= 10) score += 5;
    
    return score.clamp(0, 100);
  }

  static Map<String, double> getTopCategories(List<Transaction> transactions) {
    final Map<String, double> categoryTotals = {};
    
    for (final transaction in transactions) {
      if (transaction.type.toString().contains('expense')) {
        // For now, use categoryId as the category name
        // In a real app, you'd look up the category name from categoryId
        final category = 'Category ${transaction.categoryId}';
        categoryTotals[category] = (categoryTotals[category] ?? 0) + transaction.amount;
      }
    }
    
    // Sort by amount and return top 5
    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Map.fromEntries(sortedEntries.take(5));
  }

  static String getFinancialInsight(List<Transaction> transactions, {String currencySymbol = '\$'}) {
    final savingsRate = calculateSavingsRate(transactions);
    final monthlyChange = calculateMonthlyChange(transactions);
    final topCategories = getTopCategories(transactions);
    
    if (savingsRate < 0) {
      return "⚠️ You're spending more than you earn. Consider reducing expenses.";
    } else if (savingsRate >= 20) {
      return "🎉 Excellent! You're saving ${savingsRate.toStringAsFixed(1)}% of your income.";
    } else if (savingsRate >= 10) {
      return "👍 Good job! You're saving ${savingsRate.toStringAsFixed(1)}% of your income.";
    } else if (monthlyChange < -20) {
      return "📈 Great! Your spending decreased by ${monthlyChange.abs().toStringAsFixed(1)}% this month.";
    } else if (topCategories.isNotEmpty) {
      final topCategory = topCategories.entries.first;
      return "💡 Your biggest expense is ${topCategory.key} (${NumberFormat.currency(symbol: currencySymbol).format(topCategory.value)}).";
    } else {
      return "📊 Keep tracking your expenses to get personalized insights!";
    }
  }

  static double getWeeklySpending(List<Transaction> transactions) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    return transactions
        .where((t) => 
            t.type.toString().contains('expense') &&
            t.date.isAfter(weekStart) &&
            t.date.isBefore(weekEnd))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  static double getAverageDailySpending(List<Transaction> transactions) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    
    final monthlyExpenses = transactions
        .where((t) => 
            t.type.toString().contains('expense') &&
            t.date.isAfter(monthStart))
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final daysInMonth = now.day;
    return daysInMonth > 0 ? monthlyExpenses / daysInMonth : 0.0;
  }
}
