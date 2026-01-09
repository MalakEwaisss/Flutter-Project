import 'package:flutter_application_1/models/group_member.dart';

class TripGroup {
  final String id;
  final String groupName;
  final String tripId;
  final String tripName;
  final String destination;
  final String tripDate;
  final String? description;
  final String ownerId;
  final String ownerName;
  final List<GroupMember> members;
  final String createdAt;
  final String? groupImage;
  final bool isPublic; // NEW: public or private group

  TripGroup({
    required this.id,
    required this.groupName,
    required this.tripId,
    required this.tripName,
    required this.destination,
    required this.tripDate,
    this.description,
    required this.ownerId,
    required this.ownerName,
    required this.members,
    required this.createdAt,
    this.groupImage,
    this.isPublic = true, // Default to public
  });

  int get memberCount => members.length;

  factory TripGroup.fromJson(Map<String, dynamic> json) {
    return TripGroup(
      id: json['id'].toString(),
      groupName: json['group_name'],
      tripId: json['trip_id'],
      tripName: json['trip_name'],
      destination: json['destination'],
      tripDate: json['trip_date'],
      description: json['description'],
      ownerId: json['owner_id'],
      ownerName: json['owner_name'],
      members: (json['members'] as List?)
              ?.map((m) => GroupMember.fromJson(m))
              .toList() ??
          [],
      createdAt: json['created_at'],
      groupImage: json['group_image'],
      isPublic: json['is_public'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'group_name': groupName,
      'trip_id': tripId,
      'trip_name': tripName,
      'destination': destination,
      'trip_date': tripDate,
      'description': description,
      'owner_id': ownerId,
      'owner_name': ownerName,
      'created_at': createdAt,
      'group_image': groupImage,
      'is_public': isPublic,
    };
  }
}