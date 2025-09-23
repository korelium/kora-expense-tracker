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
  
  /// Parent category ID (null for main categories, ID for subcategories)
  @HiveField(5)
  final String? parentId;
  
  /// Notes/description for the category
  @HiveField(6)
  final String? notes;
  
  /// Usage count for smart suggestions
  @HiveField(7)
  final int usageCount;
  
  /// Last used date for sorting
  @HiveField(8)
  final DateTime? lastUsed;

  /// Constructor for Category model
  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
    this.color,
    this.parentId,
    this.notes,
    this.usageCount = 0,
    this.lastUsed,
  });

  /// Convert Category to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'type': type.toString().split('.').last,
      'color': color,
      'parentId': parentId,
      'notes': notes,
      'usageCount': usageCount,
      'lastUsed': lastUsed?.toIso8601String(),
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
      parentId: json['parentId'],
      notes: json['notes'],
      usageCount: json['usageCount'] ?? 0,
      lastUsed: json['lastUsed'] != null ? DateTime.parse(json['lastUsed']) : null,
    );
  }

  /// Create a copy of this category with updated fields
  Category copyWith({
    String? id,
    String? name,
    String? icon,
    CategoryType? type,
    String? color,
    String? parentId,
    String? notes,
    int? usageCount,
    DateTime? lastUsed,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      color: color ?? this.color,
      parentId: parentId ?? this.parentId,
      notes: notes ?? this.notes,
      usageCount: usageCount ?? this.usageCount,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  /// Get the icon as IconData for UI display
  IconData get iconData {
    // Use a constant map to avoid tree-shaking issues
    const iconMap = {
      // Income Categories
      'work': Icons.work_outline,
      'laptop': Icons.laptop_mac_outlined,
      'trending_up': Icons.trending_up_outlined,
      'card_giftcard': Icons.card_giftcard_outlined,
      'category': Icons.category_outlined,
      
      // Expense Categories
      'restaurant': Icons.restaurant_outlined,
      'shopping_cart': Icons.shopping_cart_outlined,
      'directions_car': Icons.directions_car_outlined,
      'movie': Icons.movie_outlined,
      'health_and_safety': Icons.health_and_safety_outlined,
      'school': Icons.school_outlined,
      'flight': Icons.flight_outlined,
      'electrical_services': Icons.electrical_services_outlined,
      
      // Food & Dining Subcategories
      'shopping_basket': Icons.shopping_basket_outlined,
      'fastfood': Icons.fastfood_outlined,
      'local_cafe': Icons.local_cafe_outlined,
      
      // Transportation Subcategories
      'local_gas_station': Icons.local_gas_station_outlined,
      'directions_bus': Icons.directions_bus_outlined,
      'local_taxi': Icons.local_taxi_outlined,
      'local_parking': Icons.local_parking_outlined,
      
      // Shopping Subcategories
      'checkroom': Icons.checkroom_outlined,
      'devices': Icons.devices_outlined,
      'shopping_bag': Icons.shopping_bag_outlined,
      
      // Entertainment Subcategories
      'sports_esports': Icons.sports_esports_outlined,
      'subscriptions': Icons.subscriptions_outlined,
      
      // Health & Medical Subcategories
      'fitness_center': Icons.fitness_center_outlined,
      'medical_services': Icons.medical_services_outlined,
      'local_pharmacy': Icons.local_pharmacy_outlined,
      
      // Education Subcategories
      'menu_book': Icons.menu_book_outlined,
      'account_balance': Icons.account_balance_outlined,
      
      // Utilities Subcategories
      'bolt': Icons.bolt_outlined,
      'water_drop': Icons.water_drop_outlined,
      'wifi': Icons.wifi_outlined,
      
      // Other Categories
      'home': Icons.home_outlined,
      'pets': Icons.pets_outlined,
      'savings': Icons.savings_outlined,
      'receipt': Icons.receipt_outlined,
      'emoji_events': Icons.emoji_events_outlined,
      'schedule': Icons.schedule_outlined,
    };
    
    return iconMap[icon] ?? Icons.category_outlined;
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
  
  /// Check if this is a main category (no parent)
  bool get isMainCategory => parentId == null;
  
  /// Check if this is a subcategory (has parent)
  bool get isSubcategory => parentId != null;
  
  /// Increment usage count and update last used date
  Category incrementUsage() {
    return copyWith(
      usageCount: usageCount + 1,
      lastUsed: DateTime.now(),
    );
  }

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
