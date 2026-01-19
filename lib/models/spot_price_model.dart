class SpotPriceData {
  final bool success;
  final SpotData data;
  final String dataFrom;

  SpotPriceData({
    required this.success,
    required this.data,
    required this.dataFrom,
  });

  factory SpotPriceData.fromJson(Map<String, dynamic> json) {
    return SpotPriceData(
      success: json['success'],
      data: SpotData.fromJson(json['data']),
      dataFrom: json['dataFrom'],
    );
  }
}

class SpotData {
  final String timestamp;
  final String spotTime;
  final double goldAsk;
  final double goldBid;
  final double goldChange;
  final double goldChangePercent;
  final double silverAsk;
  final double silverBid;
  final double silverChange;
  final double silverChangePercent;
  final double platinumAsk;
  final double platinumBid;
  final double platinumChange;
  final double platinumChangePercent;
  final double palladiumAsk;
  final double palladiumBid;
  final double palladiumChange;
  final double palladiumChangePercent;
  final double silverlowspot;
  final double silverhighspot;
  final double goldlowspot;
  final double goldhighspot;
  final double platinumlowspot;
  final double palladiumhighspot;
  final double palladiumlowspot;
  final double platinumhighspot;
  SpotData({
    required this.timestamp,
    required this.spotTime,
    required this.goldAsk,
    required this.goldBid,
    required this.goldChange,
    required this.goldChangePercent,
    required this.silverAsk,
    required this.silverBid,
    required this.silverChange,
    required this.silverChangePercent,
    required this.platinumAsk,
    required this.platinumBid,
    required this.platinumChange,
    required this.platinumChangePercent,
    required this.palladiumAsk,
    required this.palladiumBid,
    required this.palladiumChange,
    required this.palladiumChangePercent,
    required this.silverlowspot,
    required this.silverhighspot,
    required this.goldlowspot,
    required this.goldhighspot,
    required this.platinumlowspot,
    required this.platinumhighspot,
    required this.palladiumlowspot,
    required this.palladiumhighspot,
  });

  factory SpotData.fromJson(Map<String, dynamic> json) {
    return SpotData(
      timestamp: json['timestamp'],
      spotTime: json['spotTime'],
      goldAsk: (json['goldAsk'] as num).toDouble(),
      goldBid: (json['goldBid'] as num).toDouble(),
      goldChange: (json['goldChange'] as num).toDouble(),
      goldChangePercent: (json['goldChangePercent'] as num).toDouble(),
      silverAsk: (json['silverAsk'] as num).toDouble(),
      silverBid: (json['silverBid'] as num).toDouble(),
      silverChange: (json['silverChange'] as num).toDouble(),
      silverChangePercent: (json['silverChangePercent'] as num).toDouble(),
      platinumAsk: (json['platinumAsk'] as num).toDouble(),
      platinumBid: (json['platinumBid'] as num).toDouble(),
      platinumChange: (json['platinumChange'] as num).toDouble(),
      platinumChangePercent: (json['platinumChangePercent'] as num).toDouble(),
      palladiumAsk: (json['palladiumAsk'] as num).toDouble(),
      palladiumBid: (json['palladiumBid'] as num).toDouble(),
      palladiumChange: (json['palladiumChange'] as num).toDouble(),
      palladiumChangePercent: (json['palladiumChangePercent'] as num)
          .toDouble(),
      silverlowspot: (json['silverlowspot'] as num).toDouble(),
      silverhighspot: (json['silverhighspot'] as num).toDouble(),
      goldlowspot: (json['goldlowspot'] as num).toDouble(),
      goldhighspot: (json['goldhighspot'] as num).toDouble(),
      platinumlowspot: (json['platinumlowspot'] as num).toDouble(),
      platinumhighspot: (json['platinumhighspot'] as num).toDouble(),
      palladiumlowspot: (json['palladiumlowspot'] as num).toDouble(),
      palladiumhighspot: (json['palladiumhighspot'] as num).toDouble(),
    );
  }
}
