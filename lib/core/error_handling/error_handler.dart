// File location: lib/core/error_handling/error_handler.dart
// Purpose: Centralized error handling and user-friendly error messages
// Author: Pown Kumar - Founder of Korelium
// Date: September 23, 2025

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Centralized error handling for the application
class ErrorHandler {
  static const String _defaultErrorMessage = 'Something went wrong. Please try again.';
  
  /// Handle and display errors in a user-friendly way
  static void handleError(BuildContext context, dynamic error, {String? customMessage}) {
    if (kDebugMode) {
      print('Error: $error');
    }
    
    String message = _getUserFriendlyMessage(error, customMessage);
    _showErrorSnackBar(context, message);
  }
  
  /// Get user-friendly error message
  static String _getUserFriendlyMessage(dynamic error, String? customMessage) {
    if (customMessage != null) return customMessage;
    
    if (error is String) return error;
    
    if (error.toString().contains('Insufficient funds')) {
      return 'Insufficient funds. Please check your account balance.';
    }
    
    if (error.toString().contains('Network')) {
      return 'Network error. Please check your internet connection.';
    }
    
    if (error.toString().contains('Database')) {
      return 'Database error. Please restart the app.';
    }
    
    if (error.toString().contains('Validation')) {
      return 'Please check your input and try again.';
    }
    
    return _defaultErrorMessage;
  }
  
  /// Show error snackbar
  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[600],
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
  
  /// Show success message
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green[600],
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  /// Show warning message
  static void showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_outlined, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange[600],
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  /// Show loading dialog
  static void showLoadingDialog(BuildContext context, {String message = 'Loading...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }
  
  /// Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
  
  /// Show confirmation dialog
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
