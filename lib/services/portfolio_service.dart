import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/portfolio_model.dart';
import '../models/spot_price_model.dart';
import 'auth_service.dart';

final String spotBaseUrl = dotenv.env['SPOT_API_URL']!;
final String baseUrl = dotenv.env['API_URL']!;

class PortfolioService {
  static Future<SpotPriceData> fetchSpotPrices() async {
    try {
      final response = await http.get(
        Uri.parse('$spotBaseUrl/SpotPrices'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return SpotPriceData.fromJson(responseData);
      } else {
        throw Exception('Failed to fetch spot prices: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error fetching spot prices: ${e.toString()}');
    }
  }

  static Future<PortfolioData> fetchCustomerPortfolio(
    int customerId,
    String frequency,
  ) async {
    try {
      final authService = AuthService();
      final token = await authService.getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/Portfolio/CustomerPortFolio'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'customerId': customerId,
          'frequency': frequency,
          'metal': null,
          'productType': null,
          'productId': 0,
        }),
      );

      if (response.statusCode == 200) {
        final dynamic rawResponse = jsonDecode(response.body);

        // Check for success in response
        if (rawResponse['success'] == true) {
          // Handle the data and return the PortfolioData object
          if (rawResponse is List) {
            if (rawResponse.isNotEmpty) {
              final Map<String, dynamic> responseData = rawResponse[0];
              return PortfolioData.fromJson(responseData);
            } else {
              throw Exception('Empty list response from API');
            }
          } else if (rawResponse is Map<String, dynamic>) {
            // Return the response as PortfolioData without throwing error if certain arrays are null
            return PortfolioData.fromJson(rawResponse);
          } else {
            throw Exception(
              'Unexpected response type: ${rawResponse.runtimeType}',
            );
          }
        } else {
          // If success is false, don't throw error but return PortfolioData with null arrays
          return PortfolioData.fromJson(
            rawResponse,
          ); // Process null arrays gracefully
        }
      } else {
        throw Exception(
          'Failed to fetch customer portfolio: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception(
        'Network error fetching customer portfolio: ${e.toString()}',
      );
    }
  }
}

Future<dynamic> fetchSpotPricesDateWise({
  required String productName,
  required String purchaseDate,
  required String token,
  required String metal,
}) async {
  final url =
      '$baseUrl/Portfolio/GetSpotPricesDateWise'
      '?date=$purchaseDate&productName=$productName&metal=$metal';

  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Could not fetch spot prices date wise');
  }
}
