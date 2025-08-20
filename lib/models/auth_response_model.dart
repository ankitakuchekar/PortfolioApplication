class AuthResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? users;

  AuthResponse({required this.success, required this.message, this.users});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      users: data is Map<String, dynamic> ? data : null,
    );
  }

  /// ✅ Getter for token
  String? get token {
    if (user != null && user!.containsKey('token')) {
      return user!['token']?.toString();
    }
    return null;
  }

  /// ✅ Getter for user data (raw Map)
  Map<String, dynamic>? get user {
    return users;
  }
}
