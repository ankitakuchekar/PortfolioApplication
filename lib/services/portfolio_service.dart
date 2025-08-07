import '../models/portfolio_model.dart';

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
}
