import 'package:flutter/material.dart';
import 'package:bold_portfolio/screens/login_screen.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double scaleFont(double baseSize, double screenWidth) {
    if (screenWidth < 350) return baseSize * 0.75;
    if (screenWidth < 450) return baseSize * 0.9;
    if (screenWidth > 600) return baseSize * 1.1;
    return baseSize;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    final headingFont = scaleFont(28, screenWidth);
    final subFont = scaleFont(15, screenWidth);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Image.network(
            'https://res.cloudinary.com/bold-pm/image/upload/Graphics/portfolio-app-landing-page-bg-1.webp',
            fit: BoxFit.cover,
          ),

          // Overlay
          Container(color: Colors.black.withOpacity(0.5)),

          FadeTransition(
            opacity: _fadeAnimation,
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.07,
                      vertical: screenHeight * 0.02,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Logo
                        Image.network(
                          'https://res.cloudinary.com/bold-pm/image/upload/v1629887471/Graphics/email/BPM-White-Logo.png',
                          width: screenWidth * 0.55,
                        ),

                        // Title + Subtitle
                        Column(
                          children: [
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: headingFont,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                children: const [
                                  TextSpan(text: 'Track Your\n'),
                                  TextSpan(
                                    text: 'Gold & Silver,\n',
                                    style: TextStyle(color: Colors.yellow),
                                  ),
                                  TextSpan(text: 'Anytime, Anywhere.'),
                                ],
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.015),
                            Text(
                              'Easily check your investments real-time values with secure, live market data.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: subFont,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),

                        // Feature cards area
                        Flexible(
                          flex: 3,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              FeatureCard(
                                icon: Text('🔒', style: TextStyle(fontSize: 28)),
                                title: 'Secure & Simple Experience',
                                description:
                                    'Your data is protected with an easy-to-use interface.',
                              ),
                              SizedBox(height: 8),
                              FeatureCard(
                                icon: Text('📊', style: TextStyle(fontSize: 28)),
                                title: 'Real-Time Investment Tracking',
                                description:
                                    'See your gold and silver’s live value anytime.',
                              ),
                              SizedBox(height: 8),
                              FeatureCard(
                                icon: Text('📈', style: TextStyle(fontSize: 28)),
                                title: 'Add & Compare Predictions',
                                description:
                                    'Forecast your investments and compare with market values.',
                              ),
                            ],
                          ),
                        ),

                        // Button
                        SizedBox(
                          width: screenWidth * 0.85,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.phone_android,
                                color: Colors.black),
                            label: FittedBox(
                              child: Text(
                                'Start Tracking Your Investments',
                                style: TextStyle(
                                  fontSize: scaleFont(17, screenWidth),
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 🔹 Responsive FeatureCard (auto-adjusts for screen size)
class FeatureCard extends StatelessWidget {
  final Widget icon;
  final String title;
  final String description;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final titleFont = width < 400 ? 14.5 : 16.0;
    final descFont = width < 400 ? 12.5 : 14.0;

    return Card(
      color: const Color.fromARGB(255, 16, 15, 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: titleFont,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: descFont,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: LandingPage()),
  );
}
