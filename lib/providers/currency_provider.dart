import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyProvider with ChangeNotifier {
  String _selectedCurrency = 'INR';
  String _currencySymbol = '₹';
  
  String get selectedCurrency => _selectedCurrency;
  String get currencySymbol => _currencySymbol;

  static const Map<String, String> _currencyMap = {
    'INR': '₹',
    'USD': '\$',
    'EUR': '€',
  };

  CurrencyProvider() {
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedCurrency = prefs.getString('selected_currency') ?? 'INR';
    _currencySymbol = _currencyMap[_selectedCurrency] ?? '₹';
    notifyListeners();
  }

  Future<void> setCurrency(String currency) async {
    if (_currencyMap.containsKey(currency)) {
      _selectedCurrency = currency;
      _currencySymbol = _currencyMap[currency]!;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_currency', currency);
      notifyListeners();
    }
  }

  String formatAmount(double amount) {
    // Handle dollar symbol formatting carefully
    final formattedAmount = amount.toStringAsFixed(2);
    return '$_currencySymbol$formattedAmount';
  }

  List<String> get availableCurrencies => _currencyMap.keys.toList();
}
