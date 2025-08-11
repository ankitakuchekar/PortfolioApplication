class SpotPriceData {
  final double silverAsk;
  final double goldAsk;
  final double silverChange;
  final double goldChange;
  final double silverChangePercent;
  final double goldChangePercent;

  SpotPriceData({
    required this.silverAsk,
    required this.goldAsk,
    required this.silverChange,
    required this.goldChange,
    required this.silverChangePercent,
    required this.goldChangePercent,
  });

  factory SpotPriceData.fromJson(Map<String, dynamic> json) {
    return SpotPriceData(
      silverAsk: (json['silverAsk'] ?? 0.0).toDouble(),
      goldAsk: (json['goldAsk'] ?? 0.0).toDouble(),
      silverChange: (json['silverChange'] ?? 0.0).toDouble(),
      goldChange: (json['goldChange'] ?? 0.0).toDouble(),
      silverChangePercent: (json['silverChangePercent'] ?? 0.0).toDouble(),
      goldChangePercent: (json['goldChangePercent'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'silverAsk': silverAsk,
      'goldAsk': goldAsk,
      'silverChange': silverChange,
      'goldChange': goldChange,
      'silverChangePercent': silverChangePercent,
      'goldChangePercent': goldChangePercent,
    };
  }
}
