import 'package:bold_portfolio/services/auth_service.dart';
import 'package:bold_portfolio/services/portfolio_service.dart';
import 'package:bold_portfolio/widgets/LineChartWidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http; // For making HTTP requests
import 'dart:convert'; // To handle JSON data

import '../models/portfolio_model.dart';
import '../providers/portfolio_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/AssetAllocationPie.dart';

class GraphsScreen extends StatefulWidget {
  const GraphsScreen({super.key});

  @override
  State<GraphsScreen> createState() => _GraphsScreenState();
}

class _GraphsScreenState extends State<GraphsScreen> {
  String selectedTab = 'Asset Allocation';
  String frequency = '3M'; // Default frequency set to '3M'
  bool isLoading = false; // Flag to show loading indicator
  bool _isPredictionView = false; // Add state to manage the chart view

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

  // Method to toggle the chart view and call the API
  void _toggleChartType(bool value) async {
    setState(() {
      _isPredictionView = value;
    });

    // API request data based on the current toggle state
    final requestData = {
      "customerId": 98937,
      "showPrediction": value, // Toggle prediction view
      "showActualPrice": true,
      "showMetalPrice": false,
      "showVdo": false,
      "doNotShowAgain": false,
      "showGoldPrediction": value
          ? false
          : true, // Set to false when toggle is on
      "showSilverPrediction": value
          ? false
          : true, // Set to false when toggle is on
    };

    // Make the API call
    try {
      final authService = AuthService();
      final token = await authService.getToken();

      final response = await http.post(
        Uri.parse(
          'https://mobile-dev-api.boldpreciousmetals.com/api/Portfolio/UpdateCustomerPortfolioSettings',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestData),
      );

      if (response.statusCode == 200) {
        // If the response is successful, handle it here
        print("API call successful");

        // Call the fetchPortfolioData after a successful response
        fetchPortfolioData();
      } else {
        // If the response is not successful, handle the error
        throw Exception('Failed to update portfolio settings');
      }
    } catch (error) {
      // If an error occurs during the API call
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${error.toString()}')));
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
              Expanded(
                child: Center(
                  child: selectedTab == 'Asset Allocation'
                      ? AssetAllocationPieChart(
                          goldPercentage: goldPercentage.toDouble(),
                          silverPercentage: silverPercentage.toDouble(),
                        )
                      : selectedTab == 'Silver Holdings' ||
                            selectedTab == 'Gold Holdings' ||
                            selectedTab == 'Total Holdings'
                      ? MetalHoldingsLineChart(
                          metalInOuncesData: metalInOuncesData,
                          onToggleView: _toggleChartType,
                          isPredictionView: _isPredictionView,
                          isGoldView: selectedTab == 'Gold Holdings',
                          isTotalHoldingsView: selectedTab == 'Total Holdings',
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
