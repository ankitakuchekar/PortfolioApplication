import 'package:bold_portfolio/providers/auth_provider.dart';
import 'package:bold_portfolio/screens/main_screen.dart';
import 'package:bold_portfolio/services/auth_service.dart';
import 'package:bold_portfolio/services/biometric_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
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
  final TextEditingController _pinController = TextEditingController();
  bool _showBiometricLogin = false;
  @override
  void initState() {
    super.initState();
    _loadBiometricPreference();
  }

  Future<void> submitPin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkAuthStatus();

    final String baseUrl = dotenv.env['API_URL']!;

    final authService = AuthService();
    final fetchedUser = await authService.getUser();
    String customerId = fetchedUser?.id ?? '';
    try {
      final response = await http.get(
        Uri.parse(
          "$baseUrl/Portfolio/GetCustomerPortfolioAppPin?customerId=$customerId&pin=${_pinController.text}",
        ),
      );

      if (response.statusCode == 200) {
        print("PIN verified successfully.");
        // API call was successful, navigate to MainScreen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        // Handle error (Optional)
        print("Error: ${response.statusCode}");
        print("Response: ${response.body}");
      }
    } catch (e) {
      print("Error occurred: $e");
    }
  }

  Future<void> _loadBiometricPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showBiometricLogin = prefs.getBool('showBioMetricLogin') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA), // ✅ light professional bg
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Title
              Text(
                widget.isFromSettings ? 'Enter your current PIN' : 'Hi, User',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 6),

              /// Subtitle
              const Text(
                'Enter your PIN',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),

              const SizedBox(height: 24),

              /// PIN boxes + hidden input
              Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(4, (index) => _pinBox(index)),
                  ),

                  /// Hidden TextField (real input)
                  Opacity(
                    opacity: 0,
                    child: TextField(
                      controller: _pinController,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      autofocus: true,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// Forgot PIN
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {},
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
                  onPressed: _pinController.text.length == 4
                      ? () {
                          submitPin();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade600,
                    disabledBackgroundColor: Colors.grey.shade300,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text('Submit', style: TextStyle(fontSize: 16)),
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
                child: OutlinedButton.icon(
                  onPressed: _showBiometricLogin
                      ? () async {
                          bool check = await BiometricAuthService()
                              .authenticateLocalUser();
                          print("Biometric Auth Result: $check");
                          if (check) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const MainScreen(),
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
            ],
          ),
        ),
      ),
    );
  }

  /// PIN box widget
  Widget _pinBox(int index) {
    bool filled = index < _pinController.text.length;

    return Container(
      width: 54,
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(14),
      ),
      child: filled
          ? const Icon(Icons.circle, size: 10, color: Colors.black)
          : null,
    );
  }
}
