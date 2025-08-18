import 'package:bold_portfolio/screens/login_screen.dart';
import 'package:flutter/material.dart';

class Landingsplashpage extends StatefulWidget {
  const Landingsplashpage({Key? key}) : super(key: key);

  @override
  State<Landingsplashpage> createState() => _LandingsplashpageState();
}

class _LandingsplashpageState extends State<Landingsplashpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xff13171F),
                  Color(0xff2A2A38),
                  Color(0xff6C4E34),
                  Color.fromARGB(255, 88, 60, 4),
                ],
                stops: [0.0, 0.4, 0.7, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 18),
                    const Text(
                      "Secure Your Wealth\nOne Ounce at a Time",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        height: 1.25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Track live prices, Manage your gold\n& silver portfolio with confidence",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Image.network(
                            'https://res.cloudinary.com/bold-pm/image/upload/Graphics/portfolio-app-landing-page.webp',
                            fit: BoxFit.contain,
                          ),
                          // Removed extra spacing below the image
                        ],
                      ),
                    ),
                    const SizedBox(height: 6), // Reduced spacing here
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffF2B234),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },

                        child: const Text(
                          "Manage Portfolio",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24), // Optional bottom padding
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
