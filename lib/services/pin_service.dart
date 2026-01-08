import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PinService {
  static Future<bool> updateAppPin({
    required String customerId,
    required String pin,
  }) async {
    final String baseUrl = dotenv.env['API_URL']!;
    final String url =
        "$baseUrl/Portfolio/UpdateCustomerPortfolioAppPin?customerid=$customerId&Pin=$pin";

    try {
      final response = await http.post(Uri.parse(url));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> verifyAppPin({
    required String customerId,
    required String pin,
  }) async {
    final String baseUrl = dotenv.env['API_URL']!;
    final String url =
        "$baseUrl/Portfolio/GetCustomerPortfolioAppPin?customerId=$customerId&pin=$pin";

    try {
      final response = await http.get(Uri.parse(url));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
