import 'package:local_auth/local_auth.dart';

class BiometricAuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  Future<bool> authenticateLocalUser() async {
    bool isAuthenticated = false;

    try {
      await _localAuth.authenticate(
        localizedReason: "We need to authenticate this app",
        // options: AuthenticationOptions(stickyAuth: true, useErrorDialogs: true),
      );
      isAuthenticated = true;
    } on LocalAuthException catch (e) {
      if (e.code == LocalAuthExceptionCode.noBiometricHardware) {
        // Add handling of no hardware here.
        print("error1 ${e}");
      } else if (e.code == LocalAuthExceptionCode.temporaryLockout ||
          e.code == LocalAuthExceptionCode.biometricLockout) {
        // ...
        print("error2 ${e}");
      } else {
        // ...
        print("error3 ${e}");
      }
    } catch (e) {
      print("error: $e");
    }

    return isAuthenticated;
  }
}
