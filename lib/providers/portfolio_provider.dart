import 'package:flutter/foundation.dart';
import '../models/portfolio_model.dart';
import '../models/spot_price_model.dart';
import '../services/portfolio_service.dart';

class PortfolioProvider with ChangeNotifier {
  PortfolioData? _portfolioData;
  final List<ProductHolding> _holdings = [];
  SpotPriceData? _spotPrices;
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _errorMessage;
  String? frequency;

  PortfolioData? get portfolioData => _portfolioData;
  List<ProductHolding> get holdings => _holdings;
  SpotPriceData? get spotPrices => _spotPrices;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;

  // Load Portfolio Data (Now uses real API calls)
  Future<void> loadPortfolioData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch Spot Prices and Customer Portfolio Data in Parallel
      final spotPricesFuture = PortfolioService.fetchSpotPrices();
      final portfolioFuture = PortfolioService.fetchCustomerPortfolio(0, '3M');

      final results = await Future.wait([spotPricesFuture, portfolioFuture]);

      // Log the spot price response for debugging
      if (kDebugMode) {
        print('Fetched Spot Prices: ${results[0]}');
      }

      // Ensure the results are the correct type
      final spotPrices = results[0];
      final portfolioData = results[1];

      // Check if spotPrices is valid
      if (spotPrices is SpotPriceData) {
        _spotPrices = spotPrices;
      } else {
        throw Exception('Invalid Spot Prices Data Format');
      }

      // Check if portfolioData is valid
      if (portfolioData is PortfolioData) {
        // Check for 'success' flag and handle null arrays
        if (portfolioData.success == true) {
          // If the arrays are not null, process as normal
          _portfolioData = portfolioData;
          _errorMessage = null;
        } else {
          _errorMessage = 'Invalid data format';
          print('Error: Invalid data format in portfolio data');
        }
      } else {
        _errorMessage = 'Invalid data format for Portfolio Data';
        print('Error: Invalid portfolio data format');
      }
    } catch (e) {
      _errorMessage = 'Failed to load data: ${e.toString()}';
      if (kDebugMode) {
        print('Error loading data: $e');
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  void updatePortfolioData(PortfolioData data) {
    _portfolioData = data;
    notifyListeners(); // Notify UI to rebuild
  }

  // Refresh Data from APIs
  Future<void> refreshDataFromAPIs(frequency) async {
    _isRefreshing = true;
    notifyListeners();

    try {
      final spotPricesFuture = PortfolioService.fetchSpotPrices();
      final portfolioFuture = PortfolioService.fetchCustomerPortfolio(
        0,
        frequency,
      );

      final results = await Future.wait([spotPricesFuture, portfolioFuture]);

      // Log the spot price response for debugging
      if (kDebugMode) {
        print('Refreshed Spot Prices: ${results[0]}');
      }

      // Ensure the results are the correct type
      final spotPrices = results[0];
      final portfolioData = results[1];

      if (spotPrices is SpotPriceData && portfolioData is PortfolioData) {
        _spotPrices = spotPrices;
        _portfolioData = portfolioData;
        _errorMessage = null;
      } else {
        _errorMessage = 'Invalid data format';
        print('Error: Invalid data format');
      }
    } catch (e) {
      _errorMessage = 'Failed to refresh data: ${e.toString()}';
      if (kDebugMode) {
        print('Error refreshing data: $e');
      }
    }

    _isRefreshing = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
