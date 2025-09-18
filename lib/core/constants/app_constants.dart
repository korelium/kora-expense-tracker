// File location: lib/core/constants/app_constants.dart
// Purpose: Application-wide constants and configuration values
// Author: Pown Kumar - Founder of Korelium
// Date: September 18, 2025

/// Application-wide constants and configuration values
class AppConstants {
  // ===== APP INFO =====
  static const String appName = 'Kora Expense Tracker';
  static const String appVersion = '1.0.0';
  static const String companyName = 'Korelium';
  static const String developerName = 'Pown Kumar';
  
  // ===== STORAGE KEYS =====
  // SharedPreferences keys for data persistence
  static const String keyTransactions = 'transactions';
  static const String keyAccounts = 'accounts';
  static const String keyCategories = 'categories';
  static const String keyExpenses = 'expenses';
  static const String keyCurrency = 'currency';
  static const String keyTheme = 'theme';
  static const String keyFirstLaunch = 'first_launch';
  
  // ===== UI CONSTANTS =====
  // Layout and spacing constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;
  static const double buttonHeight = 48.0;
  
  // ===== ANIMATION DURATIONS =====
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // ===== CURRENCY SETTINGS =====
  static const String defaultCurrency = 'INR';
  static const String defaultCurrencySymbol = '₹';
  static const List<String> supportedCurrencies = [
    'INR', 'USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD'
  ];
  
  // ===== FINANCIAL CONSTANTS =====
  static const double defaultAccountBalance = 0.0;
  static const int maxTransactionDescriptionLength = 100;
  static const int maxAccountNameLength = 50;
  static const int maxCategoryNameLength = 30;
  
  // ===== CHART SETTINGS =====
  static const int maxChartDataPoints = 30;
  static const double chartAnimationDuration = 1500.0;
  static const double chartStrokeWidth = 3.0;
  
  // ===== VALIDATION CONSTANTS =====
  static const double minTransactionAmount = 0.01;
  static const double maxTransactionAmount = 999999.99;
  
  // ===== NETWORK SETTINGS =====
  static const Duration networkTimeout = Duration(seconds: 30);
  static const int maxRetryAttempts = 3;
  
  // ===== DEBUG SETTINGS =====
  static const bool enableDebugLogs = true;
  static const bool enablePerformanceLogs = false;
}

/// Color constants for easy access throughout the app
class AppColors {
  // ===== BRAND COLORS =====
  static const int primaryBlue = 0xFF6366F1; // Indigo-500
  static const int primaryBlueDark = 0xFF4F46E5; // Indigo-600
  static const int accentBlue = 0xFF8B5CF6; // Purple-500
  static const int infoCyan = 0xFF06B6D4; // Cyan-500
  
  // ===== STATUS COLORS =====
  static const int successGreen = 0xFF10B981; // Emerald-500 - Income
  static const int warningOrange = 0xFFF59E0B; // Amber-500 - Warning
  static const int errorRed = 0xFFEF4444; // Red-500 - Expense
  static const int pinkAccent = 0xFFEC4899; // Pink-500 - Special
  
  // ===== LIGHT THEME =====
  static const int lightBackground = 0xFFFAFBFC;
  static const int lightSurface = 0xFFFFFFFF;
  static const int lightText = 0xFF1A202C;
  static const int lightTextSecondary = 0xFF4A5568;
  static const int lightBorder = 0xFFE2E8F0;
  
  // ===== DARK THEME =====
  static const int darkBackground = 0xFF0F172A;
  static const int darkSurface = 0xFF1E293B;
  static const int darkCard = 0xFF334155;
  static const int darkText = 0xFFF1F5F9;
  static const int darkTextSecondary = 0xFF94A3B8;
}

/// Icon constants for consistent icon usage
class AppIcons {
  // ===== NAVIGATION ICONS =====
  static const String home = 'home';
  static const String transactions = 'receipt_long';
  static const String accounts = 'account_balance_wallet';
  static const String analytics = 'analytics';
  static const String more = 'more_horiz';
  
  // ===== TRANSACTION ICONS =====
  static const String income = 'trending_up';
  static const String expense = 'trending_down';
  static const String transfer = 'swap_horiz';
  static const String add = 'add';
  static const String edit = 'edit';
  static const String delete = 'delete';
  
  // ===== ACCOUNT ICONS =====
  static const String bank = 'account_balance';
  static const String cash = 'payments';
  static const String creditCard = 'credit_card';
  static const String investment = 'trending_up';
  static const String liability = 'account_balance_wallet';
  
  // ===== CATEGORY ICONS =====
  static const String food = 'restaurant';
  static const String transport = 'directions_car';
  static const String shopping = 'shopping_bag';
  static const String entertainment = 'movie';
  static const String health = 'local_hospital';
  static const String education = 'school';
  static const String utilities = 'build';
  static const String other = 'category';
}
