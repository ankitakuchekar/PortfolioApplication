import 'package:bold_portfolio/services/portfolio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/portfolio_model.dart';
import '../providers/portfolio_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/AssetAllocationPie.dart';
import '../widgets/LineChartWidget.dart';

class GraphsScreen extends StatefulWidget {
  const GraphsScreen({super.key});

  @override
  State<GraphsScreen> createState() => _GraphsScreenState();
}

class _GraphsScreenState extends State<GraphsScreen> {
  String selectedTab = 'Asset Allocation';
  String frequency = '3M'; // Default frequency set to '3M'
  bool isLoading = false; // Flag to show loading indicator

  final List<String> tabOptions = [
    'Asset Allocation',
    'Total Holdings',
    'Gold Holdings',
    'Silver Holdings',
  ];

  final List<String> timePeriods = ['1D', '1W', '1M', '3M', '6M', '1Y', '5Y'];

  // Method to fetch the portfolio data when the frequency changes
  Future<void> fetchPortfolioData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final portfolioData = await PortfolioService.fetchCustomerPortfolio(
        0,
        frequency,
      );
      // Update portfolio provider with new data after fetching
      Provider.of<PortfolioProvider>(
        context,
        listen: false,
      ).updatePortfolioData(portfolioData);
    } catch (e) {
      // Handle any errors if the API call fails
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Portfolio Charts'),
        backgroundColor: AppColors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<PortfolioProvider>(
        builder: (context, portfolioProvider, child) {
          final portfolioData = portfolioProvider.portfolioData;

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (portfolioData == null ||
              portfolioData.data.isEmpty ||
              portfolioData.data[0].investment == null) {
            return const Center(child: Text('No data available.'));
          }

          final investment = portfolioData.data[0].investment;

          final totalInvestment =
              investment.totalGoldInvested + investment.totalSilverInvested;

          final goldPercentage = totalInvestment == 0
              ? 0
              : (investment.totalGoldInvested / totalInvestment) * 100;

          final silverPercentage = totalInvestment == 0
              ? 0
              : (investment.totalSilverInvested / totalInvestment) * 100;

          // Use the actual metalInOunces data from API response
          final metalInOuncesData = portfolioData.data[0].metalInOunces ?? [];
          print("Metal In Ounces Data: $metalInOuncesData");

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Wrap(
                  spacing: 10,
                  children: tabOptions.map((label) {
                    final isSelected = selectedTab == label;
                    return ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedTab = label;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected
                            ? Colors.black
                            : Colors.white,
                        foregroundColor: isSelected
                            ? Colors.white
                            : Colors.black,
                        side: const BorderSide(color: Colors.black),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(label),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              // Display frequency buttons only if not on pie chart (Asset Allocation tab)
              if (selectedTab != 'Asset Allocation')
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Wrap(
                    spacing: 10,
                    children: timePeriods.map((timePeriod) {
                      final isSelected = frequency == timePeriod;
                      return ElevatedButton(
                        onPressed: () {
                          setState(() {
                            frequency = timePeriod;
                          });
                          // Fetch portfolio data when the frequency is changed
                          fetchPortfolioData();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected
                              ? Colors.black
                              : Colors.white,
                          foregroundColor: isSelected
                              ? Colors.white
                              : Colors.black,
                          side: const BorderSide(color: Colors.black),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(timePeriod),
                      );
                    }).toList(),
                  ),
                ),
              const SizedBox(height: 20),
              Expanded(
                child: Center(
                  child: selectedTab == 'Asset Allocation'
                      ? AssetAllocationPieChart(
                          goldPercentage: goldPercentage.toDouble(),
                          silverPercentage: silverPercentage.toDouble(),
                        )
                      : selectedTab == 'Silver Holdings'
                      ? SilverHoldingsLineChart(
                          metalInOuncesData: metalInOuncesData,
                        )
                      : Text(
                          '$selectedTab View Coming Soon',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
