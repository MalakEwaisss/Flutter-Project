class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final String? bio;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.bio,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'].toString(),
      name: json['name'],
      email: json['email'],
      avatar: json['avatar'],
      bio: json['bio'],
    );
  }
}