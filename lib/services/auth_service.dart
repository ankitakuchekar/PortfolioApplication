import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final String baseUrl = dotenv.env['API_URL']!;
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _passWordKey = 'password_data';
  static const String _emailKey = 'email_data';

  Future<AuthResponse> login(
    String username,
    String password,
    bool isGoogleLogin,
    String googleToken,
    String firstName,
    String lastName,
    String screenSize,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Authentication/authenticate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'emailId': username,
          'password': password,
          'screenSize': screenSize,
          'sessionId': "",
          'GoogleToken': googleToken,
          'isGoogleLogin': isGoogleLogin,
          'firstName': firstName,
          'lastName': lastName,
          'token': '',
          'isAppLogin': true,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(responseData);
        if (authResponse.success && authResponse.token != null) {
          await _saveToken(authResponse.token!);
          if (authResponse.user != null) {
            final user = authResponse.user;
            await _savePassword(password);
            await _saveEmail(username);
            await _saveUser(user!);
          }
        }
        return authResponse;
      } else {
        print("respnonse, $responseData");
        return AuthResponse(
          success: false,
          message:
              responseData['errorMessage'] ??
              'Username or password is incorrect',
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

  Future<void> _savePassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_passWordKey, password);
  }

  Future<String?> getPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_passWordKey);
  }

  Future<void> _saveEmail(String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, password);
  }

  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
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

  bool isLoading = false;

  Future<AuthResponse> validateCaptcha(String captchaToken) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/Authentication/ValidateGoogleReCaptcha?captchaResponse=$captchaToken',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(responseData);
      } else {
        return AuthResponse(
          success: false,
          message:
              responseData['errorMessage'] ?? 'reCAPTCHA validation failed',
        );
      }
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<AuthResponse> register({
    required String firstName,
    required String lastName,
    required String email,
    required String mobile,
    required String password,
    required String screenSize,
    required String captchaToken,
  }) async {
    isLoading = true;
    notifyListeners();

    // final captchaValidation = await validateCaptcha(captchaToken);
    // if (!captchaValidation.success) {
    //   isLoading = false;
    //   notifyListeners();
    //   return captchaValidation;
    // }
    final String baseUrl = dotenv.env['API_URL']!;
    final url = Uri.parse('$baseUrl/Customer/register');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "firstName": firstName,
          "lastName": lastName,
          "emailId": email,
          "mobNo": mobile,
          "password": password,
          "screenSize": screenSize,
          "sessionId": "",
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      isLoading = false;
      notifyListeners();

      if (response.statusCode == 200 && responseData["success"] == true) {
        final authResponse = AuthResponse.fromJson(responseData);

        // ✅ Extract user data and token from `data`
        final userData = responseData['data'];
        final token = userData['token'];
        if (userData != null) {
          await _saveUser(userData); // Save user
        }

        if (token != null && token is String && token.isNotEmpty) {
          await _saveToken(token); // Save token
        }

        return AuthResponse(success: true, users: userData, message: '');
      } else {
        return AuthResponse(
          success: false,
          message: responseData['errorMessage'] ?? 'Registration failed',
        );
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }
}
