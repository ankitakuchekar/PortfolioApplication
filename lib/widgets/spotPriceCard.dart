import 'package:bold_portfolio/models/spot_price_model.dart';
import 'package:bold_portfolio/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:bold_portfolio/services/portfolio_service.dart'; // your API service
import 'dart:async';

import 'package:intl/intl.dart';

const snapYellow = Color.fromARGB(255, 220, 166, 2);

class SpotPriceCard extends StatefulWidget {
  final String metal; // "Gold", "Silver", "Platinum", "Palladium"
  final ValueChanged<SpotData> onSpotPriceUpdated;

  const SpotPriceCard({
    super.key,
    required this.metal,
    required this.onSpotPriceUpdated,
  });

  @override
  State<SpotPriceCard> createState() => _SpotPriceCardState();
}

class _SpotPriceCardState extends State<SpotPriceCard> {
  late SpotData spotPrice;
  bool loading = true;
  late Timer _timer;
  bool errorOccurred = false;

  @override
  void initState() {
    super.initState();
    _fetchSpotPrice();
    _startPeriodicRefresh();
  }

  // Method to start the periodic refresh every 45 seconds
  void _startPeriodicRefresh() {
    _timer = Timer.periodic(Duration(seconds: 45), (timer) {
      _fetchSpotPrice();
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed to avoid memory leaks
    _timer.cancel();
    super.dispose();
  }

  Future<void> _fetchSpotPrice() async {
    try {
      final SpotPriceData data = await PortfolioService.fetchSpotPrices();
      print("Spot Price Data: $data");
      setState(() {
        spotPrice = data.data;
        loading = false;
        errorOccurred = false; // Reset error state
      });
      widget.onSpotPriceUpdated(spotPrice);
    } catch (e) {
      setState(() {
        loading = false;
        errorOccurred = true; // Set error state when fetching fails
      });
      print("Error fetching spot price: $e");
    }
  }

  // Replace loading spinner with skeleton
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1️⃣ Main Spot Price Skeleton
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title skeleton
                Container(width: 150, height: 24, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                // Price skeleton
                Container(width: 200, height: 32, color: Colors.grey.shade300),
                const SizedBox(height: 8),
                Container(width: 120, height: 20, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                // Linear progress skeleton
                Container(
                  width: double.infinity,
                  height: 8,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 60,
                      height: 16,
                      color: Colors.grey.shade300,
                    ),
                    Container(
                      width: 60,
                      height: 16,
                      color: Colors.grey.shade300,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 2️⃣ Gram & Kilo small card skeletons
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    if (errorOccurred) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text.rich(
              TextSpan(
                text:
                    'No internet connection', // First part of the message (bold)
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.error, // Set color for error message
                ),
                children: [
                  TextSpan(
                    text:
                        '\nPlease check your network connection and try again.',
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      color: AppColors
                          .error, // Keep the same error color for the second part
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  loading = true;
                  errorOccurred = false;
                });
                _fetchSpotPrice(); // Retry fetching data
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // ---------------- REAL CONTENT ----------------
    // Extract metal data
    late double ounce,
        gram,
        kg,
        changeOunce,
        changeGram,
        changeKg,
        changePercent;
    late double lowSpot, highSpot;

    switch (widget.metal) {
      case "Silver":
        ounce = spotPrice.silverAsk;
        changeOunce = spotPrice.silverChange;
        changePercent = spotPrice.silverChangePercent;
        lowSpot = spotPrice.silverlowspot;
        highSpot = spotPrice.silverhighspot;
        break;
      case "Gold":
        ounce = spotPrice.goldAsk;
        changeOunce = spotPrice.goldChange;
        changePercent = spotPrice.goldChangePercent;
        lowSpot = spotPrice.goldlowspot;
        highSpot = spotPrice.goldhighspot;
        break;
      case "Platinum":
        ounce = spotPrice.platinumAsk;
        changeOunce = spotPrice.platinumChange;
        changePercent = spotPrice.platinumChangePercent;
        lowSpot = spotPrice.platinumlowspot;
        highSpot = spotPrice.platinumhighspot;
        break;
      case "Palladium":
        ounce = spotPrice.palladiumAsk;
        changeOunce = spotPrice.palladiumChange;
        changePercent = spotPrice.palladiumChangePercent;
        lowSpot = spotPrice.palladiumlowspot;
        highSpot = spotPrice.palladiumhighspot;
        break;
      default:
        ounce = 0;
        changeOunce = 0;
        changePercent = 0;
        lowSpot = 0;
        highSpot = 0;
    }

    gram = ounce / 31.1;
    kg = gram * 1000;
    changeGram = changeOunce / 31.1;
    changeKg = changeGram * 1000;

    final range = (highSpot - lowSpot).abs().clamp(0.001, double.infinity);
    final boundedPosition = (((ounce - lowSpot) / range).clamp(0, 1) as double);

    Color changeColor = changeOunce >= 0 ? Colors.green : Colors.red;
    Icon changeIcon = changeOunce >= 0
        ? const Icon(Icons.arrow_drop_up, color: Colors.green)
        : const Icon(Icons.arrow_drop_down, color: Colors.red);

    final currencyFormat = NumberFormat("#,##0.00", "en_US");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1️⃣ Main Spot Price Container
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${widget.metal} Spot Price",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "\$${currencyFormat.format(ounce)}",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      changeIcon,
                      Text(
                        "${currencyFormat.format(changeOunce.abs())} ($changePercent%)",
                        style: TextStyle(
                          color: changeColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                "Price per troy ounce",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              const Text("Today's Range"),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: boundedPosition,
                color: widget.metal == 'Silver'
                    ? Colors.grey.shade700
                    : snapYellow,
                backgroundColor: Colors.grey.shade300,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("\$${currencyFormat.format(lowSpot)}"),
                  Text("\$${currencyFormat.format(highSpot)}"),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 2️⃣ Small Cards
        Row(
          children: [
            _smallCard("Gram", gram, changeGram),
            const SizedBox(width: 16),
            _smallCard("Kilo", kg, changeKg),
          ],
        ),
      ],
    );
  }

  Widget _smallCard(String title, double value, double change) {
    Color changeColor = change >= 0 ? Colors.green : Colors.red;
    Icon changeIcon = change >= 0
        ? const Icon(Icons.arrow_drop_up, color: Colors.green)
        : const Icon(Icons.arrow_drop_down, color: Colors.red);

    final currencyFormat = NumberFormat("#,##0.00", "en_US");

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),

            // Value
            Text(
              "\$${currencyFormat.format(value)}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),

            // Change with icon
            Row(
              children: [
                changeIcon,
                const SizedBox(width: 4),
                Text(
                  "${change.abs().toStringAsFixed(2)}%",
                  style: TextStyle(
                    color: changeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
