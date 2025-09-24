// File location: lib/core/navigation/back_button_handler.dart
// Purpose: Handle system back button with smart navigation and double-tap to exit
// Author: Pown Kumar - Founder of Korelium
// Date: September 18, 2025

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'navigation_controller.dart';

/// Handles system back button with smart navigation behavior
/// Single press: Navigate to home overview
/// Double press: Exit app with confirmation
class BackButtonHandler {
  static DateTime? _lastBackPressed;
  static const Duration _doublePressInterval = Duration(seconds: 2);

  /// Handle system back button press
  static Future<bool> handleBackPress(BuildContext context) async {
    final navigationController = NavigationController();
    
    // Debug logging
    print('Back button pressed - Current context: ${navigationController.currentContext}');
    print('Bottom nav index: ${navigationController.currentBottomNavIndex}');
    print('Home tab index: ${navigationController.currentHomeTabIndex}');
    
    // If we're in home tabs (Transactions or Analytics), go to Overview tab
    if (navigationController.currentContext == NavigationContext.homeTransactions ||
        navigationController.currentContext == NavigationContext.homeAnalytics) {
      print('Navigating to home overview from tab');
      _navigateToHomeOverview(context, navigationController);
      return true; // Consume the back press
    }
    
    // If we're already at home overview, show exit confirmation
    if (navigationController.currentContext == NavigationContext.homeOverview) {
      print('Already at home overview - showing exit confirmation');
      return _handleExitConfirmation(context);
    }
    
    // If we're in other main screens (Accounts, Credit Cards, Analytics, More), go to home overview
    if (navigationController.currentContext == NavigationContext.accounts ||
        navigationController.currentContext == NavigationContext.creditCards ||
        navigationController.currentContext == NavigationContext.analytics ||
        navigationController.currentContext == NavigationContext.more) {
      print('Navigating to home overview from main screen');
      _navigateToHomeOverview(context, navigationController);
      return true; // Consume the back press
    }
    
    // Check if we're in a pushed route (like AnalyticsScreen from home)
    // If we can pop the current route, do it and go to home overview
    if (Navigator.of(context).canPop()) {
      print('Popping route and navigating to home overview');
      Navigator.of(context).pop();
      // After popping, navigate to home overview
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToHomeOverview(context, navigationController);
      });
      return true; // Consume the back press
    }
    
    // Fallback: show exit confirmation
    print('Fallback - showing exit confirmation');
    return _handleExitConfirmation(context);
  }

  /// Handle back press with custom logic
  static Future<bool> handleCustomBackPress(BuildContext context, {
    VoidCallback? onBack,
    bool showExitConfirmation = true,
  }) async {
    // If custom back handler is provided, use it
    if (onBack != null) {
      onBack();
      return true;
    }
    
    // Otherwise use default behavior
    return handleBackPress(context);
  }

  /// Navigate to home overview with animation
  static void _navigateToHomeOverview(BuildContext context, NavigationController navigationController) {
    navigationController.navigateToHomeOverview();
    // No popup - silent navigation
  }

  /// Handle exit confirmation with double-tap detection
  static Future<bool> _handleExitConfirmation(BuildContext context) async {
    final now = DateTime.now();
    
    // Check if this is a double press
    if (_lastBackPressed != null && 
        now.difference(_lastBackPressed!) < _doublePressInterval) {
      _lastBackPressed = null;
      // Direct exit without confirmation dialog
      SystemNavigator.pop();
      return true;
    }
    
    // First press - show "Press again to exit" message
    _lastBackPressed = now;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.exit_to_app, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            const Text('Press back again to exit app'),
          ],
        ),
        duration: _doublePressInterval,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: Colors.orange[600],
      ),
    );
    
    return true; // Consume the back press
  }

}

/// Widget wrapper that handles system back button
class BackButtonHandlerWidget extends StatelessWidget {
  final Widget child;

  const BackButtonHandlerWidget({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await BackButtonHandler.handleBackPress(context);
        }
      },
      child: child,
    );
  }
}

/// Mixin for easy back button handling in StatefulWidgets
mixin BackButtonHandlerMixin<T extends StatefulWidget> on State<T> {
  @override
  Widget build(BuildContext context) {
    return BackButtonHandlerWidget(
      child: buildWithBackHandler(context),
    );
  }

  /// Override this method instead of build() when using the mixin
  Widget buildWithBackHandler(BuildContext context);
}

/// Extension for easy back button handling
extension BackButtonHandlerExtension on Widget {
  /// Wrap widget with back button handling
  Widget withBackButtonHandler() {
    return BackButtonHandlerWidget(child: this);
  }
}
