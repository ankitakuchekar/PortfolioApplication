import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:bold_portfolio/providers/auth_provider.dart';
import 'package:bold_portfolio/services/auth_service.dart';
import 'main_screen.dart'; // Make sure to import your MainScreen

class SettingPinScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Set/Update App PIN',
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}

class SettingPinScreenComponent extends StatefulWidget {
  @override
  _SettingPinScreenComponentState createState() =>
      _SettingPinScreenComponentState();
}

class _SettingPinScreenComponentState extends State<SettingPinScreenComponent> {
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

  // Submit PIN function
  Future<void> submitPin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkAuthStatus();

    final String baseUrl = dotenv.env['API_URL']!;

    String pin = _getPin(_newPinControllers).trim();

    final authService = AuthService();
    final fetchedUser = await authService.getUser();
    String customerId = fetchedUser?.id ?? '';
    if (authProvider.isAuthenticated) {
      try {
        final response = await http.post(
          Uri.parse(
            "$baseUrl/Portfolio/GetCustomerPortfolioAppPin?customerid=$customerId&Pin=$pin",
          ),
        );
        print("Response Status: ${response.statusCode}");
        if (response.statusCode == 200) {
          print("PIN updated successfully.");
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
    } else {
      try {
        final response = await http.post(
          Uri.parse(
            "$baseUrl/Portfolio/UpdateCustomerPortfolioAppPin?customerid=$customerId&Pin=$pin",
          ),
          headers: {
            "Accept": "*/*",
            "Authorization":
                "Bearer ${fetchedUser?.token}", // Include Bearer token
          },
        );
        print("Response Status: ${response.statusCode} ${fetchedUser?.token}");
        if (response.statusCode == 200) {
          print("PIN updated successfully.");
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      resizeToAvoidBottomInset:
          true, // Ensure resizing when the keyboard appears
      body: SingleChildScrollView(
        // Allow scrolling when the keyboard appears
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set/Update App PIN',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'This PIN is required every time you open the app.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 40),
            Text('New PIN', style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Input fields for New PIN
                ...List.generate(4, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: SizedBox(
                      width: 50,
                      child: TextFormField(
                        controller: _newPinControllers[index],
                        maxLength: 1,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        obscureText: _obscureNewPin,
                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        onChanged: (value) =>
                            _onFieldChanged(index, value, _newPinControllers),
                      ),
                    ),
                  );
                }),
                // Eye Icon for New PIN
                IconButton(
                  icon: Icon(
                    _obscureNewPin ? Icons.visibility_off : Icons.visibility,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureNewPin = !_obscureNewPin;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 40),
            Text('Confirm New PIN', style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Input fields for Confirm New PIN
                ...List.generate(4, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: SizedBox(
                      width: 50,
                      child: TextFormField(
                        controller: _confirmPinControllers[index],
                        maxLength: 1,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        obscureText: _obscureConfirmPin,
                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        onChanged: (value) => _onFieldChanged(
                          index,
                          value,
                          _confirmPinControllers,
                        ),
                      ),
                    ),
                  );
                }),
                // Eye Icon for Confirm PIN
                IconButton(
                  icon: Icon(
                    _obscureConfirmPin
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPin = !_obscureConfirmPin;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Ensure the PINs match before submitting
                String newPin = _getPin(_newPinControllers);
                String confirmPin = _getPin(_confirmPinControllers);

                if (newPin == confirmPin) {
                  submitPin(); // Call the submitPin function
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('PINs do not match')));
                }
              },
              child: Text('Save PIN'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
