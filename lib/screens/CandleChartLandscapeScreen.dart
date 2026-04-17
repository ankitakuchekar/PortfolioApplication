import 'package:bold_portfolio/models/portfolio_model.dart';
import 'package:bold_portfolio/providers/portfolio_provider.dart';
import 'package:bold_portfolio/widgets/CandlestickChartWidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CandleChartLandscapeScreen extends StatefulWidget {
  final String initialMetal;

  const CandleChartLandscapeScreen({super.key, required this.initialMetal});

  @override
  State<CandleChartLandscapeScreen> createState() =>
      _CandleChartLandscapeScreenState();
}

class _CandleChartLandscapeScreenState
    extends State<CandleChartLandscapeScreen> {
  late String metalFilter;

  @override
  void initState() {
    super.initState();
    metalFilter = widget.initialMetal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<PortfolioProvider>(
        builder: (context, portfolioProvider, _) {
          final metalCandleChartData =
              portfolioProvider.portfolioData?.data[0].metalCandleChart ?? [];

          return SafeArea(
            child: Stack(
              children: [
                // ── Chart fills the entire screen (has its own title, zoom, filters) ──
                Positioned.fill(
                  child: MetalCandleChart(
                    candleChartData: metalCandleChartData,
                    selectedMetal: metalFilter,
                    showCombined: metalFilter == 'All',
                  ),
                ),

                // ── Close button centered at the top ──────────────────────
                Positioned(
                  top: 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
