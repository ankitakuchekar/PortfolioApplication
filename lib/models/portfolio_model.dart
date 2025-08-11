import 'spot_price_model.dart';

class PortfolioData {
  final double totalInvestment;
  final double currentValue;
  final double totalProfitLoss;
  final double totalProfitLossPercentage;
  final double dayProfitLoss;
  final double dayProfitLossPercentage;
  final MetalData silver;
  final MetalData gold;
  final List<ChartData> chartData;
  final SpotPriceData? spotPrices;

  PortfolioData({
    required this.totalInvestment,
    required this.currentValue,
    required this.totalProfitLoss,
    required this.totalProfitLossPercentage,
    required this.dayProfitLoss,
    required this.dayProfitLossPercentage,
    required this.silver,
    required this.gold,
    required this.chartData,
    this.spotPrices,
  });
}

class MetalData {
  final String name;
  final double value;
  final double ounces;
  final double profit;
  final double profitPercentage;

  MetalData({
    required this.name,
    required this.value,
    required this.ounces,
    required this.profit,
    required this.profitPercentage,
  });
}

class ChartData {
  final DateTime date;
  final double value;

  ChartData({
    required this.date,
    required this.value,
  });
}

class Holding {
  final String id;
  final String name;
  final String type;
  final double quantity;
  final double purchasePrice;
  final double currentPrice;
  final double profit;
  final double profitPercentage;

  Holding({
    required this.id,
    required this.name,
    required this.type,
    required this.quantity,
    required this.purchasePrice,
    required this.currentPrice,
    required this.profit,
    required this.profitPercentage,
  });
}
