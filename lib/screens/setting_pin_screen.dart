import 'package:bold_portfolio/services/biometric_auth_service.dart';
import 'package:bold_portfolio/services/pin_service.dart' show PinService;
import 'package:bold_portfolio/utils/app_colors.dart';
import 'package:bold_portfolio/widgets/common_app_bar.dart';
import 'package:bold_portfolio/widgets/common_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bold_portfolio/providers/auth_provider.dart';
import 'package:bold_portfolio/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_screen.dart'; // Make sure to import your MainScreen

class SettingPinScreen extends StatefulWidget {
  final bool isSettingPage;

  const SettingPinScreen({super.key, required this.isSettingPage});

  @override
  _SettingPinScreenState createState() => _SettingPinScreenState();
}

class _SettingPinScreenState extends State<SettingPinScreen> {
  String? pinForApp = '';
  bool _showBiometricLogin = false;
  late String currentUserKey;

  @override
  void initState() {
    super.initState();
    initUserBiometric();
  }

  Future<void> initUserBiometric() async {
    final authService = AuthService();
    final fetchedUser = await authService.getUser();

    currentUserKey = fetchedUser != null && fetchedUser.id.isNotEmpty
        ? fetchedUser.id
        : fetchedUser?.email ?? '';

    final prefs = await SharedPreferences.getInstance();
    _showBiometricLogin =
        prefs.getBool('biometric_enabled_$currentUserKey') ?? false;

    setState(() {});
  }

  Future<void> saveBiometricPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled_$currentUserKey', value);
  }

  final List<TextEditingController> _newPinControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<TextEditingController> _confirmPinControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  bool _obscureNewPin = true;
  bool _obscureConfirmPin = true;

  // To handle focus movement between blocks
  void _onFieldChanged(
    int index,
    String value,
    List<TextEditingController> controllers,
  ) {
    if (value.isNotEmpty && index < 3) {
      FocusScope.of(context).nextFocus();
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).previousFocus();
    }
  }

  // To join the pin inputs
  String _getPin(List<TextEditingController> controllers) {
    return controllers.map((e) => e.text).join('');
  }

  Future<void> submitPin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkAuthStatus();

    final pin = _getPin(_newPinControllers).trim();

    if (!RegExp(r'^\d+$').hasMatch(pin)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN must contain only numbers'),
          backgroundColor: Colors.red,
        ),
      );
      return; // ⛔ Stop execution
    }

    final authService = AuthService();
    final fetchedUser = await authService.getUser();

    final bool success = await PinService.updateAppPin(
      customerId: fetchedUser?.id ?? '',
      pin: pin,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN Successfully Set'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const MainScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update PIN'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: widget.isSettingPage
          ? CommonAppBar(title: 'Settings')
          : AppBar(
              title: widget.isSettingPage ? const Text('Settings') : null,
              backgroundColor: Colors.white,
              elevation: 0,
              foregroundColor: Colors.black,
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => MainScreen()),
                    );
                  },
                  child: const Text(
                    'SKIP',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
      drawer: widget.isSettingPage ? const CommonDrawer() : null,
      body: SingleChildScrollView(
        child: SizedBox(
          // height: MediaQuery.of(context).size.height,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.isSettingPage
                      ? TextButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.black87,
                          ),
                          label: const Text(
                            'Back',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 1,
                              vertical: 4,
                            ),
                            minimumSize:
                                Size.zero, // To prevent default min button size
                            tapTargetSize: MaterialTapTargetSize
                                .shrinkWrap, // Compact tap area
                          ),
                        )
                      : const SizedBox.shrink(),

                  const Text(
                    'Set / Update App PIN',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'This PIN is required every time you open the app.',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 22),

                  _pinSectionWithoutEye(
                    title: 'New PIN',
                    controllers: _newPinControllers,
                    obscure: _obscureNewPin,
                  ),

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

                  const SizedBox(height: 14),

                  _pinSectionWithoutEye(
                    title: 'Confirm New PIN',
                    controllers: _confirmPinControllers,
                    obscure: _obscureConfirmPin,
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(
                        _obscureConfirmPin
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey.shade700,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPin = !_obscureConfirmPin;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        final newPin = _getPin(_newPinControllers);
                        final confirmPin = _getPin(_confirmPinControllers);

                        if (newPin == confirmPin) {
                          submitPin();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('PINs do not match')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        textStyle: const TextStyle(color: Colors.white),
                        disabledBackgroundColor: Colors.grey.shade300,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Save PIN',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  widget.isSettingPage
                      ? const SizedBox(height: 7)
                      : const SizedBox(height: 24),

                  widget.isSettingPage
                      ? SizedBox.shrink()
                      : Row(
                          children: [
                            Expanded(
                              child: Divider(color: Colors.grey.shade300),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(color: Colors.grey.shade300),
                            ),
                          ],
                        ),

                  widget.isSettingPage
                      ? const SizedBox(height: 7)
                      : const SizedBox(height: 20),

                  widget.isSettingPage
                      ? SizedBox.shrink()
                      : SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: _showBiometricLogin
                                ? () async {
                                    bool check = await BiometricAuthService()
                                        .authenticateLocalUser();
                                    print("Biometric Auth Result: $check");
                                    if (check) {
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const MainScreen(),
                                        ),
                                      );
                                    }
                                  }
                                : null,
                            icon: const Icon(Icons.fingerprint),
                            label: const Text('Biometric / Face Unlock'),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                          ),
                        ),

                  const SizedBox(height: 6),

                  !widget.isSettingPage
                      ? SizedBox.shrink()
                      : Divider(color: Colors.grey.shade300),
                  !widget.isSettingPage
                      ? SizedBox.shrink()
                      : const Text(
                          'Use fingerprint or face recognition to log in faster.',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                  !widget.isSettingPage
                      ? SizedBox.shrink()
                      : const SizedBox(height: 12),
                  !widget.isSettingPage
                      ? SizedBox.shrink()
                      : Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Enable Biometric Login',
                                style: TextStyle(fontSize: 14),
                              ),
                              Switch(
                                value: _showBiometricLogin,
                                onChanged: (pinForApp == '' || pinForApp == '0')
                                    ? (value) async {
                                        setState(() {
                                          _showBiometricLogin = value;
                                        });
                                        await saveBiometricPreference(value);
                                      }
                                    : null,
                              ),
                            ],
                          ),
                        ),

                  const SizedBox(height: 20),
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
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
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
