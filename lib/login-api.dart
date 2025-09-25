import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb

class GoogleSignInApi {
  static final _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? '347771815909-ci32m2rgo3as3e4k6gbktume1g1hlpp0.apps.googleusercontent.com' // <-- Web only
        : null,
    scopes: ['email'],
  );

  static Future<GoogleSignInAccount?> login() => _googleSignIn.signIn();
}
