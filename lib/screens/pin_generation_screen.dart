import 'package:bold_portfolio/screens/main_screen.dart';
import 'package:bold_portfolio/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:bold_portfolio/services/biometric_auth_service.dart'; // Import your BiometricAuthService

class PinEntryScreen extends StatefulWidget {
  @override
  _PinEntryScreenState createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends State<PinEntryScreen> {
  final _pinController = TextEditingController();
  bool _isPinVisible = false;

  // Function to toggle the visibility of the PIN
  void _togglePinVisibility() {
    setState(() {
      _isPinVisible = !_isPinVisible;
    });
  }

  // Function to handle forgotten PIN
  void _forgotPin() {
    // Handle forgotten PIN logic (e.g., navigate to another screen or show a dialog)
    print("Forgot PIN");
  }

  Future<void> submitPin() async {
    final String baseUrl = dotenv.env['API_URL']!;

    String pin = _pinController.text.trim();

    final authService = AuthService();
    final fetchedUser = await authService.getUser();
    final tokens = await authService.getToken();
    String customerId = fetchedUser?.id ?? '';
    String? token = tokens; // Replace this with actual token

    try {
      final response = await http.post(
        Uri.parse(
          "$baseUrl/Portfolio/UpdateCustomerPortfolioAppPin?customerid=$customerId&Pin=$pin",
        ),
        headers: {
          "Accept": "*/*",
          "Authorization": "Bearer $token", // Include Bearer token
        },
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
        // You can show an error dialog or message here
      }
    } catch (e) {
      // Handle network errors or other exceptions
      print("Error occurred: $e");
      // Show an error dialog or message
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService().getUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text('Error loading user')));
        }
        final fetchedUser = snapshot.data;
        return Scaffold(
          appBar: AppBar(
            title: Text("PIN Entry"),
            backgroundColor: Colors.black, // App bar black background
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.only(
              top: 100,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hi, ${fetchedUser?.firstName ?? 'User'}",
                  style: TextStyle(
                    fontSize: 26, // Increased font size for better visibility
                    fontWeight: FontWeight.bold,
                    color: Colors.black87, // Slightly lighter black color
                  ),
                ),
                SizedBox(height: 30), // Increased space between elements
                TextField(
                  controller: _pinController,
                  obscureText: !_isPinVisible,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color: Colors.black, // Text color for PIN input
                  ),
                  decoration: InputDecoration(
                    labelText: 'Enter PIN',
                    labelStyle: TextStyle(color: Colors.black54), // Label color
                    fillColor: Colors.white, // White background for text field
                    filled: true,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPinVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.black,
                      ),
                      onPressed: _togglePinVisibility,
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,
                      ), // Lighter border color
                      borderRadius: BorderRadius.circular(
                        12.0,
                      ), // Rounded corners
                    ),
                  ),
                ),
                SizedBox(height: 15), // Reduced space
                TextButton(
                  onPressed: _forgotPin,
                  child: Text(
                    "Forgot PIN?",
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
                SizedBox(height: 30), // Increased space before button
                ElevatedButton(
                  onPressed: () {
                    submitPin();
                    // Add your logic to submit or validate the PIN
                    print("PIN Submitted: ${_pinController.text}");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber, // Button background color
                    padding: EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 60,
                    ), // Adjusted padding
                    shape: RoundedRectangleBorder(
                      // Rounded button corners
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    "Submit PIN",
                    style: TextStyle(
                      color: Colors.black87,
                    ), // Dark text color for readability
                  ),
                ),
                SizedBox(height: 30), // Space before fingerprint section
                Center(
                  child: Text(
                    "Or",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ), // Space before the button with text and icon
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () async {
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
                    },
                    icon: Icon(Icons.fingerprint, size: 24), // Fingerprint icon
                    label: Text(
                      "Login with fingerprint / faceid",
                    ), // Text label
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent, // Button color
                      padding: EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 50,
                      ), // Padding
                      shape: RoundedRectangleBorder(
                        // Rounded corners
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
