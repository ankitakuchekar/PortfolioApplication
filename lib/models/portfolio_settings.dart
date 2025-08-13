// models/portfolio_settings.dart
class PortfolioSettings {
  final bool showActualPrice;
  final bool showPrediction;
  final bool showVdo;
  final bool doNotShowAgain;
  final bool showGoldPrediction;
  final bool showSilverPrediction;
  final bool showTotalPrediction;

  PortfolioSettings({
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
      showActualPrice: json['showActualPrice'],
      showPrediction: json['showPrediction'],
      showVdo: json['showVdo'],
      doNotShowAgain: json['doNotShowAgain'],
      showGoldPrediction: json['showGoldPrediction'],
      showSilverPrediction: json['showSilverPrediction'],
      showTotalPrediction: json['showTotalPrediction'],
    );
  }
}
