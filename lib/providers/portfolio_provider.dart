import 'package:flutter/foundation.dart';
import '../models/portfolio_model.dart';
import '../models/spot_price_model.dart';
import '../services/portfolio_service.dart';

class PortfolioProvider with ChangeNotifier {
  PortfolioData? _portfolioData;
  List<Holding> _holdings = [];
  SpotPriceData? _spotPrices;
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _errorMessage;

  PortfolioData? get portfolioData => _portfolioData;
  List<Holding> get holdings => _holdings;
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
      final portfolioFuture = PortfolioService.fetchCustomerPortfolio(
        0,
      ); // Replace with actual customerId if needed

      final results = await Future.wait([spotPricesFuture, portfolioFuture]);

      // Log the spot price response for debugging
      if (kDebugMode) {
        print('Fetched Spot Prices: ${results[0]}');
      }

      // Assign spot prices and portfolio data
      _spotPrices = results[0] as SpotPriceData;
      final newPortfolioData = results[1] as PortfolioData;

      _portfolioData = PortfolioData(
        totalInvestment: newPortfolioData.totalInvestment,
        currentValue: newPortfolioData.currentValue,
        totalProfitLoss: newPortfolioData.totalProfitLoss,
        totalProfitLossPercentage: newPortfolioData.totalProfitLossPercentage,
        dayProfitLoss: newPortfolioData.dayProfitLoss,
        dayProfitLossPercentage: newPortfolioData.dayProfitLossPercentage,
        silver: newPortfolioData.silver,
        gold: newPortfolioData.gold,
        chartData: newPortfolioData.chartData,
        spotPrices: _spotPrices, // Store fetched spot price data
      );

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load data: ${e.toString()}';
      if (kDebugMode) {
        print('Error loading data: $e');
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  // Refresh Data from APIs
  Future<void> refreshDataFromAPIs() async {
    _isRefreshing = true;
    notifyListeners();

    try {
      final spotPricesFuture = PortfolioService.fetchSpotPrices();
      final portfolioFuture = PortfolioService.fetchCustomerPortfolio(
        0,
      ); // Replace with actual customerId if needed

      final results = await Future.wait([spotPricesFuture, portfolioFuture]);

      // Log the spot price response for debugging
      if (kDebugMode) {
        print('Refreshed Spot Prices: ${results[0]}');
      }

      // Assign spot prices and portfolio data
      _spotPrices = results[0] as SpotPriceData;
      final newPortfolioData = results[1] as PortfolioData;

      _portfolioData = PortfolioData(
        totalInvestment: newPortfolioData.totalInvestment,
        currentValue: newPortfolioData.currentValue,
        totalProfitLoss: newPortfolioData.totalProfitLoss,
        totalProfitLossPercentage: newPortfolioData.totalProfitLossPercentage,
        dayProfitLoss: newPortfolioData.dayProfitLoss,
        dayProfitLossPercentage: newPortfolioData.dayProfitLossPercentage,
        silver: newPortfolioData.silver,
        gold: newPortfolioData.gold,
        chartData: newPortfolioData.chartData,
        spotPrices: _spotPrices, // Store fetched spot price data
      );

      _errorMessage = null;
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
