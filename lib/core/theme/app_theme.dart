// File location: lib/core/theme/app_theme.dart
// Purpose: App theme configuration with vibrant colors and modern design
// Author: Pown Kumar - Founder of Korelium
// Date: September 18, 2025

import 'package:flutter/material.dart';

/// App theme configuration with vibrant colors and modern design
/// Contains light and dark theme definitions with consistent color scheme
class AppTheme {
  // ===== BRAND COLORS =====
  // Primary brand colors - Indigo based for modern look
  static const Color primaryBlue = Color(0xFF6366F1); // Indigo-500 - Main brand color
  static const Color primaryBlueDark = Color(0xFF4F46E5); // Indigo-600 - Darker variant
  static const Color accentBlue = Color(0xFF8B5CF6); // Purple-500 - Secondary accent
  static const Color infoCyan = Color(0xFF06B6D4); // Cyan-500 - Info color
  
  // Status colors - For income/expense indicators
  static const Color successGreen = Color(0xFF10B981); // Emerald-500 - Income color
  static const Color warningOrange = Color(0xFFF59E0B); // Amber-500 - Warning color
  static const Color errorRed = Color(0xFFEF4444); // Red-500 - Expense color
  static const Color pinkAccent = Color(0xFFEC4899); // Pink-500 - Special accent
  
  // ===== LIGHT THEME COLORS =====
  // Enhanced light theme with better contrast and vibrancy
  static const Color lightBackground = Color(0xFFFAFBFC); // Very light blue-gray background
  static const Color lightSurface = Color(0xFFFFFFFF); // Pure white surface
  static const Color lightCard = Color(0xFFFFFFFF); // White cards with subtle shadows
  static const Color lightText = Color(0xFF1A202C); // Dark gray text for better readability
  static const Color lightTextSecondary = Color(0xFF4A5568); // Medium gray for secondary text
  static const Color lightBorder = Color(0xFFE2E8F0); // Light gray borders
  static const Color lightDivider = Color(0xFFF1F5F9); // Very light dividers
  
  // ===== DARK THEME COLORS =====
  static const Color darkBackground = Color(0xFF0F172A); // Dark blue-gray background
  static const Color darkSurface = Color(0xFF1E293B); // Dark surface color
  static const Color darkCard = Color(0xFF334155); // Dark card color
  static const Color darkText = Color(0xFFF1F5F9); // Light text on dark background
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Medium light for secondary text

  /// Light theme configuration with vibrant colors and modern design
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // ===== COLOR SCHEME =====
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.light,
        primary: primaryBlue, // Main app color
        secondary: accentBlue, // Secondary actions
        tertiary: infoCyan, // Tertiary actions
        surface: lightSurface, // Card and surface backgrounds
        surfaceContainerHighest: lightBackground, // Page background
        error: errorRed, // Error states
        onPrimary: Colors.white, // Text on primary color
        onSecondary: Colors.white, // Text on secondary color
        onSurface: lightText, // Primary text color
        onSurfaceVariant: lightTextSecondary, // Secondary text color
        onError: Colors.white, // Text on error color
        outline: lightBorder, // Border color
        outlineVariant: lightDivider, // Divider color
      ),
      
      // ===== APP BAR THEME =====
      appBarTheme: AppBarTheme(
        backgroundColor: lightSurface,
        foregroundColor: lightText,
        elevation: 0, // No shadow for modern look
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: lightText,
        ),
        iconTheme: IconThemeData(color: lightText),
      ),
      
      // ===== CARD THEME =====
      cardTheme: CardThemeData(
        elevation: 2, // Subtle shadow for depth
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Rounded corners
        ),
        color: lightCard,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      ),
      
      // ===== BUTTON THEMES =====
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Rounded buttons
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          side: BorderSide(color: primaryBlue, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      
      // ===== INPUT DECORATION THEME =====
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: errorRed),
        ),
        filled: true,
        fillColor: Colors.grey[50], // Very light gray background
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(color: lightTextSecondary),
        labelStyle: TextStyle(color: lightTextSecondary),
      ),
      
      // ===== FLOATING ACTION BUTTON THEME =====
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // ===== BOTTOM NAVIGATION THEME =====
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: lightSurface,
        selectedItemColor: primaryBlue,
        unselectedItemColor: lightTextSecondary,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
      ),
      
      // ===== CHIP THEME =====
      chipTheme: ChipThemeData(
        backgroundColor: lightBackground,
        selectedColor: primaryBlue.withValues(alpha: 0.15),
        labelStyle: TextStyle(
          color: lightText,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide(color: lightBorder),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      
      // ===== TAB BAR THEME =====
      tabBarTheme: const TabBarThemeData(
        labelColor: primaryBlue,
        unselectedLabelColor: lightTextSecondary,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: primaryBlue, width: 3),
          insets: const EdgeInsets.symmetric(horizontal: 16),
        ),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
    );
  }

  /// Dark theme configuration with modern dark design
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // ===== COLOR SCHEME =====
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.dark,
        primary: primaryBlue,
        secondary: accentBlue,
        surface: darkSurface,
        error: errorRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkText,
        onError: Colors.white,
      ),
      
      // ===== APP BAR THEME =====
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkText,
        ),
        iconTheme: IconThemeData(color: darkText),
      ),
      
      // ===== CARD THEME =====
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: darkCard,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      ),
      
      // ===== BUTTON THEMES =====
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          side: BorderSide(color: primaryBlue, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      
      // ===== INPUT DECORATION THEME =====
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkTextSecondary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkTextSecondary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: errorRed),
        ),
        filled: true,
        fillColor: darkCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(color: darkTextSecondary),
        labelStyle: TextStyle(color: darkTextSecondary),
      ),
      
      // ===== FLOATING ACTION BUTTON THEME =====
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // ===== BOTTOM NAVIGATION THEME =====
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: primaryBlue,
        unselectedItemColor: darkTextSecondary,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
      ),
      
      // ===== CHIP THEME =====
      chipTheme: ChipThemeData(
        backgroundColor: darkCard,
        selectedColor: primaryBlue.withValues(alpha: 0.2),
        labelStyle: TextStyle(
          color: darkText,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide(color: darkTextSecondary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      
      // ===== TAB BAR THEME =====
      tabBarTheme: const TabBarThemeData(
        labelColor: primaryBlue,
        unselectedLabelColor: darkTextSecondary,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: primaryBlue, width: 3),
          insets: const EdgeInsets.symmetric(horizontal: 16),
        ),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
    );
  }
}
