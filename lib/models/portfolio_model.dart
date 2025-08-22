import 'package:intl/intl.dart';

class PortfolioData {
  final bool success;
  final List<CustomerData> data;

  PortfolioData({required this.success, required this.data});

  // Access the first CustomerData object from the list
  CustomerData get customerData =>
      data.isNotEmpty ? data[0] : throw Exception('CustomerData list is empty');

  // Computed getters for backward compatibility with UI components
  double get totalInvestment =>
      customerData.investment.totalGoldInvested +
      customerData.investment.totalSilverInvested;
  double get currentValue =>
      customerData.investment.totalGoldCurrent +
      customerData.investment.totalSilverCurrent;
  double get totalProfitLoss => currentValue - totalInvestment;
  double get totalProfitLossPercentage =>
      totalInvestment > 0 ? (totalProfitLoss / totalInvestment) * 100 : 0.0;
  double get dayProfitLoss =>
      customerData.investment.dayGold + customerData.investment.daySilver;
  double get dayProfitLossPercentage =>
      customerData.investment.dayChangePercentage;

  // Metal data getters for backward compatibility
  MetalData get silver => MetalData(
    name: 'Silver',
    value: customerData.investment.totalSilverCurrent,
    ounces: customerData.investment.totalSilverOunces,
    profit:
        customerData.investment.totalSilverCurrent -
        customerData.investment.totalSilverInvested,
    profitPercentage: customerData.investment.totalSilverInvested > 0
        ? ((customerData.investment.totalSilverCurrent -
                      customerData.investment.totalSilverInvested) /
                  customerData.investment.totalSilverInvested) *
              100
        : 0.0,
  );

  MetalData get gold => MetalData(
    name: 'Gold',
    value: customerData.investment.totalGoldCurrent,
    ounces: customerData.investment.totalGoldOunces,
    profit:
        customerData.investment.totalGoldCurrent -
        customerData.investment.totalGoldInvested,
    profitPercentage: customerData.investment.totalGoldInvested > 0
        ? ((customerData.investment.totalGoldCurrent -
                      customerData.investment.totalGoldInvested) /
                  customerData.investment.totalGoldInvested) *
              100
        : 0.0,
  );

  factory PortfolioData.fromJson(Map<String, dynamic> json) {
    // The top-level 'data' field is a map, not a list.
    // The lists are inside the 'data' map.
    var rawData = json['data'];

    // For simplicity, we'll assume there's only one customer and one investment record.
    return PortfolioData(
      success: json['success'],
      data: [CustomerData.fromJson(rawData)],
    );
  }
}

class CustomerData {
  final InvestmentData investment;
  final PortfolioSettings portfolioSettings;
  final List<MetalCandleChartEntry> metalCandleChart;
  final List<ProductHolding> productHoldings;
  final List<MetalInOunces> metalInOunces;
  // ... (other fields)

  CustomerData({
    required this.investment,
    required this.portfolioSettings,
    required this.metalCandleChart,
    required this.productHoldings,
    required this.metalInOunces,
  });

  factory CustomerData.fromJson(Map<String, dynamic> json) {
    // Corrected logic to handle 'investment' as a list and get the first item
    final investmentList = json['investment'] as List<dynamic>;
    final investmentData = investmentList.isNotEmpty
        ? InvestmentData.fromJson(investmentList[0] as Map<String, dynamic>)
        : null;

    if (investmentData == null) {
      throw Exception(
        'Investment data is missing or empty in the API response.',
      );
    }

    final portfolioSettingsList = json['portfolioSettings'] as List<dynamic>;
    final portfolioSettingsData = portfolioSettingsList.isNotEmpty
        ? PortfolioSettings.fromJson(
            portfolioSettingsList[0] as Map<String, dynamic>,
          )
        : throw Exception('portfolioSettings is missing');

    final chartList = json['metalCandleChart'] as List<dynamic>? ?? [];
    final metalCandleChartData = chartList
        .map((item) => MetalCandleChartEntry.fromJson(item))
        .toList();

    final productHoldingsJson =
        json['productsForPortfolio'] as List<dynamic>? ?? [];
    final productHoldings = productHoldingsJson
        .map((item) => ProductHolding.fromJson(item))
        .toList();

    final metalOuncesJson = json['metalInounces'] as List<dynamic>? ?? [];
    final metalInOunces = metalOuncesJson
        .map((item) => MetalInOunces.fromJson(item))
        .toList();

    return CustomerData(
      investment: investmentData,
      portfolioSettings: portfolioSettingsData,
      metalCandleChart: metalCandleChartData,
      productHoldings: productHoldings,
      metalInOunces: metalInOunces,
      // Uncomment and correct the parsing for other fields as needed
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

class PortfolioSettings {
  final int customerId;
  final bool showActualPrice;
  final bool showPrediction;
  final bool showVdo;
  final bool doNotShowAgain;
  final bool showGoldPrediction;
  final bool showSilverPrediction;
  final bool showTotalPrediction;

  PortfolioSettings({
    required this.customerId,
    required this.showActualPrice,
    required this.showPrediction,
    required this.showVdo,
    required this.doNotShowAgain,
    required this.showGoldPrediction,
    required this.showSilverPrediction,
    required this.showTotalPrediction,
  });

  factory PortfolioSettings.fromJson(Map<String, dynamic> json) {
    return PortfolioSettings(
      customerId: json['customerId'] ?? 0,
      showActualPrice: json['showActualPrice'] ?? false,
      showPrediction: json['showPrediction'] ?? false,
      showVdo: json['showVdo'] ?? false,
      doNotShowAgain: json['doNotShowAgain'] ?? false,
      showGoldPrediction: json['showGoldPrediction'] ?? false,
      showSilverPrediction: json['showSilverPrediction'] ?? false,
      showTotalPrediction: json['showTotalPrediction'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'showActualPrice': showActualPrice,
      'showPrediction': showPrediction,
      'showVdo': showVdo,
      'doNotShowAgain': doNotShowAgain,
      'showGoldPrediction': showGoldPrediction,
      'showSilverPrediction': showSilverPrediction,
      'showTotalPrediction': showTotalPrediction,
    };
  }
}

class MetalCandleChartEntry {
  final DateTime intervalStart;
  final double openGold;
  final double closeGold;
  final double highGold;
  final double lowGold;
  final double openSilver;
  final double closeSilver;
  final double highSilver;
  final double lowSilver;
  final double openMetal;
  final double closeMetal;
  final double highMetal;
  final double lowMetal;

  MetalCandleChartEntry({
    required this.intervalStart,
    required this.openGold,
    required this.closeGold,
    required this.highGold,
    required this.lowGold,
    required this.openSilver,
    required this.closeSilver,
    required this.highSilver,
    required this.lowSilver,
    required this.openMetal,
    required this.closeMetal,
    required this.highMetal,
    required this.lowMetal,
  });

  factory MetalCandleChartEntry.fromJson(Map<String, dynamic> json) {
    return MetalCandleChartEntry(
      intervalStart: json['intervalStart'] != null
          ? DateTime.parse(json['intervalStart'])
          : DateTime.now(),
      openGold: (json['openGold'] ?? 0).toDouble(),
      closeGold: (json['closeGold'] ?? 0).toDouble(),
      highGold: (json['highGold'] ?? 0).toDouble(),
      lowGold: (json['lowGold'] ?? 0).toDouble(),
      openSilver: (json['openSilver'] ?? 0).toDouble(),
      closeSilver: (json['closeSilver'] ?? 0).toDouble(),
      highSilver: (json['highSilver'] ?? 0).toDouble(),
      lowSilver: (json['lowSilver'] ?? 0).toDouble(),
      openMetal: (json['openMetal'] ?? 0).toDouble(),
      closeMetal: (json['closeMetal'] ?? 0).toDouble(),
      highMetal: (json['highMetal'] ?? 0).toDouble(),
      lowMetal: (json['lowMetal'] ?? 0).toDouble(),
    );
  }
}

class MetalInOunces {
  final DateTime orderDate;
  final double totalGoldOptimalPrediction;
  final double totalGoldOunces;
  final double totalGoldWorstPrediction;
  final double totalOunces;
  final double totalSilverOptimalPrediction;
  final double totalSilverOunces;
  final double totalSilverWorstPrediction;
  final String type;

  MetalInOunces(
    this.orderDate,
    this.totalGoldOptimalPrediction,
    this.totalGoldOunces,
    this.totalGoldWorstPrediction,
    this.totalOunces,
    this.totalSilverOptimalPrediction,
    this.totalSilverOunces,
    this.totalSilverWorstPrediction,
    this.type,
  );

  factory MetalInOunces.fromJson(Map<String, dynamic> json) {
    final dateFormat = DateFormat("MM/dd/yyyy HH:mm:ss");

    return MetalInOunces(
      json['orderDate'] != null
          ? dateFormat.parse(json['orderDate'])
          : DateTime.now(),
      (json['totalGoldOptimalPrediction'] ?? 0).toDouble(),
      (json['totalGoldOunces'] ?? 0).toDouble(),
      (json['totalGoldWorstPrediction'] ?? 0).toDouble(),
      (json['totalOunces'] ?? 0).toDouble(),
      (json['totalSilverOptimalPrediction'] ?? 0).toDouble(),
      (json['totalSilverOunces'] ?? 0).toDouble(),
      (json['totalSilverWorstPrediction'] ?? 0).toDouble(),
      (json['type'] ?? '').toString(),
    );
  }
}

class ProductHolding {
  final int productId;
  final String name;
  final String metal;
  final double weight;
  final double avgPrice;
  final double currentPrice;
  final bool isSold;
  final DateTime orderDate;
  final double currentMetalValue;
  final String productImage;
  final String assetList;
  final int totalQtyOrdered;

  ProductHolding({
    required this.productId,
    required this.name,
    required this.metal,
    required this.weight,
    required this.avgPrice,
    required this.currentPrice,
    required this.isSold,
    required this.orderDate,
    required this.currentMetalValue,
    required this.productImage,
    required this.assetList,
    required this.totalQtyOrdered,
  });

  double get profit => (currentMetalValue - avgPrice) * weight;
  double get profitPercentage =>
      avgPrice > 0 ? ((currentMetalValue - avgPrice) / avgPrice) * 100 : 0;

  factory ProductHolding.fromJson(Map<String, dynamic> json) {
    final dateFormat = DateFormat("MM/dd/yyyy HH:mm:ss");

    return ProductHolding(
      productId: json['productId'],
      name: json['assetList'] ?? '',
      metal: json['metal'] ?? '',
      weight: (json['weight'] ?? 0).toDouble(),
      avgPrice: (json['avgPrice'] ?? 0).toDouble(),
      currentPrice: (json['currentPrice'] ?? 0).toDouble(),
      currentMetalValue: (json['currentMetalValue'] ?? 0).toDouble(),
      isSold: json['isSold'] ?? false,
      orderDate: json['orderDate'] != null
          ? dateFormat.parse(json['orderDate'])
          : DateTime.now(),
      productImage: json['productImage'] ?? '',
      assetList: json['assetList'] ?? '',
      totalQtyOrdered: json['totalQtyOrdered'] ?? 0,
    );
  }
}

class CandleData {
  final DateTime time;
  final double open;
  final double high;
  final double low;
  final double close;

  CandleData({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });
}
