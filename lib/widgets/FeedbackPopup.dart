import 'package:bold_portfolio/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FeedbackPopup extends StatefulWidget {
  const FeedbackPopup({super.key});

  @override
  _FeedbackPopupState createState() => _FeedbackPopupState();
}

class _FeedbackPopupState extends State<FeedbackPopup> {
  final TextEditingController _feedbackController = TextEditingController();
  String selectedFeedbackType = '';
  final List<String> feedbackTypes = [
    'Suggestions',
    'Cost Concern',
    'Product Issue',
    'Other',
  ];

  bool isLoading = false;

  void _submitFeedback() async {
    if (selectedFeedbackType.isEmpty || _feedbackController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => isLoading = true);
    final String baseUrl = dotenv.env['API_URL']!;
    final url = Uri.parse("$baseUrl/Portfolio/AddPortfolioCustomerFeedbacks");
    final authService = AuthService();
    final token = await authService.getToken();

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "customerId": 0,
          "feedBackText": _feedbackController.text.trim(),
          "feedBackType": selectedFeedbackType,
        }),
      );

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        Navigator.pop(context); // Close popup
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Thank you for your feedback.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to send feedback")),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to send feedback")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "We Value Your Feedback!",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),

                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              "Your feedback helps us improve! Share your thoughts below.",
              style: TextStyle(color: Colors.grey[700]),
            ),
            SizedBox(height: 16),

            /// Feedback type
            Text(
              "Select Feedback Type ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text.rich(
              TextSpan(
                text: '*',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.red,
                ),
              ),
            ),

            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: feedbackTypes.map((type) {
                final isSelected = selectedFeedbackType == type;
                return ChoiceChip(
                  label: Text(type),
                  selected: isSelected,
                  selectedColor: Colors.blue[50],
                  backgroundColor: Colors.grey[100],
                  onSelected: (_) {
                    setState(() {
                      selectedFeedbackType = type;
                    });
                  },
                );
              }).toList(),
            ),

            SizedBox(height: 20),

            /// Feedback text input
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Your Feedback ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  TextSpan(
                    text: '*',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _feedbackController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Share your feedback here...",
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            SizedBox(height: 20),

            /// Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Submit Your Feedback"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
