import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final String icon;
  final CategoryType type;
  final String? color;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
    this.color,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'type': type.toString().split('.').last,
      'color': color,
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Category',
      icon: json['icon'] is String ? json['icon'] : Icons.category.codePoint.toString(),
      type: CategoryType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => CategoryType.expense, // Default to expense if not found
      ),
      color: json['color'] is String ? json['color'] : Colors.grey.value.toString(),
    );
  }
}

enum CategoryType {
  income,
  expense,
}
