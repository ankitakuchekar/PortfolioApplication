import 'package:bold_portfolio/models/portfolio_model.dart';
import 'package:bold_portfolio/widgets/CandlestickChartWidget.dart';
import 'package:flutter/material.dart';

class CandleChartLandscapeScreen extends StatelessWidget {
  final List<MetalCandleChartEntry> candleChartData;
  final String selectedMetal;

  const CandleChartLandscapeScreen({
    super.key,
    required this.candleChartData,
    required this.selectedMetal,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            MetalCandleChart(
              candleChartData: candleChartData,
              selectedMetal: selectedMetal,
              showCombined: selectedMetal == 'All',
            ),

            // 👇 Exit landscape button
            Positioned(
              top: 10,
              left: 402,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
