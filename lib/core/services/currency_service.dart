class CurrencyService {
  static String _currentCurrency = 'INR';
  static String _currencySymbol = '₹';
  static double _exchangeRate = 1.0;
  
  // Currency symbols mapping
  static const Map<String, String> _currencySymbols = {
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'INR': '₹',
    'JPY': '¥',
    'CAD': 'C\$',
    'AUD': 'A\$',
    'CHF': 'CHF',
    'CNY': '¥',
    'KRW': '₩',
    'SGD': 'S\$',
    'HKD': 'HK\$',
    'NZD': 'NZ\$',
    'MXN': 'Mex\$',
    'BRL': 'R\$',
    'RUB': '₽',
    'ZAR': 'R',
    'TRY': '₺',
    'AED': 'د.إ',
    'SAR': '﷼',
    'THB': '฿',
    'MYR': 'RM',
    'IDR': 'Rp',
    'PHP': '₱',
    'VND': '₫',
    'BGN': 'лв',
    'CZK': 'Kč',
    'DKK': 'kr',
    'HUF': 'Ft',
    'PLN': 'zł',
    'RON': 'lei',
    'SEK': 'kr',
    'NOK': 'kr',
    'ISK': 'kr',
    'HRK': 'kn',
    'RSD': 'дин',
    'UAH': '₴',
    'BYN': 'Br',
    'KZT': '₸',
    'UZS': 'лв',
    'KGS': 'лв',
    'TJS': 'SM',
    'TMT': 'T',
    'AZN': '₼',
    'GEL': '₾',
    'AMD': '֏',
    'BAM': 'КМ',
    'MKD': 'ден',
    'ALL': 'L',
    'MDL': 'L',
  };
  
  static String get currentCurrency => _currentCurrency;
  static String get currencySymbol => _currencySymbol;
  static double get exchangeRate => _exchangeRate;
  
  /// Format amount with current currency symbol
  static String formatAmount(double amount) {
    return '$_currencySymbol${amount.toStringAsFixed(2)}';
  }
  
  /// Format amount with specific currency symbol
  static String formatAmountWithCurrency(double amount, String currencyCode) {
    final symbol = _currencySymbols[currencyCode] ?? currencyCode;
    return '$symbol${amount.toStringAsFixed(2)}';
  }
  
  /// Set current currency
  static void setCurrency(String currencyCode) {
    _currentCurrency = currencyCode;
    _currencySymbol = _currencySymbols[currencyCode] ?? currencyCode;
  }
  
  /// Set exchange rate for currency conversion
  static void setExchangeRate(double rate) {
    _exchangeRate = rate;
  }
  
  /// Convert amount from one currency to another
  static double convertAmount(double amount, String fromCurrency, String toCurrency) {
    if (fromCurrency == toCurrency) return amount;
    // This would typically use a real exchange rate API
    return amount * _exchangeRate;
  }
  
  /// Get all supported currencies
  static List<String> getSupportedCurrencies() {
    return _currencySymbols.keys.toList();
  }
  
  /// Get currency symbol for a specific currency code
  static String getCurrencySymbol(String currencyCode) {
    return _currencySymbols[currencyCode] ?? currencyCode;
  }
}
