import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/portfolio_model.dart';
import '../models/spot_price_model.dart';
import 'auth_service.dart';

class PortfolioService {
  static PortfolioData getMockPortfolioData() {
    return PortfolioData(
      totalInvestment: 1500.00,
      currentValue: 1709.47,
      totalProfitLoss: 209.47,
      totalProfitLossPercentage: 13.96,
      dayProfitLoss: 25.30,
      dayProfitLossPercentage: 1.50,
      silver: MetalData(
        name: 'Silver',
        value: 838.27,
        ounces: 25.5,
        profit: 104.23,
        profitPercentage: 14.2,
      ),
      gold: MetalData(
        name: 'Gold',
        value: 871.20,
        ounces: 0.45,
        profit: 105.24,
        profitPercentage: 13.7,
      ),
      chartData: _generateMockChartData(),
    );
  }

  static List<ChartData> _generateMockChartData() {
    final now = DateTime.now();
    return List.generate(30, (index) {
      return ChartData(
        date: now.subtract(Duration(days: 29 - index)),
        value: 1500 + (index * 7) + (index % 3 * 10),
      );
    });
  }

  static List<Holding> getMockHoldings() {
    return [
      Holding(
        id: '1',
        name: 'Silver 1oz',
        type: 'Silver',
        quantity: 20.0,
        purchasePrice: 25.50,
        currentPrice: 28.75,
        profit: 65.00,
        profitPercentage: 12.7,
      ),
      Holding(
        id: '2',
        name: '1 gram gold',
        type: 'Gold',
        quantity: 15.0,
        purchasePrice: 55.00,
        currentPrice: 62.30,
        profit: 109.50,
        profitPercentage: 13.3,
      ),
    ];
  }

  static Future<SpotPriceData> fetchSpotPrices() async {
    try {
      final response = await http.get(
        Uri.parse('https://mobile-dev-spot-api.boldpreciousmetals.com/SpotPrices'),
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

  static Future<PortfolioData> fetchCustomerPortfolio(int customerId) async {
    try {
      final authService = AuthService();
      final token = await authService.getToken();
      
      final response = await http.post(
        Uri.parse('https://mobile-dev-api.boldpreciousmetals.com/api/Portfolio/CustomerPortFolio'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'customerId': customerId,
          'frequency': '3M',
          'metal': null,
          'productType': null,
          'productId': 0,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        return PortfolioData(
          totalInvestment: (responseData['totalInvestment'] ?? 1500.0).toDouble(),
          currentValue: (responseData['currentValue'] ?? 1709.47).toDouble(),
          totalProfitLoss: (responseData['totalProfitLoss'] ?? 209.47).toDouble(),
          totalProfitLossPercentage: (responseData['totalProfitLossPercentage'] ?? 13.96).toDouble(),
          dayProfitLoss: (responseData['dayProfitLoss'] ?? 25.30).toDouble(),
          dayProfitLossPercentage: (responseData['dayProfitLossPercentage'] ?? 1.50).toDouble(),
          silver: MetalData(
            name: 'Silver',
            value: (responseData['silverValue'] ?? 838.27).toDouble(),
            ounces: (responseData['silverOunces'] ?? 25.5).toDouble(),
            profit: (responseData['silverProfit'] ?? 104.23).toDouble(),
            profitPercentage: (responseData['silverProfitPercentage'] ?? 14.2).toDouble(),
          ),
          gold: MetalData(
            name: 'Gold',
            value: (responseData['goldValue'] ?? 871.20).toDouble(),
            ounces: (responseData['goldOunces'] ?? 0.45).toDouble(),
            profit: (responseData['goldProfit'] ?? 105.24).toDouble(),
            profitPercentage: (responseData['goldProfitPercentage'] ?? 13.7).toDouble(),
          ),
          chartData: _generateMockChartData(),
        );
      } else {
        throw Exception('Failed to fetch customer portfolio: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error fetching customer portfolio: ${e.toString()}');
    }
  }
}
