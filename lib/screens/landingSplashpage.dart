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

import 'package:bold_portfolio/screens/login_screen.dart';
import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.network(
                'https://res.cloudinary.com/bold-pm/image/upload/Graphics/portfolio-app-landing-page-bg-1.webp',
                fit: BoxFit.cover,
              ),
            ),
            // Content overlaid on top of the background
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo
                    Image.network(
                      'https://res.cloudinary.com/bold-pm/image/upload/v1629887471/Graphics/email/BPM-White-Logo.png',
                      width: 150,
                    ),
                    const SizedBox(height: 15),
                    // Heading and Subheading
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // default color for text
                        ),
                        children: [
                          TextSpan(text: 'Your Precious Metals,\n'),
                          TextSpan(
                            text: 'Your Wealth,\n',
                            style: TextStyle(
                              color: Colors.yellow,
                            ), // Yellow color for "Your Wealth"
                          ),
                          TextSpan(text: 'Your Control.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Your precious metals investment starts with solid, secure returns.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    // Action buttons with descriptive text
                    Column(
                      children: [
                        // Track Your Holdings Feature Card
                        FeatureCard(
                          icon: Icons.show_chart,
                          iconColor: Colors.green,
                          title: 'Track Your Holdings',
                          description:
                              'Secure real-time portfolio tracking with detailed analytics.',
                        ),
                        // View Live Performance Feature Card
                        FeatureCard(
                          icon: Icons.trending_up,
                          iconColor: Colors.blue,
                          title: 'View Live Performance',
                          description:
                              'Real-time market data and performance insights.',
                        ),
                        // Add Predictions Feature Card
                        FeatureCard(
                          icon: Icons.circle,
                          iconColor: Colors.purple,
                          title: 'Add Predictions',
                          description:
                              'AI-powered market predictions and investment guidance.',
                        ),

                        const SizedBox(height: 10),
                        // Start Tracking Your Investments Button
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
                            backgroundColor: Colors.amber, // Button color
                            minimumSize: Size(250, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: Icon(
                            Icons.phone_android,
                            color: Colors.black,
                          ), // Icon on the left
                          label: Column(
                            children: [
                              Text(
                                'Start Tracking Your Investments',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: const Color.fromARGB(255, 38, 37, 37),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Join thousands of investors securing their financial future',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  const FeatureCard({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(
        255,
        16,
        15,
        15,
      ), // Slightly gray background color for the card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ), // Border with slight transparency
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Icon with background color
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: Colors.white),
            ),
            const SizedBox(width: 20),
            // Text with title and description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(fontSize: 14, color: Colors.white70),
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
  runApp(MaterialApp(home: LandingPage()));
}
