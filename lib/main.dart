// File location: lib/main.dart
// Purpose: Main entry point for the Kora Expense Tracker app
// Author: Pown Kumar - Founder of Korelium
// Date: September 18, 2025

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Core imports
import 'core/theme/app_theme.dart';

// Data layer imports
import 'data/providers/currency_provider.dart';
import 'data/providers/transaction_provider.dart';
import 'data/providers/theme_provider.dart';

// Presentation layer imports
import 'presentation/screens/intro_screen.dart';

/// Main application entry point
void main() {
  runApp(const KoraApp());
}

/// Root application widget
/// Sets up providers and theme configuration
class KoraApp extends StatelessWidget {
  const KoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // ===== PROVIDERS SETUP =====
      // All state management providers are configured here
      providers: [
        // Currency management
        ChangeNotifierProvider(create: (_) => CurrencyProvider()),
        
        // Transaction, account, and category management
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        
        // Theme management (light/dark mode)
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      
      // ===== THEME CONSUMER =====
      // Theme provider is consumed here to rebuild app when theme changes
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            // ===== APP CONFIGURATION =====
            title: 'Kora Expense Tracker',
            debugShowCheckedModeBanner: false, // Remove debug banner
            
            // ===== THEME CONFIGURATION =====
            // Use custom theme from app_theme.dart
            theme: AppTheme.lightTheme, // Light theme configuration
            darkTheme: AppTheme.darkTheme, // Dark theme configuration
            themeMode: themeProvider.themeMode, // Current theme mode
            
            // ===== NAVIGATION =====
            home: const IntroScreen(), // App starts with intro screen
            
            // ===== LOCALIZATION =====
            // TODO: Add localization support for multiple languages
            // locale: const Locale('en', 'US'),
            // supportedLocales: const [Locale('en', 'US')],
          );
        },
      ),
    );
  }
}