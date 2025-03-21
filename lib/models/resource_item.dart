import 'package:flutter/material.dart';

/// **ResourceItem Model**
/// Represents an item that can be shared in the application.
class ResourceItem {
  final String name;
  final String category;
  final String image;
  final String owner;
  final IconData? icon;
  final String description;

  ResourceItem({
    required this.name,
    required this.category,
    required this.image,
    required this.owner,
    this.icon,
    required this.description,
  });

  /// **Converts a ResourceItem to a Map (for storage or API requests)**
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'image': image,
      'owner': owner,
      'icon': icon?.codePoint, // Convert IconData to int
      'description': description,
    };
  }

  /// **Creates a ResourceItem from a Map (useful for local storage or API responses)**
  factory ResourceItem.fromMap(Map<String, dynamic> map) {
    return ResourceItem(
      name: map['name'],
      category: map['category'],
      image: map['image'],
      owner: map['owner'],
      icon: map['icon'] != null ? IconData(map['icon'], fontFamily: 'MaterialIcons') : null,
      description: map['description'],
    );
  }
}
