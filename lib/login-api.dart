import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb

class GoogleSignInApi {
  static final _googleSignIn = GoogleSignIn(
    clientId: !kIsWeb
        ? '347771815909-ci32m2rgo3as3e4k6gbktume1g1hlpp0.apps.googleusercontent.com' // <-- Web only
        : null,
    scopes: ['email'],
  );

  static Future<Map<String, dynamic>?> login() async {
    try {
      final GoogleSignInAccount? user = await _googleSignIn.signIn();
      print("user ${user}");
      if (user == null) {
        // If sign-in is cancelled by the user
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await user.authentication;
      print("user ${googleAuth}");

      // Now you can retrieve the Google token
      final String googleToken = googleAuth.accessToken ?? '';

      return {
        'googleToken': googleToken,
        'email': user.email,
        'firstName': user.displayName?.split(' ')[0] ?? '',
        'lastName': user.displayName?.split(' ')[1] ?? '',
        'profilePhoto': user.photoUrl,
        'id': user.id,
      };
    } catch (e) {
      print('Google sign-in failed: $e');
      return null;
    }
  }

  // Retrieve Google user details (useful for backend authentication)
  static Future<Map<String, dynamic>?> getUserDetails() async {
    final user = _googleSignIn.currentUser;
    if (user != null) {
      return {
        'email': user.email,
        'firstName': user.displayName?.split(' ')[0] ?? '',
        'lastName': user.displayName?.split(' ')[1] ?? '',
        'profilePhoto': user.photoUrl,
        'id': user.id,
      };
    }
    return null;
  }

  // Check if the user is already signed in
  static bool isSignedIn() => _googleSignIn.currentUser != null;
}
