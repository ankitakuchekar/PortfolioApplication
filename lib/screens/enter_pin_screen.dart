import 'package:bold_portfolio/providers/auth_provider.dart';
import 'package:bold_portfolio/screens/login_screen.dart';
import 'package:bold_portfolio/screens/main_screen.dart';
import 'package:bold_portfolio/services/auth_service.dart';
import 'package:bold_portfolio/services/biometric_auth_service.dart';
import 'package:bold_portfolio/services/pin_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewPinEntryScreen extends StatefulWidget {
  final bool isFromSettings;

  const NewPinEntryScreen({Key? key, required this.isFromSettings})
    : super(key: key);

  @override
  State<NewPinEntryScreen> createState() => _NewPinEntryScreenState();
}

class _NewPinEntryScreenState extends State<NewPinEntryScreen> {
  final List<TextEditingController> _newPinControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  bool _obscureNewPin = true;
  bool _showBiometricLogin = true;

  @override
  void dispose() {
    for (var controller in _newPinControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onFieldChanged(
    int index,
    String value,
    List<TextEditingController> controllers,
  ) {
    if (value.length == 1 && index < controllers.length - 1) {
      FocusScope.of(context).nextFocus();
    }
    if (value.isEmpty && index > 0) {
      FocusScope.of(context).previousFocus();
    }
    setState(() {}); // To rebuild Submit button or PIN boxes if needed
  }

  String? emailId;
  String? firstName;
  String? userId;
  late String currentUserKey;

  @override
  void initState() {
    super.initState();
    _loadEmailId();
    _loadBiometricPreference();
    _checkBiometricAvailability();
  }

  final BiometricAuthService _biometricAuthService = BiometricAuthService();
  bool _isBiometricAvailable = false;

  // Check biometric availability
  void _checkBiometricAvailability() async {
    bool isAvailable = await _biometricAuthService
        .canAuthenticateWithBiometrics();
    setState(() {
      _isBiometricAvailable = isAvailable;
    });
  }

  Future<void> _loadEmailId() async {
    final authService = AuthService();
    final fetchedUser = await authService.getUser();
    final fechedEMail = await authService.getEmail();
    setState(() {
      emailId = fechedEMail;
      firstName = fetchedUser?.firstName;
      userId = fetchedUser?.id;
    });
  }

  Future<void> submitPin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkAuthStatus();

    final authService = AuthService();
    final fetchedUser = await authService.getUser();

    final bool isValid = await PinService.verifyAppPin(
      customerId: fetchedUser?.id ?? '',
      pin: _newPinControllers.map((e) => e.text).join('').trim(),
    );

    if (isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN verified successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const MainScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to verify PIN'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadBiometricPreference() async {
    final authService = AuthService();
    final fetchedUser = await authService.getUser();

    currentUserKey = fetchedUser != null && fetchedUser.id.isNotEmpty
        ? fetchedUser.id
        : fetchedUser?.email ?? '';
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showBiometricLogin =
          prefs.getBool('biometric_enabled_$currentUserKey') ?? false;
    });
    bool check = false;
    if (_showBiometricLogin) {
      check = await BiometricAuthService().authenticateLocalUser();
    }
    if (check) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Center(
          // Center vertically and horizontally
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo at the top
                  Image.network(
                    'https://res.cloudinary.com/bold-pm/image/upload/Graphics/Icons/bold-logo-icon.webp',
                    width: 60,
                    height: 60,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 20),

                  // Greeting text
                  Text(
                    widget.isFromSettings
                        ? 'Enter your current PIN'
                        : 'Welcome Back, ${firstName ?? 'User'}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 6),

                  // Instruction text
                  const Text(
                    'Enter your 4-digit PIN to access your account',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),

                  /// PIN Section
                  _pinSectionWithoutEye(
                    title: '',
                    controllers: _newPinControllers,
                    obscure: _obscureNewPin,
                  ),

                  /// Eye icon below PIN boxes
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(
                        _obscureNewPin
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey.shade700,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureNewPin = !_obscureNewPin;
                        });
                      },
                    ),
                  ),

                  /// Forgot PIN
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(
                              fetchedUserEmail: emailId ?? '',
                              isForgotPassClick: true,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Forgot PIN?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFFF9800),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed:
                          _newPinControllers.every((c) => c.text.isNotEmpty)
                          ? submitPin
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// OR divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'OR',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),

                  const SizedBox(height: 18),

                  /// Biometric
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: _showBiometricLogin && _isBiometricAvailable
                          ? () async {
                              bool check = await BiometricAuthService()
                                  .authenticateLocalUser();
                              if (check) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => const MainScreen(),
                                  ),
                                );
                              }
                            }
                          : null,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.fingerprint, color: Colors.orange),
                          const SizedBox(width: 8),
                          Text(
                            'Biometric / Face Unlock',
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.face, color: Colors.orange),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  /// Biometric Note
                  if (_showBiometricLogin && _isBiometricAvailable)
                    const Text(
                      'Note: Please enable biometric authentication or Face Unlock from the settings.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _pinSectionWithoutEye({
    required String title,
    required List<TextEditingController> controllers,
    required bool obscure,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...List.generate(4, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: SizedBox(
                  width: 54,
                  height: 54,
                  child: TextFormField(
                    controller: controllers[index],
                    maxLength: 1,
                    obscureText: obscure,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w200,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      // Add consistent transparent border to avoid size jump
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Colors.transparent,
                          width: 2,
                        ),
                      ),
                      // Focused border with visible color, same width
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.orange, width: 2),
                      ),
                    ),
                    onChanged: (value) =>
                        _onFieldChanged(index, value, controllers),
                  ),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }
}
