import 'package:flutter/foundation.dart';
import '../models/portfolio_model.dart';
import '../services/portfolio_service.dart';

class PortfolioProvider with ChangeNotifier {
  PortfolioData? _portfolioData;
  List<Holding> _holdings = [];
  bool _isLoading = false;
  String? _errorMessage;

  PortfolioData? get portfolioData => _portfolioData;
  List<Holding> get holdings => _holdings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadPortfolioData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _portfolioData = PortfolioService.getMockPortfolioData();
      _holdings = PortfolioService.getMockHoldings();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
