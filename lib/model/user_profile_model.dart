class UserProfileModel {
  final String id;
  final String username;
  final String? email;
  final DateTime createdAt;

  const UserProfileModel({
    required this.id,
    required this.username,
    required this.createdAt,
    this.email,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      username: (json['username'] as String?) ?? '',
      email: json['email'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
    };
  }
}

