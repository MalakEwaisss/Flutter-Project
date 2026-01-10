import 'package:latlong2/latlong.dart';
import 'location_category.dart';

class SavedLocation {
  final String id;
  final String name;
  final String description;
  final LatLng location;
  final LocationCategory category;
  final String? notes;
  final DateTime savedAt;

  SavedLocation({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.category,
    this.notes,
    required this.savedAt,
  });

  factory SavedLocation.fromJson(Map<String, dynamic> json) {
    return SavedLocation(
      id: json['id'].toString(),
      name: json['name'],
      description: json['description'],
      location: LatLng(json['latitude'], json['longitude']),
      category: LocationCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => LocationCategory.other,
      ),
      notes: json['notes'],
      savedAt: DateTime.parse(json['saved_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'category': category.name,
      'notes': notes,
      'saved_at': savedAt.toIso8601String(),
    };
  }
}