import 'package:bold_portfolio/screens/enter_pin_screen.dart';
import 'package:bold_portfolio/screens/guestScreen.dart';
import 'package:bold_portfolio/screens/spot_priceScreen.dart';
import 'package:bold_portfolio/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import 'landingSplashpage.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 4));

    if (mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.checkAuthStatus();
      final authService = AuthService();
      final fetchedUserPin = await authService.getPin();
      print(
        'Fetched User PIN: $fetchedUserPin ${authProvider.isAuthenticated}',
      );
      if (mounted) {
        // if (authProvider.isAuthenticated &&
        //     ((fetchedUserPin == null || fetchedUserPin == '0'))) {
        //   print("Navigating to MainScreen");
        //   Navigator.of(context).pushReplacement(
        //     MaterialPageRoute(builder: (context) => MainScreen()),
        //   );
        // } else if (authProvider.isAuthenticated && fetchedUserPin != null) {
        //   Navigator.of(context).pushReplacement(
        //     MaterialPageRoute(
        //       builder: (context) => NewPinEntryScreen(isFromSettings: false),
        //     ),
        //   );
        // } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => Guestscreen()),
        );
        // }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://res.cloudinary.com/bold-pm/image/upload/Graphics/bpm-app-logo-icon.png',
              fit: BoxFit.cover,
              width: 170,
            ),

            const SizedBox(height: 40),
            // const Text(
            //   'BOLD Precious Metals',
            //   style: TextStyle(
            //     fontSize: 24,
            //     fontWeight: FontWeight.bold,
            //     color: AppColors.background,
            //   ),
            // ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.background),
            ),
          ],
        ),
      ),
    );
  }
}
