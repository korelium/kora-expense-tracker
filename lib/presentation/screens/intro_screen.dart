// File location: lib/presentation/screens/intro_screen.dart
// Purpose: Introduction/onboarding screen for new users
// Author: Pown Kumar - Founder of Korelium
// Date: September 18, 2025

import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'home/home_screen.dart';

/// Introduction screen shown to new users
/// Provides app overview and feature highlights
class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntroductionScreen(
        // ===== ONBOARDING PAGES =====
        pages: [
          _buildWelcomePage(context),
          _buildExpenseTrackingPage(context),
          _buildAnalyticsPage(context),
          _buildGetStartedPage(context),
        ],
        
        // ===== INTRODUCTION SCREEN CONFIGURATION =====
        onDone: () => _navigateToHome(context),
        onSkip: () => _navigateToHome(context),
        
        // ===== STYLING CONFIGURATION =====
        globalBackgroundColor: Theme.of(context).colorScheme.surface,
        skipStyle: TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.primary,
        ),
        doneStyle: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        
        // ===== NAVIGATION CONFIGURATION =====
        showSkipButton: true,
        skip: const Text('Skip'),
        next: const Text('Next'),
        done: const Text('Get Started'),
        
        // ===== DOT INDICATOR CONFIGURATION =====
        dotsDecorator: DotsDecorator(
          size: const Size(10.0, 10.0),
          color: Theme.of(context).colorScheme.outline,
          activeSize: const Size(22.0, 10.0),
          activeColor: Theme.of(context).colorScheme.primary,
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
      ),
    );
  }

  // ===== PAGE BUILDERS =====
  /// Welcome page - App introduction
  PageViewModel _buildWelcomePage(BuildContext context) {
    return PageViewModel(
      title: "Welcome to Kora",
      body: "Your personal finance companion for tracking expenses and managing money smartly.",
      image: _buildPageImage(
        context,
        Icons.account_balance_wallet,
        "Welcome to Kora Expense Tracker",
      ),
      decoration: _getPageDecoration(context),
    );
  }

  /// Expense tracking page - Core feature
  PageViewModel _buildExpenseTrackingPage(BuildContext context) {
    return PageViewModel(
      title: "Track Your Expenses",
      body: "Easily record your income and expenses with categories and accounts. Stay on top of your finances.",
      image: _buildPageImage(
        context,
        Icons.receipt_long,
        "Track Income & Expenses",
      ),
      decoration: _getPageDecoration(context),
    );
  }

  /// Analytics page - Insights feature
  PageViewModel _buildAnalyticsPage(BuildContext context) {
    return PageViewModel(
      title: "Smart Analytics",
      body: "Get insights into your spending patterns with beautiful charts and financial health metrics.",
      image: _buildPageImage(
        context,
        Icons.analytics,
        "Financial Analytics",
      ),
      decoration: _getPageDecoration(context),
    );
  }

  /// Get started page - Final page
  PageViewModel _buildGetStartedPage(BuildContext context) {
    return PageViewModel(
      title: "Ready to Start?",
      body: "Join thousands of users who are taking control of their finances with Kora Expense Tracker.",
      image: _buildPageImage(
        context,
        Icons.rocket_launch,
        "Start Your Journey",
      ),
      decoration: _getPageDecoration(context),
    );
  }

  // ===== HELPER METHODS =====
  /// Build circular image container for each page
  Widget _buildPageImage(BuildContext context, IconData icon, String semanticLabel) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 100,
        color: Theme.of(context).colorScheme.primary,
        semanticLabel: semanticLabel,
      ),
    );
  }

  /// Get consistent page decoration for all pages
  PageDecoration _getPageDecoration(BuildContext context) {
    return PageDecoration(
      titleTextStyle: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      bodyTextStyle: TextStyle(
        fontSize: 16,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        height: 1.5,
      ),
      imagePadding: const EdgeInsets.only(top: 40, bottom: 20),
      pageColor: Theme.of(context).colorScheme.surface,
      imageFlex: 2,
      bodyFlex: 1,
    );
  }

  /// Navigate to home screen after onboarding
  void _navigateToHome(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }
}
