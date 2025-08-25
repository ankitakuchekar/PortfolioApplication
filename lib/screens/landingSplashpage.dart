import 'package:flutter/material.dart';
import 'package:bold_portfolio/screens/login_screen.dart';

class Landingsplashpage extends StatelessWidget {
  const Landingsplashpage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              // 🔹 Full image
              Image.network(
                'https://res.cloudinary.com/bold-pm/image/upload/Graphics/portfolio-app-landing-page-1.webp',
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width,
              ),

              // 🔹 Positioned Button over the image (near bottom, just above black edge)
              Positioned(
                bottom: 80, // Adjust this to align with your red mark
                left: 24,
                right: 24,
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffF2B234),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
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
                    const SizedBox(height: 8),
                    const Text(
                      "Figures shown are for illustration purposes only.",
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
