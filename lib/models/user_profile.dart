class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final String? bio;
  final DateTime? createdAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.bio,
    this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'],
      bio: json['bio'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'email': email, 'avatar': avatar, 'bio': bio};
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? avatar,
    String? bio,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Validation
  bool isValid() {
    return name.isNotEmpty && email.isNotEmpty && _isValidEmail(email);
  }

  String? validate() {
    if (name.isEmpty) return 'Name is required';
    if (email.isEmpty) return 'Email is required';
    if (!_isValidEmail(email)) return 'Invalid email format';
    return null;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
