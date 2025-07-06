class User {
  final String id;
  final String username;
  final String fullName;
  final List<String> roles;
  final String token;

  User({
    required this.id,
    required this.username,
    required this.fullName,
    required this.roles,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Handle the case where username is used as ID if no specific ID is provided
    final userId = (json['id'] ?? json['username'])?.toString() ?? '';
    if (userId.isEmpty) {
      throw Exception('User ID or username is required');
    }

    // Safely extract username
    final username = json['username']?.toString() ?? '';
    if (username.isEmpty) {
      throw Exception('Username is required');
    }

    // Safely extract fullName
    final fullName = json['fullName']?.toString() ?? '';
    if (fullName.isEmpty) {
      throw Exception('Full name is required');
    }

    // Safely extract token
    final token = json['token']?.toString() ?? '';
    if (token.isEmpty) {
      throw Exception('Token is required');
    }

    // Safely extract roles with type checking
    List<String> roles = [];
    if (json['roles'] != null) {
      if (json['roles'] is List) {
        roles = (json['roles'] as List).map((role) => role.toString()).toList();
      } else if (json['roles'] is String) {
        // Handle case where roles might be a comma-separated string
        roles = [json['roles'].toString()];
      }
    }

    return User(
      id: userId,
      username: username,
      fullName: fullName,
      roles: roles,
      token: token,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'fullName': fullName,
      'roles': roles,
      'token': token,
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? fullName,
    List<String>? roles,
    String? token,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      roles: roles ?? this.roles,
      token: token ?? this.token,
    );
  }
} 