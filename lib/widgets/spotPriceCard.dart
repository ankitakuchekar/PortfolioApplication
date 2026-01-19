import 'package:bold_portfolio/models/spot_price_model.dart';
import 'package:flutter/material.dart';
import 'package:bold_portfolio/services/portfolio_service.dart'; // your API service
import 'dart:async';

import 'package:intl/intl.dart';

const snapYellow = Color.fromARGB(255, 220, 166, 2);

class SpotPriceCard extends StatefulWidget {
  final String metal; // "Gold", "Silver", "Platinum", "Palladium"

  const SpotPriceCard({super.key, required this.metal});

  @override
  State<SpotPriceCard> createState() => _SpotPriceCardState();
}

class _SpotPriceCardState extends State<SpotPriceCard> {
  late SpotData spotPrice;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchSpotPrice();
  }

  Future<void> _fetchSpotPrice() async {
    final SpotPriceData data = await PortfolioService.fetchSpotPrices();
    print("Spot Price Data: $data");
    setState(() {
      spotPrice = data.data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

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

    // Calculate bounded position for progress bar
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
                color: snapYellow,
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

        // 2️⃣ New Column for Small Cards
        Column(
          children: [
            Row(
              children: [
                _smallCard("Gram", gram, changeGram),
                const SizedBox(width: 16),
                _smallCard("Kilo", kg, changeKg),
              ],
            ),
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
