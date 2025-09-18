// File location: lib/data/providers/currency_provider.dart
// Purpose: Currency management and formatting for the expense tracker
// Author: Pown Kumar - Founder of Korelium
// Date: September 18, 2025

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing currency settings and formatting
/// Handles currency selection, symbols, and amount formatting
class CurrencyProvider with ChangeNotifier {
  // ===== PRIVATE FIELDS =====
  String _selectedCurrency = 'INR';
  String _currencySymbol = '₹';
  
  // ===== CURRENCY MAPPING =====
  /// Map of currency codes to their symbols
  static const Map<String, String> _currencyMap = {
    'INR': '₹', // Indian Rupee
    'USD': '\$', // US Dollar
    'EUR': '€', // Euro
    'GBP': '£', // British Pound
    'JPY': '¥', // Japanese Yen
    'CAD': 'C\$', // Canadian Dollar
    'AUD': 'A\$', // Australian Dollar
  };

  // ===== GETTERS =====
  /// Currently selected currency code
  String get selectedCurrency => _selectedCurrency;
  
  /// Symbol for the currently selected currency
  String get currencySymbol => _currencySymbol;
  
  /// List of available currency codes
  List<String> get availableCurrencies => _currencyMap.keys.toList();

  // ===== CONSTRUCTOR =====
  CurrencyProvider() {
    _loadCurrency();
  }

  // ===== CURRENCY MANAGEMENT =====
  /// Load saved currency from SharedPreferences
  Future<void> _loadCurrency() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCurrency = prefs.getString('selected_currency') ?? 'INR';
      await setCurrency(savedCurrency);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading currency: $e');
      }
      // Keep default currency on error
    }
  }

  /// Set the currency and save to SharedPreferences
  /// Validates currency code before setting
  Future<void> setCurrency(String currency) async {
    if (_currencyMap.containsKey(currency)) {
      _selectedCurrency = currency;
      _currencySymbol = _currencyMap[currency]!;
      
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('selected_currency', currency);
      } catch (e) {
        if (kDebugMode) {
          print('Error saving currency: $e');
        }
      }
      
      notifyListeners();
    } else {
      if (kDebugMode) {
        print('Invalid currency code: $currency');
      }
    }
  }

  // ===== FORMATTING METHODS =====
  /// Format amount with currency symbol
  /// Handles special formatting for different currencies
  String formatAmount(double amount) {
    // Format with 2 decimal places
    final formattedAmount = amount.toStringAsFixed(2);
    
    // Special handling for currencies that put symbol after amount
    if (_selectedCurrency == 'JPY') {
      return '$formattedAmount$_currencySymbol'; // Japanese Yen: 1000¥
    }
    
    // Default formatting: symbol before amount
    return '$_currencySymbol$formattedAmount'; // Most currencies: $1000.00
  }

  /// Format amount without currency symbol
  /// Useful for calculations or when symbol is displayed separately
  String formatAmountOnly(double amount) {
    return amount.toStringAsFixed(2);
  }

  /// Parse amount string to double
  /// Handles various input formats
  double parseAmount(String amountString) {
    try {
      // Remove currency symbols and whitespace
      final cleanString = amountString
          .replaceAll(RegExp(r'[^\d.-]'), '') // Keep only digits, dots, and minus
          .trim();
      
      return double.parse(cleanString);
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing amount: $e');
      }
      return 0.0;
    }
  }

  // ===== UTILITY METHODS =====
  /// Get currency symbol for a specific currency code
  static String getCurrencySymbol(String currencyCode) {
    return _currencyMap[currencyCode] ?? '₹'; // Default to INR symbol
  }

  /// Check if a currency code is supported
  static bool isSupportedCurrency(String currencyCode) {
    return _currencyMap.containsKey(currencyCode);
  }

  /// Get currency name (for display purposes)
  String getCurrencyName(String currencyCode) {
    const currencyNames = {
      'INR': 'Indian Rupee',
      'USD': 'US Dollar',
      'EUR': 'Euro',
      'GBP': 'British Pound',
      'JPY': 'Japanese Yen',
      'CAD': 'Canadian Dollar',
      'AUD': 'Australian Dollar',
    };
    
    return currencyNames[currencyCode] ?? 'Unknown Currency';
  }

  /// Reset to default currency (INR)
  Future<void> resetToDefault() async {
    await setCurrency('INR');
  }
}
