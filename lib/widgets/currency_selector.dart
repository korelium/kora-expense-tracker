import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';

class CurrencySelector extends StatelessWidget {
  const CurrencySelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrencyProvider>(
      builder: (context, currencyProvider, child) {
        return AlertDialog(
          title: const Text('Select Currency'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: currencyProvider.availableCurrencies.map((currency) {
              final isSelected = currencyProvider.selectedCurrency == currency;
              return ListTile(
                leading: Text(
                  _getCurrencySymbol(currency),
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(currency),
                trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
                onTap: () {
                  currencyProvider.setCurrency(currency);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  String _getCurrencySymbol(String currency) {
    switch (currency) {
      case 'INR':
        return '₹';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      default:
        return currency;
    }
  }
}
