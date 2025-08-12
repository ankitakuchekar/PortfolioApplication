class PortfolioData {
  final bool success;
  final CustomerData data;

  PortfolioData({required this.success, required this.data});

  // Computed getters for backward compatibility with UI components
  double get totalInvestment => data.investment.totalGoldInvested + data.investment.totalSilverInvested;
  double get currentValue => data.investment.totalGoldCurrent + data.investment.totalSilverCurrent;
  double get totalProfitLoss => currentValue - totalInvestment;
  double get totalProfitLossPercentage => totalInvestment > 0 ? (totalProfitLoss / totalInvestment) * 100 : 0.0;
  double get dayProfitLoss => data.investment.dayGold + data.investment.daySilver;
  double get dayProfitLossPercentage => data.investment.dayChangePercentage;

  // Metal data getters for backward compatibility
  MetalData get silver => MetalData(
    name: 'Silver',
    value: data.investment.totalSilverCurrent,
    ounces: data.investment.totalSilverOunces,
    profit: data.investment.totalSilverCurrent - data.investment.totalSilverInvested,
    profitPercentage: data.investment.totalSilverInvested > 0 
        ? ((data.investment.totalSilverCurrent - data.investment.totalSilverInvested) / data.investment.totalSilverInvested) * 100 
        : 0.0,
  );

  MetalData get gold => MetalData(
    name: 'Gold',
    value: data.investment.totalGoldCurrent,
    ounces: data.investment.totalGoldOunces,
    profit: data.investment.totalGoldCurrent - data.investment.totalGoldInvested,
    profitPercentage: data.investment.totalGoldInvested > 0 
        ? ((data.investment.totalGoldCurrent - data.investment.totalGoldInvested) / data.investment.totalGoldInvested) * 100 
        : 0.0,
  );

  factory PortfolioData.fromJson(Map<String, dynamic> json) {
    // Handle if 'data' is a List or Map
    var dataJson = json['data'];

    // If 'data' is a List, we are assuming the first item contains the needed data
    if (dataJson is List && dataJson.isNotEmpty) {
      dataJson = dataJson[0];
    }

    return PortfolioData(
      success: json['success'],
      data: CustomerData.fromJson(dataJson),
    );
  }
}

class CustomerData {
  final InvestmentData investment;
  // final MetalCandleCart metalCandleCart;
  // final MetalInOunces metalInOunces;
  // final PortFolioSetting portFolioSetting;
  // final ProductsForPortfolio productsForPortfolio;

  CustomerData({
    required this.investment,
    // required this.metalCandleCart,
    // required this.metalInOunces,
    // required this.portFolioSetting,
    // required this.productsForPortfolio,
  });

  factory CustomerData.fromJson(Map<String, dynamic> json) {
    return CustomerData(
      investment: InvestmentData.fromJson(json['investment']),
      // metalCandleCart: MetalCandleCart.fromJson(json['metalCandleCart']),
      // metalInOunces: MetalInOunces.fromJson(json['metalInOunces']),
      // portFolioSetting: PortFolioSetting.fromJson(json['portFolioSetting']),
      // productsForPortfolio: ProductsForPortfolio.fromJson(json['productsForPortfolio']),
    );
  }
}

class InvestmentData {
  final double customerId;
  final double dayChangePercentage;
  final double totalGold;
  final double totalSilver;
  final double totalGoldCurrent;
  final double totalGoldInvested;
  final double totalGoldOunces;
  final double totalSilverCurrent;
  final double totalSilverInvestment;
  final double totalSilverOunces;
  final double totalSilverInvested;
  final double dayGold;
  final double daySilver;

  InvestmentData({
    required this.customerId,
    required this.dayChangePercentage,
    required this.totalGold,
    required this.totalSilver,
    required this.totalGoldCurrent,
    required this.totalGoldInvested,
    required this.totalGoldOunces,
    required this.totalSilverCurrent,
    required this.totalSilverInvestment,
    required this.totalSilverOunces,
    required this.totalSilverInvested,
    required this.dayGold,
    required this.daySilver,
  });

  factory InvestmentData.fromJson(Map<String, dynamic> json) {
    return InvestmentData(
      customerId: json['customerId']?.toDouble() ?? 0.0,
      dayChangePercentage: json['dayChangePercentage']?.toDouble() ?? 0.0,
      totalGold: json['totalGold']?.toDouble() ?? 0.0,
      totalSilver: json['totalSilver']?.toDouble() ?? 0.0,
      totalGoldCurrent: json['totalGoldCurrent']?.toDouble() ?? 0.0,
      totalGoldInvested: json['totalGoldInvested']?.toDouble() ?? 0.0,
      totalGoldOunces: json['totalGoldOunces']?.toDouble() ?? 0.0,
      totalSilverCurrent: json['totalSilverCurrent']?.toDouble() ?? 0.0,
      totalSilverInvestment: json['totalSilverInvestment']?.toDouble() ?? 0.0,
      totalSilverOunces: json['totalSilverOunces']?.toDouble() ?? 0.0,
      totalSilverInvested: json['totalSilverInvested']?.toDouble() ?? 0.0,
      dayGold: json['dayGold']?.toDouble() ?? 0.0,
      daySilver: json['daySilver']?.toDouble() ?? 0.0,
    );
  }
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
