// File location: lib/core/error_handling/error_utils.dart
// Purpose: Utility functions for error handling and recovery
// Author: Pown Kumar - Founder of Korelium
// Date: September 23, 2025

import 'package:flutter/foundation.dart';

/// Utility class for common error handling operations
class ErrorUtils {
  /// Retry an operation with exponential backoff
  static Future<T> retryOperation<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;
    
    while (attempt < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempt++;
        if (attempt >= maxRetries) {
          rethrow;
        }
        
        if (kDebugMode) {
          print('Operation failed (attempt $attempt/$maxRetries): $e');
          print('Retrying in ${delay.inSeconds} seconds...');
        }
        
        await Future.delayed(delay);
        delay = Duration(seconds: delay.inSeconds * 2); // Exponential backoff
      }
    }
    
    throw Exception('Operation failed after $maxRetries attempts');
  }

  /// Safely execute an operation with error handling
  static Future<T?> safeExecute<T>(
    Future<T> Function() operation, {
    String? operationName,
    bool logErrors = true,
  }) async {
    try {
      return await operation();
    } catch (e) {
      if (logErrors && kDebugMode) {
        final name = operationName ?? 'Operation';
        print('$name failed: $e');
      }
      return null;
    }
  }

  /// Execute multiple operations and return results
  static Future<List<T?>> executeMultiple<T>(
    List<Future<T> Function()> operations, {
    bool failFast = false,
    String? operationName,
  }) async {
    final results = <T?>[];
    
    for (int i = 0; i < operations.length; i++) {
      try {
        final result = await operations[i]();
        results.add(result);
      } catch (e) {
        if (kDebugMode) {
          final name = operationName ?? 'Operation';
          print('$name $i failed: $e');
        }
        
        results.add(null);
        
        if (failFast) {
          break;
        }
      }
    }
    
    return results;
  }

  /// Validate transaction data
  static String? validateTransaction({
    required double amount,
    required String accountId,
    required String categoryId,
    required String description,
  }) {
    if (amount <= 0) {
      return 'Transaction amount must be greater than 0';
    }
    
    if (accountId.isEmpty) {
      return 'Please select an account';
    }
    
    if (categoryId.isEmpty) {
      return 'Please select a category';
    }
    
    if (description.trim().isEmpty) {
      return 'Please enter a description';
    }
    
    return null; // No errors
  }

  /// Validate transfer data
  static String? validateTransfer({
    required double amount,
    required String fromAccountId,
    required String toAccountId,
    required String description,
  }) {
    if (amount <= 0) {
      return 'Transfer amount must be greater than 0';
    }
    
    if (fromAccountId.isEmpty) {
      return 'Please select source account';
    }
    
    if (toAccountId.isEmpty) {
      return 'Please select destination account';
    }
    
    if (fromAccountId == toAccountId) {
      return 'Cannot transfer to the same account';
    }
    
    if (description.trim().isEmpty) {
      return 'Please enter a transfer description';
    }
    
    return null; // No errors
  }

  /// Get user-friendly error message
  static String getUserFriendlyMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('insufficient balance')) {
      return 'Not enough funds in the account';
    }
    
    if (errorString.contains('not found')) {
      return 'The requested item could not be found';
    }
    
    if (errorString.contains('network')) {
      return 'Network connection issue. Please check your internet connection';
    }
    
    if (errorString.contains('database')) {
      return 'Data storage issue. Please try again';
    }
    
    if (errorString.contains('permission')) {
      return 'Permission denied. Please check app permissions';
    }
    
    // Default message
    return 'An unexpected error occurred. Please try again';
  }

  /// Log error with context
  static void logError(
    dynamic error, {
    String? context,
    StackTrace? stackTrace,
    Map<String, dynamic>? additionalData,
  }) {
    if (kDebugMode) {
      final contextStr = context != null ? '[$context] ' : '';
      print('${contextStr}Error: $error');
      
      if (stackTrace != null) {
        print('Stack trace: $stackTrace');
      }
      
      if (additionalData != null && additionalData.isNotEmpty) {
        print('Additional data: $additionalData');
      }
    }
  }

  /// Check if error is recoverable
  static bool isRecoverableError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    // Non-recoverable errors
    if (errorString.contains('not found') && 
        (errorString.contains('account') || errorString.contains('transaction'))) {
      return false;
    }
    
    if (errorString.contains('insufficient balance')) {
      return false;
    }
    
    if (errorString.contains('invalid') && errorString.contains('amount')) {
      return false;
    }
    
    // Recoverable errors
    if (errorString.contains('network')) {
      return true;
    }
    
    if (errorString.contains('timeout')) {
      return true;
    }
    
    if (errorString.contains('database') && !errorString.contains('corrupt')) {
      return true;
    }
    
    return false;
  }

  /// Get error severity level
  static ErrorSeverity getErrorSeverity(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('data loss') || errorString.contains('corrupt')) {
      return ErrorSeverity.critical;
    }
    
    if (errorString.contains('insufficient balance') || 
        errorString.contains('not found')) {
      return ErrorSeverity.high;
    }
    
    if (errorString.contains('network') || errorString.contains('timeout')) {
      return ErrorSeverity.medium;
    }
    
    return ErrorSeverity.low;
  }

  /// Format error for display
  static String formatErrorForDisplay(dynamic error) {
    final severity = getErrorSeverity(error);
    final message = getUserFriendlyMessage(error);
    
    switch (severity) {
      case ErrorSeverity.critical:
        return '🚨 $message';
      case ErrorSeverity.high:
        return '⚠️ $message';
      case ErrorSeverity.medium:
        return '🔄 $message';
      case ErrorSeverity.low:
        return 'ℹ️ $message';
    }
  }
}

/// Error severity levels
enum ErrorSeverity {
  low,
  medium,
  high,
  critical,
}

/// Error recovery strategies
enum ErrorRecoveryStrategy {
  retry,
  fallback,
  skip,
  abort,
}

/// Error context information
class ErrorContext {
  final String operation;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final String? userId;
  final String? sessionId;

  const ErrorContext({
    required this.operation,
    required this.data,
    required this.timestamp,
    this.userId,
    this.sessionId,
  });

  Map<String, dynamic> toMap() {
    return {
      'operation': operation,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'sessionId': sessionId,
    };
  }
}
