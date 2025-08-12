import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _baseUrl =
      'https://mobile-dev-api.boldpreciousmetals.com/api';
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  Future<AuthResponse> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/Authentication/authenticate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'emailId': username,
          'password': password,
          'screenSize': '1536, 390',
          'sessionId': "",
          'token': "",
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(responseData);
        print('authResponse: ${authResponse.token}');
        if (authResponse.success && authResponse.token != null) {
          await _saveToken(authResponse.token!);
          if (authResponse.user != null) {
            await _saveUser(authResponse.user!);
          }
        }
        return authResponse;
      } else {
        return AuthResponse(
          success: false,
          message: responseData['message'] ?? 'Login failed',
        );
      }
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> _saveUser(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(userData));
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);
    if (userString != null) {
      final userData = jsonDecode(userString);
      return User.fromJson(userData);
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
