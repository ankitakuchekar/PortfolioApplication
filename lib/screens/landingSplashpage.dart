// import 'package:flutter/material.dart';
// import 'package:bold_portfolio/screens/login_screen.dart';

// class Landingsplashpage extends StatelessWidget {
//   const Landingsplashpage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Stack(
//             children: [
//               // 🔹 Full image
//               Image.network(
//                 'https://res.cloudinary.com/bold-pm/image/upload/Graphics/portfolio-app-landing-page-1.webp',
//                 fit: BoxFit.cover,
//                 width: MediaQuery.of(context).size.width,
//               ),

//               // 🔹 Positioned Button over the image (near bottom, just above black edge)
//               Positioned(
//                 bottom: 80, // Adjust this to align with your red mark
//                 left: 24,
//                 right: 24,
//                 child: Column(
//                   children: [
//                     SizedBox(
//                       width: double.infinity,
//                       height: 48,
//                       child: ElevatedButton(
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => const LoginScreen(),
//                             ),
//                           );
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xffF2B234),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(14),
//                           ),
//                         ),
//                         child: const Text(
//                           "Manage Portfolio",
//                           style: TextStyle(
//                             fontSize: 17,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     const Text(
//                       "Figures shown are for illustration purposes only.",
//                       style: TextStyle(fontSize: 12, color: Colors.white70),
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

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

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.network(
              'https://res.cloudinary.com/bold-pm/image/upload/Graphics/portfolio-app-landing-page-bg-1.webp',
              fit: BoxFit.cover,
            ),
          ),

          // Foreground Content
          SingleChildScrollView(
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(minHeight: screenHeight),
              padding: const EdgeInsets.all(16.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 5),
                    // Logo
                    Image.network(
                      'https://res.cloudinary.com/bold-pm/image/upload/v1629887471/Graphics/email/BPM-White-Logo.png',
                      width: 250,
                    ),
                    const SizedBox(height: 15),

                    // Heading and Subheading
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        children: [
                          TextSpan(text: 'Track Your \n'),
                          TextSpan(
                            text: 'Gold & Silver,\n',
                            style: TextStyle(color: Colors.yellow),
                          ),
                          TextSpan(text: 'Anytime, Anywhere.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Easily check your investments real-time values with secure, live market data.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    const SizedBox(height: 20),

                    // Feature Cards
                    const FeatureCard(
                      icon: Text(
                        '🔒',
                        style: TextStyle(fontSize: 32), // adjust size as needed
                      ),
                      title: 'Secure & Simple Experience',
                      description:
                          'Your data is protected with an easy-to-use interface.',
                    ),
                    const FeatureCard(
                      icon: Text(
                        '📊',
                        style: TextStyle(fontSize: 32), // adjust size as needed
                      ),
                      title: 'Real-Time Investment Tracking',
                      description:
                          'See your gold and silver’s live value anytime.',
                    ),
                    const FeatureCard(
                      icon: Text(
                        '📈',
                        style: TextStyle(fontSize: 32), // adjust size as needed
                      ),
                      title: 'Add & Compare Predictions',
                      description:
                          'Forecast your investments and compare with market values.',
                    ),
                    const SizedBox(height: 20),

                    // CTA Button
                    ElevatedButton.icon(
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
                        minimumSize: const Size(
                          250,
                          50,
                        ), // Adjust the size if needed
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(
                        Icons.phone_android,
                        color: Colors.black,
                      ),
                      label: Text(
                        'Start Tracking Your Investments',
                        style: TextStyle(
                          fontSize: 17, // Adjusted font size if needed
                          fontWeight: FontWeight.w500,
                          color: Color.fromARGB(255, 38, 37, 37),
                        ),
                        overflow: TextOverflow
                            .ellipsis, // Prevents overflow with ellipsis
                        maxLines: 1, // Keeps the text in one line
                      ),
                    ),
                    const SizedBox(height: 40), // Bottom spacing
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

// Reuse FeatureCard
class FeatureCard extends StatefulWidget {
  final Widget icon;
  // final Color iconColor;
  final String title;
  final String description;

  const FeatureCard({
    Key? key,
    required this.icon,
    // required this.iconColor,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  State<FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0), // Start from left
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Card(
          color: const Color.fromARGB(255, 16, 15, 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    // color: widget.iconColor,
                    shape: BoxShape.circle,
                  ),
                  child: widget.icon,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
