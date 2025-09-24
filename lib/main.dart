// File location: lib/main.dart
// Purpose: Main entry point for the Kora Expense Tracker app
// Author: Pown Kumar - Founder of Korelium
// Date: September 18, 2025

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core imports
import 'core/theme/app_theme.dart';
import 'core/navigation/navigation_controller.dart';
import 'core/navigation/back_button_handler.dart';

// Data layer imports
import 'data/providers/currency_provider.dart';
import 'data/providers/transaction_provider_hive.dart';
import 'data/providers/theme_provider.dart';
import 'data/providers/credit_card_provider.dart';
import 'data/providers/bill_provider.dart';
import 'data/providers/loan_provider.dart';
import 'data/services/hive_database_helper.dart';

// Presentation layer imports
import 'presentation/screens/intro_screen.dart';
import 'presentation/screens/home/home_screen.dart';

/// Main application entry point
void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive database
  await HiveDatabaseHelper().initialize();
  
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
        
        // Transaction, account, and category management (Hive-based)
        ChangeNotifierProvider(create: (_) => TransactionProviderHive()),
        
        // Credit card management
        ChangeNotifierProvider(create: (_) => CreditCardProvider()),
        
        // Bill management
        ChangeNotifierProvider(create: (_) => BillProvider()),
        
        // Loan management
        ChangeNotifierProvider(create: (_) => LoanProvider()),
        
        // Theme management (light/dark mode)
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        
        // Navigation management (smart back button and navigation state)
        ChangeNotifierProvider(create: (_) => NavigationController()),
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
            home: const BackButtonHandlerWidget(
              child: AppInitializer(),
            ), // App starts with proper initialization
            
            // ===== LOCALIZATION =====
            // TODO: Add localization support for multiple languages - Planned for Phase 4 (Deep Refactoring)
            // locale: const Locale('en', 'US'),
            // supportedLocales: const [Locale('en', 'US')],
          );
        },
      ),
    );
  }
}

/// App initialization widget that determines whether to show intro or home screen
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isLoading = true;
  bool _showIntro = true;

  @override
  void initState() {
    super.initState();
    _checkIntroStatus();
  }

  /// Check if user has completed the intro screen
  Future<void> _checkIntroStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bool hasSeenIntro = prefs.getBool('has_seen_intro') ?? false;
      
      setState(() {
        _showIntro = !hasSeenIntro;
        _isLoading = false;
      });
    } catch (e) {
      // On error, show intro screen
      setState(() {
        _showIntro = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return _showIntro ? const IntroScreen() : const HomeScreen();
  }
}