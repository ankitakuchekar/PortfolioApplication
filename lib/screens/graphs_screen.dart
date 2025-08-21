import 'package:bold_portfolio/models/portfolio_model.dart';
import 'package:bold_portfolio/services/auth_service.dart';
import 'package:bold_portfolio/services/portfolio_service.dart';
import 'package:bold_portfolio/widgets/CandlestickChartWidget.dart';
import 'package:bold_portfolio/widgets/LineChartWidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http; // For making HTTP requests
import 'dart:convert'; // To handle JSON data
import '../providers/auth_provider.dart';
import '../providers/portfolio_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/AssetAllocationPie.dart';
import '../widgets/circular_timer_widget.dart';
import 'login_screen.dart';

// The data models and the widget for the candlestick chart.
// Assuming these are in a separate file like 'metal_candle_chart.dart'
// If they are in the same file, you don't need this import.

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

  String metalFilter = 'Silver'; // Default filter for candlestick chart

  String detectMetalData(List<MetalCandleChartEntry> data) {
    final hasGoldData = data.any(
      (d) =>
          d.openGold != 0 ||
          d.highGold != 0 ||
          d.lowGold != 0 ||
          d.closeGold != 0,
    );
    final hasSilverData = data.any(
      (d) =>
          d.openSilver != 0 ||
          d.highSilver != 0 ||
          d.lowSilver != 0 ||
          d.closeSilver != 0,
    );

    if (!hasGoldData && hasSilverData) {
      return 'Silver';
    } else if (hasGoldData && !hasSilverData) {
      return 'Gold';
    } else {
      return 'Gold'; // Default fallback
    }
  }

  void _onTimerComplete() {
    Provider.of<PortfolioProvider>(
      context,
      listen: false,
    ).refreshDataFromAPIs();
  }

  Future<void> _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: AppColors.primary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/bold_logo.png',
                    width: 120,
                    height: 60,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Text(
                        'BOLD',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'BOLD Portfolio',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile feature coming soon')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings feature coming soon')),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: _handleLogout,
            ),
          ],
        ),
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

          final metalInOuncesData = portfolioData.data[0].metalInOunces ?? [];
          final metalCandleChartData = portfolioData.data[0].metalCandleChart;
          detectMetalData(metalCandleChartData);
          final hasGoldData = metalCandleChartData.any(
            (d) =>
                d.openGold != 0 ||
                d.highGold != 0 ||
                d.lowGold != 0 ||
                d.closeGold != 0,
          );

          final hasSilverData = metalCandleChartData.any(
            (d) =>
                d.openSilver != 0 ||
                d.highSilver != 0 ||
                d.lowSilver != 0 ||
                d.closeSilver != 0,
          );
          // Dynamically build button list
          final List<String> filterOptions = [];
          if (hasGoldData) filterOptions.add('Gold');
          if (hasSilverData) filterOptions.add('Silver');
          if (hasGoldData && hasSilverData) filterOptions.add('All');

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (filterOptions.isNotEmpty)
                      Container(
                        color: const Color(0xFF111827), // Tailwind gray-900
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: filterOptions.map((type) {
                            final isSelected = metalFilter == type;
                            return ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  metalFilter = type;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isSelected
                                    ? Colors.white
                                    : Colors.black,
                                foregroundColor: isSelected
                                    ? Colors.black
                                    : Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                              ),
                              child: Text(type),
                            );
                          }).toList(),
                        ),
                      ),

                    // ... title, zoom buttons, chart etc
                  ],
                ),
                SizedBox(
                  height: 400,
                  // Use the MetalCandleChart widget with the provided data
                  child: MetalCandleChart(
                    candleChartData: metalCandleChartData,
                    selectedMetal: metalFilter,
                  ),
                ),

                // The following sections are left as-is from your original code.
                // const SizedBox(height: 10),
                // SizedBox(
                //   height: 400,
                //   child: ApexChartFlutter(
                //     chartData: metalCandleChartData,
                //     isGold: true,
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Wrap(
                    spacing: 10,
                    alignment: WrapAlignment.center,
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
                // ✅ FIXED: Remove Expanded, use fixed-height container
                Container(
                  height: 400, // Set as needed
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: selectedTab == 'Asset Allocation'
                        ? AssetAllocationPieChart(
                            goldPercentage: goldPercentage.toDouble(),
                            silverPercentage: silverPercentage.toDouble(),
                          )
                        : (selectedTab == 'Silver Holdings' ||
                              selectedTab == 'Gold Holdings' ||
                              selectedTab == 'Total Holdings')
                        ? MetalHoldingsLineChart(
                            metalInOuncesData: metalInOuncesData,
                            onToggleView: _toggleChartType,
                            isPredictionView: _isPredictionView,
                            isGoldView: selectedTab == 'Gold Holdings',
                            isTotalHoldingsView:
                                selectedTab == 'Total Holdings',
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
            ),
          );
        },
      ),
    );
  }
}
