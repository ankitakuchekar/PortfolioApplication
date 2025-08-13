import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/portfolio_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/circular_timer_widget.dart';
import '../widgets/asset_allocation_section.dart';
import '../widgets/profit_loss_cards.dart';
import '../widgets/value_cost_cards.dart';
import '../widgets/metal_portfolio_section.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PortfolioProvider>(
        context,
        listen: false,
      ).loadPortfolioData();
    });
  }

  void _onTimerComplete() {
    Provider.of<PortfolioProvider>(
      context,
      listen: false,
    ).refreshDataFromAPIs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Portfolio'),
        backgroundColor: AppColors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircularTimerWidget(
              durationSeconds: 45,
              onTimerComplete: _onTimerComplete,
            ),
          ),
        ],
      ),
      body: Consumer<PortfolioProvider>(
        builder: (context, portfolioProvider, child) {
          if (portfolioProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (portfolioProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    portfolioProvider.errorMessage!,
                    style: const TextStyle(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => portfolioProvider.loadPortfolioData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final portfolioData = portfolioProvider.portfolioData;
          if (portfolioData == null) {
            return const Center(child: Text('No data available'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<PortfolioProvider>(
                  builder: (context, provider, child) {
                    final spotPriceData = provider.spotPrices;
                    if (spotPriceData == null) {
                      return const Center(child: Text('No data available'));
                    }
                    return AssetAllocationSection(spotPrices: spotPriceData);
                  },
                ),
                const SizedBox(height: 16),
                ProfitLossCards(portfolioData: portfolioData),
                const SizedBox(height: 16),
                ValueCostCards(portfolioData: portfolioData),
                const SizedBox(height: 16),
                MetalPortfolioSection(
                  portfolioData: portfolioData,
                  metalType: "Silver",
                ),
                const SizedBox(height: 16),
                MetalPortfolioSection(
                  portfolioData: portfolioData,
                  metalType: "Gold",
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
