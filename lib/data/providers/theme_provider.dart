// File location: lib/data/providers/theme_provider.dart
// Purpose: Theme management for light/dark mode switching
// Author: Pown Kumar - Founder of Korelium
// Date: September 18, 2025

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing app theme (light/dark/system mode)
/// Persists theme preference and provides theme switching functionality
class ThemeProvider with ChangeNotifier {
  // ===== PRIVATE FIELDS =====
  static const String _themeKey = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.system;
  bool _isDarkMode = false;

  // ===== GETTERS =====
  /// Current theme mode (light, dark, or system)
  ThemeMode get themeMode => _themeMode;
  
  /// Whether dark mode is currently active
  bool get isDarkMode => _isDarkMode;
  
  /// Human-readable theme mode name
  String get themeModeName {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  /// Icon for current theme mode
  IconData get themeIcon {
    switch (_themeMode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  /// Description for current theme mode
  String get themeDescription {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Always use light theme';
      case ThemeMode.dark:
        return 'Always use dark theme';
      case ThemeMode.system:
        return 'Follow system theme';
    }
  }

  // ===== CONSTRUCTOR =====
  ThemeProvider() {
    _loadTheme();
  }

  // ===== THEME MANAGEMENT =====
  /// Load saved theme from SharedPreferences
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey) ?? 0;
      
      // Validate theme index
      if (themeIndex >= 0 && themeIndex < ThemeMode.values.length) {
        _themeMode = ThemeMode.values[themeIndex];
      } else {
        _themeMode = ThemeMode.system; // Default fallback
      }
      
      _updateDarkMode();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading theme: $e');
      }
      // Fallback to system theme on error
      _themeMode = ThemeMode.system;
      _isDarkMode = false;
    }
  }

  /// Set theme mode and save to SharedPreferences
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    _updateDarkMode();
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, mode.index);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving theme: $e');
      }
      // Continue even if saving fails
    }
  }

  /// Toggle between light, dark, and system themes
  Future<void> toggleTheme() async {
    ThemeMode newMode;
    switch (_themeMode) {
      case ThemeMode.light:
        newMode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        newMode = ThemeMode.system;
        break;
      case ThemeMode.system:
        newMode = ThemeMode.light;
        break;
    }
    await setThemeMode(newMode);
  }

  /// Set to light theme
  Future<void> setLightTheme() async {
    await setThemeMode(ThemeMode.light);
  }

  /// Set to dark theme
  Future<void> setDarkTheme() async {
    await setThemeMode(ThemeMode.dark);
  }

  /// Set to system theme
  Future<void> setSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }

  // ===== HELPER METHODS =====
  /// Update dark mode status based on current theme mode
  void _updateDarkMode() {
    _isDarkMode = _themeMode == ThemeMode.dark;
  }

  /// Get theme mode index for storage
  int get themeModeIndex => _themeMode.index;

  /// Check if theme is currently light
  bool get isLightMode => _themeMode == ThemeMode.light;

  /// Check if theme is currently system
  bool get isSystemMode => _themeMode == ThemeMode.system;

  /// Reset theme to system default
  Future<void> resetTheme() async {
    await setThemeMode(ThemeMode.system);
  }

  /// Get all available theme modes with their details
  static List<Map<String, dynamic>> get availableThemes => [
    {
      'mode': ThemeMode.light,
      'name': 'Light',
      'description': 'Always use light theme',
      'icon': Icons.light_mode,
    },
    {
      'mode': ThemeMode.dark,
      'name': 'Dark',
      'description': 'Always use dark theme',
      'icon': Icons.dark_mode,
    },
    {
      'mode': ThemeMode.system,
      'name': 'System',
      'description': 'Follow system theme',
      'icon': Icons.brightness_auto,
    },
  ];
}
