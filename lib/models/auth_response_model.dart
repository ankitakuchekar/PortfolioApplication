class AuthResponse {
  final bool success;
  final Map<String, dynamic>? data;
  final String? message;

  AuthResponse({required this.success, this.data, this.message});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return AuthResponse(
      success: json['success'] ?? false,
      data: data is Map<String, dynamic> ? data : null,
      message: json['errorMessage'] ?? json['message'],
    );
  }

  /// ✅ Getter for token
  String? get token {
    if (data != null && data!.containsKey('token')) {
      return data!['token']?.toString();
    }
    return null;
  }

  /// ✅ Getter for user data (raw Map)
  Map<String, dynamic>? get user {
    return data;
  }
}
