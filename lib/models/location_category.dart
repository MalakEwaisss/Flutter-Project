import 'package:flutter/material.dart';

enum LocationCategory {
  restaurant,
  attraction,
  hotel,
  shopping,
  nature,
  transport,
  other,
}

extension LocationCategoryExtension on LocationCategory {
  String get displayName {
    switch (this) {
      case LocationCategory.restaurant:
        return 'Restaurant';
      case LocationCategory.attraction:
        return 'Attraction';
      case LocationCategory.hotel:
        return 'Hotel';
      case LocationCategory.shopping:
        return 'Shopping';
      case LocationCategory.nature:
        return 'Nature';
      case LocationCategory.transport:
        return 'Transport';
      case LocationCategory.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case LocationCategory.restaurant:
        return Icons.restaurant;
      case LocationCategory.attraction:
        return Icons.attractions;
      case LocationCategory.hotel:
        return Icons.hotel;
      case LocationCategory.shopping:
        return Icons.shopping_bag;
      case LocationCategory.nature:
        return Icons.park;
      case LocationCategory.transport:
        return Icons.directions_bus;
      case LocationCategory.other:
        return Icons.place;
    }
  }

  Color get color {
    switch (this) {
      case LocationCategory.restaurant:
        return const Color(0xFFE91E63);
      case LocationCategory.attraction:
        return const Color(0xFF9C27B0);
      case LocationCategory.hotel:
        return const Color(0xFF2196F3);
      case LocationCategory.shopping:
        return const Color(0xFFFF9800);
      case LocationCategory.nature:
        return const Color(0xFF4CAF50);
      case LocationCategory.transport:
        return const Color(0xFF607D8B);
      case LocationCategory.other:
        return const Color(0xFF795548);
    }
  }
}