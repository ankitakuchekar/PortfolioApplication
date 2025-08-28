import 'package:bold_portfolio/widgets/common_app_bar.dart';
import 'package:flutter/material.dart';
import '../widgets/common_drawer.dart';
import '../utils/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CommonAppBar(title: 'Privacy Policy'),
      drawer: const CommonDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Privacy Policy for Bullion Portfolio",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Your privacy is our priority. Learn how we protect and handle your data within the Bullion Portfolio feature.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Section 1
            const Text(
              "1. Data Privacy & Access Control",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            bulletPoint(
              "The Bullion Portfolio is designed to be accessible only to the user who has logged into their account.",
            ),
            bulletPoint(
              "No other user, including administrators, can view or access the portfolio data of another user.",
            ),
            bulletPoint(
              "Users must be logged in to view their portfolio; no data will be visible to any third party or unauthorized entity.",
            ),
            bulletPoint(
              "If a user adds a bullion product to their portfolio that was not purchased from our website, the details of that product will be visible only to that user.",
            ),
            bulletPoint(
              "If a user purchases a bullion product from our website, the product will only be visible in their portfolio after it has been shipped.",
            ),

            const SizedBox(height: 24),

            // Section 2
            const Text(
              "2. Data Security Measures",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            bulletPoint(
              "We implement strict security protocols to prevent unauthorized access to user portfolios.",
            ),
            bulletPoint(
              "Data transmission is encrypted using industry-standard security measures.",
            ),
            bulletPoint(
              "Any personal or investment data is securely stored and never shared or sold to third parties.",
            ),

            const SizedBox(height: 24),

            // Section 3
            const Text(
              "3. User Authentication",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            bulletPoint(
              "Only the registered user associated with the account can access their portfolio.",
            ),
            bulletPoint(
              "Users are responsible for maintaining the confidentiality of their login credentials.",
            ),
          ],
        ),
      ),
    );
  }

  /// Helper widget for bullet points
  static Widget bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 16)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
