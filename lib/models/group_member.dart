class GroupMember {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String role; // 'owner' or 'member'
  final String joinedAt;
  final String? userAvatar;

  GroupMember({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.role,
    required this.joinedAt,
    this.userAvatar,
  });

  bool get isOwner => role == 'owner';

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      id: json['id'].toString(),
      userId: json['user_id'],
      userName: json['user_name'],
      userEmail: json['user_email'],
      role: json['role'],
      joinedAt: json['joined_at'],
      userAvatar: json['user_avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_name': userName,
      'user_email': userEmail,
      'role': role,
      'joined_at': joinedAt,
      'user_avatar': userAvatar,
    };
  }
}