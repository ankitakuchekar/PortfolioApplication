import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/portfolio_model.dart';
import '../providers/portfolio_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/AssetAllocationPie.dart';
import 'package:bold_portfolio/services/portfolio_service.dart';
import '../widgets/LineChartWidget.dart'; // Adjust the path accordingly

class GraphsScreen extends StatefulWidget {
  const GraphsScreen({super.key});

  @override
  State<GraphsScreen> createState() => _GraphsScreenState();
}

class _GraphsScreenState extends State<GraphsScreen> {
  String selectedTab = 'Asset Allocation';
  bool _isPredictionView = false; // Flag for showing prediction
  bool _isGoldView = false; // Flag for gold view

  final List<String> tabOptions = [
    'Asset Allocation',
    'Total Holdings',
    'Gold Holdings',
    'Silver Holdings',
  ];

  final List<String> timePeriods = ['1D', '1W', '1M', '3M', '6M', '1Y', '5Y'];

  // Fetch portfolio data from the server
  Future<void> fetchPortfolioData() async {
    try {
      final portfolioData = await PortfolioService.fetchCustomerPortfolio(
        0,
        '3M', // Default frequency set to '3M'
      );

      // Update portfolio provider with new data
      Provider.of<PortfolioProvider>(
        context,
        listen: false,
      ).updatePortfolioData(portfolioData);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  // Method to toggle the chart type (prediction view)
  void _toggleChartType(bool value) async {
    setState(() {
      _isPredictionView = value;
    });

    // Call to update the API with the new view settings
    fetchPortfolioData();
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

          if (portfolioData == null || portfolioData.data.isEmpty) {
            return const Center(child: Text('No data available.'));
          }

          final investment = portfolioData.data[0].investment;
          final metalInOuncesData = portfolioData.data[0].metalInOunces ?? [];

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
                          _isGoldView = label == 'Gold Holdings';
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
              Expanded(
                child: Center(
                  child: selectedTab == 'Asset Allocation'
                      ? AssetAllocationPieChart(
                          goldPercentage:
                              (investment.totalGoldInvested /
                                  (investment.totalGoldInvested +
                                      investment.totalSilverInvested)) *
                              100,
                          silverPercentage:
                              (investment.totalSilverInvested /
                                  (investment.totalGoldInvested +
                                      investment.totalSilverInvested)) *
                              100,
                        )
                      : selectedTab == 'Gold Holdings' ||
                            selectedTab == 'Silver Holdings'
                      ? MetalHoldingsLineChart(
                          metalInOuncesData: metalInOuncesData,
                          onToggleView: _toggleChartType,
                          isPredictionView: _isPredictionView,
                          isGoldView: _isGoldView,
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
