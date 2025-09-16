// services/api_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:bold_portfolio/models/portfolio_model.dart';

Future<bool> updatePortfolioSettings({
  required int customerId,
  required PortfolioSettings settings,
  required bool showActualPrice,
  required String token,
}) async {
  final String baseUrl = dotenv.env['API_URL']!;
  final url = Uri.parse('$baseUrl/Portfolio/UpdateCustomerPortfolioSettings');

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      "customerId": customerId,
      "showPrediction": settings.showPrediction,
      "showActualPrice": showActualPrice,
      "showActual": !showActualPrice,
      "showVdo": settings.showVdo,
      "doNotShowAgain": settings.doNotShowAgain,
      "showGoldPrediction": settings.showGoldPrediction,
      "showSilverPrediction": settings.showSilverPrediction,
      "showTotalPrediction": settings.showTotalPrediction,
    }),
  );

  if (response.statusCode == 200) {
    return true;
  } else {
    print("API Error: ${response.statusCode} - ${response.body}");
    return false;
  }
}
