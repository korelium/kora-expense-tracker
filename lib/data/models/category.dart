// File location: lib/data/models/category.dart
// Purpose: Category data model for organizing transactions by type
// Author: Pown Kumar - Founder of Korelium
// Date: September 18, 2025

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'category.g.dart';

/// Category model for organizing transactions
/// Used to group and categorize income and expense transactions
@HiveType(typeId: 5)
class Category extends HiveObject {
  /// Unique identifier for the category
  @HiveField(0)
  final String id;
  
  /// Display name of the category
  @HiveField(1)
  final String name;
  
  /// Icon code for the category (Material Icons codePoint)
  @HiveField(2)
  final String icon;
  
  /// Type of category (income or expense)
  @HiveField(3)
  final CategoryType type;
  
  /// Optional color for the category (hex color value as string)
  @HiveField(4)
  final String? color;

  /// Constructor for Category model
  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
    this.color,
  });

  /// Convert Category to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'type': type.toString().split('.').last,
      'color': color,
    };
  }

  /// Create Category from JSON data
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Category',
      icon: json['icon'] is String ? json['icon'] : Icons.category.codePoint.toString(),
      type: CategoryType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => CategoryType.expense, // Default to expense if not found
      ),
        color: json['color'] is String ? json['color'] : Colors.grey.value.toRadixString(16),
    );
  }

  /// Create a copy of this category with updated fields
  Category copyWith({
    String? id,
    String? name,
    String? icon,
    CategoryType? type,
    String? color,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      color: color ?? this.color,
    );
  }

  /// Get the icon as IconData for UI display
  IconData get iconData {
    try {
      return IconData(int.parse(icon), fontFamily: 'MaterialIcons');
    } catch (e) {
      return Icons.category; // Fallback icon if parsing fails
    }
  }

  /// Get the color as Color object for UI display
  Color get colorData {
    if (color != null) {
      try {
        return Color(int.parse(color!));
      } catch (e) {
        return Colors.grey; // Fallback color if parsing fails
      }
    }
    return Colors.grey; // Default color
  }

  /// Check if this is an income category
  bool get isIncome => type == CategoryType.income;

  /// Check if this is an expense category
  bool get isExpense => type == CategoryType.expense;

  @override
  String toString() {
    return 'Category(id: $id, name: $name, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Enum representing the type of category
/// Determines whether category is for income or expense transactions
@HiveType(typeId: 2)
enum CategoryType {
  /// Income category - for money coming in
  @HiveField(0)
  income,
  
  /// Expense category - for money going out
  @HiveField(1)
  expense,
}
