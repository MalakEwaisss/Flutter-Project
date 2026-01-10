import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class MeetingPoint {
  final String id;
  final String name;
  final String description;
  final LatLng location;
  final IconData icon;

  MeetingPoint({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.icon,
  });

  factory MeetingPoint.fromJson(Map<String, dynamic> json) {
    return MeetingPoint(
      id: json['id'].toString(),
      name: json['name'],
      description: json['description'] ?? '',
      location: LatLng(
        double.parse(json['latitude'].toString()),
        double.parse(json['longitude'].toString()),
      ),
      icon: _getIcon(json['icon_type']),
    );
  }

  static IconData _getIcon(String? type) {
    switch (type) {
      case 'airport':
        return Icons.flight;
      case 'train':
        return Icons.train;
      case 'landmark':
        return Icons.tour;
      case 'hotel':
        return Icons.hotel;
      default:
        return Icons.place;
    }
  }
}