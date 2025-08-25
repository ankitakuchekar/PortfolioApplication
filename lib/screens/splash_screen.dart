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

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _coinRotationController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  late AnimationController _yellowBarAnimController;
  late Animation<Offset> _yellowBarOffset;

  late AnimationController _whiteBarAnimController;
  late Animation<Offset> _whiteBarOffset;

  @override
  void initState() {
    super.initState();

    // Coin rotation
    _coinRotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Fade in for center content
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();

    // Yellow bar animation (top right)
    _yellowBarAnimController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _yellowBarOffset =
        Tween<Offset>(
          begin: const Offset(1.5, 0.0),
          end: const Offset(0.0, 0.0),
        ).animate(
          CurvedAnimation(
            parent: _yellowBarAnimController,
            curve: Curves.easeInOut,
          ),
        );

    // White bar animation (bottom left)
    _whiteBarAnimController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _whiteBarOffset =
        Tween<Offset>(
          begin: const Offset(-1.5, 0.0),
          end: const Offset(0.0, 0.0),
        ).animate(
          CurvedAnimation(
            parent: _whiteBarAnimController,
            curve: Curves.easeInOut,
          ),
        );

    _initializeApp();
  }

  @override
  void dispose() {
    _coinRotationController.dispose();
    _fadeController.dispose();
    _yellowBarAnimController.dispose();
    _whiteBarAnimController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 4));

    if (mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.checkAuthStatus();

      if (mounted) {
        if (authProvider.isAuthenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Landingsplashpage()),
          );
        }
      }
    }
  }

  Widget rotatingCoin({
    required double top,
    required double left,
    required String imageUrl,
  }) {
    return Positioned(
      top: top,
      left: left,
      child: RotationTransition(
        turns: _coinRotationController,
        child: Image.network(
          imageUrl,
          width: 55,
          height: 55,
          errorBuilder: (context, error, stackTrace) =>
              Icon(Icons.error), // optional
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Colors.grey.shade900],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Rotating coins
          rotatingCoin(
            top: 100,
            left: 30,
            imageUrl:
                'https://res.cloudinary.com/bold-pm/image/upload/Graphics/2025-american-eagle-gold-coin-1.png',
          ),
          rotatingCoin(
            top: 100,
            left: screenSize.width - 70,
            imageUrl:
                'https://res.cloudinary.com/bold-pm/image/upload/Graphics/2025-american-eagle-silver-coin-1.png',
          ),
          rotatingCoin(
            top: screenSize.height - 130,
            left: 50,
            imageUrl:
                'https://res.cloudinary.com/bold-pm/image/upload/Graphics/2025-american-eagle-silver-coin-1.png',
          ),
          rotatingCoin(
            top: screenSize.height - 120,
            left: screenSize.width - 100,
            imageUrl:
                'https://res.cloudinary.com/bold-pm/image/upload/Graphics/2025-american-eagle-gold-coin-1.png',
          ),

          // Yellow sliding bar (top right)
          Positioned(
            top: 80,
            right: 20,
            child: SlideTransition(
              position: _yellowBarOffset,
              child: Container(
                width: 60,
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.yellow, Colors.orangeAccent],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),

          // White sliding bar (bottom left)
          Positioned(
            bottom: 130,
            left: 20,
            child: SlideTransition(
              position: _whiteBarOffset,
              child: Container(
                width: 60,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),

          // Center logo and text
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.yellowAccent, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.asset(
                      'assets/images/bold_logo.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Bullion Portfolio',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Where your investment shines brighter',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  Container(width: 100, height: 2, color: Colors.yellowAccent),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
