import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'providers/currency_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/theme_provider.dart';
import 'bloc/expense_bloc.dart';
import 'utils/theme_config.dart';
import 'screens/intro_screen.dart';

void main() {
  runApp(const KoraApp());
}

class KoraApp extends StatelessWidget {
  const KoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CurrencyProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        BlocProvider(create: (_) => ExpenseBloc()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Kora Expense Tracker',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const IntroScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
