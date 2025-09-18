// File location: lib/core/navigation/navigation_controller.dart
// Purpose: Smart navigation controller for intelligent back button and navigation management
// Author: Pown Kumar - Founder of Korelium
// Date: September 18, 2025

import 'package:flutter/material.dart';

/// Navigation controller for managing app-wide navigation state and smart back button behavior
class NavigationController extends ChangeNotifier {
  static final NavigationController _instance = NavigationController._internal();
  factory NavigationController() => _instance;
  NavigationController._internal();

  // Navigation state
  int _currentBottomNavIndex = 0;
  int _currentHomeTabIndex = 0;
  final List<String> _navigationStack = [];
  
  // Getters
  int get currentBottomNavIndex => _currentBottomNavIndex;
  int get currentHomeTabIndex => _currentHomeTabIndex;
  List<String> get navigationStack => List.unmodifiable(_navigationStack);
  
  /// Check if we can go back to home overview
  bool get canGoToHomeOverview => _currentBottomNavIndex != 0 || _currentHomeTabIndex != 0;
  
  /// Get the current navigation context
  NavigationContext get currentContext {
    if (_currentBottomNavIndex == 0) {
      // We're in home screen
      switch (_currentHomeTabIndex) {
        case 0:
          return NavigationContext.homeOverview;
        case 1:
          return NavigationContext.homeTransactions;
        case 2:
          return NavigationContext.homeAnalytics;
        default:
          return NavigationContext.homeOverview;
      }
    } else {
      // We're in other screens
      switch (_currentBottomNavIndex) {
        case 1:
          return NavigationContext.accounts;
        case 2:
          return NavigationContext.analytics;
        case 3:
          return NavigationContext.more;
        default:
          return NavigationContext.homeOverview;
      }
    }
  }

  /// Update bottom navigation index
  void updateBottomNavIndex(int index) {
    _currentBottomNavIndex = index;
    _addToStack('bottom_nav_$index');
    notifyListeners();
  }

  /// Update home tab index
  void updateHomeTabIndex(int index) {
    _currentHomeTabIndex = index;
    _addToStack('home_tab_$index');
    notifyListeners();
  }

  /// Navigate to home overview (smart back button behavior)
  void navigateToHomeOverview() {
    _currentBottomNavIndex = 0;
    _currentHomeTabIndex = 0;
    _addToStack('home_overview');
    notifyListeners();
  }

  /// Navigate to specific home tab
  void navigateToHomeTab(int tabIndex) {
    _currentBottomNavIndex = 0;
    _currentHomeTabIndex = tabIndex;
    _addToStack('home_tab_$tabIndex');
    notifyListeners();
  }

  /// Navigate to bottom nav screen
  void navigateToBottomNav(int index) {
    _currentBottomNavIndex = index;
    _currentHomeTabIndex = 0; // Reset home tab when switching bottom nav
    _addToStack('bottom_nav_$index');
    notifyListeners();
  }

  /// Add navigation step to stack
  void _addToStack(String step) {
    _navigationStack.add(step);
    // Keep only last 10 navigation steps
    if (_navigationStack.length > 10) {
      _navigationStack.removeAt(0);
    }
  }

  /// Clear navigation stack
  void clearStack() {
    _navigationStack.clear();
    notifyListeners();
  }

  /// Get smart back button text based on current context
  String getSmartBackButtonText() {
    final context = currentContext;
    switch (context) {
      case NavigationContext.homeTransactions:
        return 'Back to Overview';
      case NavigationContext.homeAnalytics:
        return 'Back to Overview';
      case NavigationContext.accounts:
        return 'Back to Home';
      case NavigationContext.analytics:
        return 'Back to Home';
      case NavigationContext.more:
        return 'Back to Home';
      default:
        return 'Back';
    }
  }

  /// Get smart back button icon based on current context
  IconData getSmartBackButtonIcon() {
    final context = currentContext;
    switch (context) {
      case NavigationContext.homeTransactions:
      case NavigationContext.homeAnalytics:
        return Icons.dashboard;
      case NavigationContext.accounts:
      case NavigationContext.analytics:
      case NavigationContext.more:
        return Icons.home;
      default:
        return Icons.arrow_back;
    }
  }
}

/// Navigation context enum
enum NavigationContext {
  homeOverview,
  homeTransactions,
  homeAnalytics,
  accounts,
  analytics,
  more,
}

/// Navigation utility functions
class NavigationUtils {
  /// Navigate to home overview with animation
  static void goToHomeOverview(BuildContext context, {bool animated = true}) {
    final navController = NavigationController();
    navController.navigateToHomeOverview();
    
    if (animated) {
      // Add a subtle animation feedback
      _showNavigationFeedback(context, 'Returning to Overview');
    }
  }

  /// Navigate to specific home tab with animation
  static void goToHomeTab(BuildContext context, int tabIndex, {bool animated = true}) {
    final navController = NavigationController();
    navController.navigateToHomeTab(tabIndex);
    
    if (animated) {
      final tabNames = ['Overview', 'Transactions', 'Analytics'];
      _showNavigationFeedback(context, 'Switching to ${tabNames[tabIndex]}');
    }
  }

  /// Navigate to bottom nav screen with animation
  static void goToBottomNav(BuildContext context, int index, {bool animated = true}) {
    final navController = NavigationController();
    navController.navigateToBottomNav(index);
    
    if (animated) {
      final screenNames = ['Home', 'Accounts', 'Analytics', 'More'];
      _showNavigationFeedback(context, 'Switching to ${screenNames[index]}');
    }
  }

  /// Show navigation feedback
  static void _showNavigationFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.navigation, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  /// Check if we should show smart back button
  static bool shouldShowSmartBackButton(BuildContext context) {
    final navController = NavigationController();
    return navController.canGoToHomeOverview;
  }

  /// Get smart back button configuration
  static SmartBackButtonConfig getSmartBackButtonConfig(BuildContext context) {
    final navController = NavigationController();
    return SmartBackButtonConfig(
      text: navController.getSmartBackButtonText(),
      icon: navController.getSmartBackButtonIcon(),
      onPressed: () => goToHomeOverview(context),
    );
  }
}

/// Smart back button configuration
class SmartBackButtonConfig {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  SmartBackButtonConfig({
    required this.text,
    required this.icon,
    required this.onPressed,
  });
}
