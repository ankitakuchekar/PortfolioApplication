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
  // ... (other fields)

  CustomerData({required this.investment});

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

    return CustomerData(
      investment: investmentData,
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
