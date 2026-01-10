import 'package:latlong2/latlong.dart';

class DayLocation {
  final int day;
  final String title;
  final String description;
  final LatLng location;
  final List<String> activities;
  final String time;

  DayLocation({
    required this.day,
    required this.title,
    required this.description,
    required this.location,
    required this.activities,
    required this.time,
  });

  factory DayLocation.fromJson(Map<String, dynamic> json) {
    return DayLocation(
      day: json['day'],
      title: json['title'],
      description: json['description'],
      location: LatLng(
        double.parse(json['latitude'].toString()),
        double.parse(json['longitude'].toString()),
      ),
      activities: List<String>.from(json['activities']),
      time: json['time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'title': title,
      'description': description,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'activities': activities,
      'time': time,
    };
  }
}