import 'package:bold_portfolio/models/portfolio_model.dart';
import 'package:bold_portfolio/services/auth_service.dart';
import 'package:bold_portfolio/services/portfolio_service.dart';
import 'package:bold_portfolio/widgets/CandlestickChartWidget.dart';
import 'package:bold_portfolio/widgets/LineChartWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http; // For making HTTP requests
import 'dart:convert'; // To handle JSON data
import '../providers/portfolio_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/AssetAllocationPie.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/common_drawer.dart';

class GraphsScreen extends StatefulWidget {
  const GraphsScreen({super.key});

  @override
  State<GraphsScreen> createState() => _GraphsScreenState();
}

class _GraphsScreenState extends State<GraphsScreen> {
  String selectedTab = 'Candle Chart'; // Set Candle Chart as the initial tab
  String frequency = '1D'; // Default frequency set to '3M'
  bool isLoading = false; // Flag to show loading indicator
  bool showGoldPrediction = false; // This can be dynamic based on your data
  bool showSilverPrediction = false;
  bool showTotalPrediction = false;

  // Determine the value of _isPredictionView
  bool _isPredictionView = false;

  final List<String> timePeriods = ['1D', '1W', '1M', '3M', '6M', '1Y', '5Y'];

  final List<String> tabOptions = [
    'Candle Chart', // Added new tab
    'Asset Allocation',
    'Total Holdings',
    'Gold Holdings',
    'Silver Holdings',
  ];

  // Method to fetch the portfolio data when the frequency changes

  Future<void> fetchChartData(frequency) async {
    try {
      final provider = Provider.of<PortfolioProvider>(context, listen: false);
      await provider.refreshDataFromAPIs(
        frequency,
      ); // Or refreshDataFromAPIs() depending on what you want
    } catch (error) {
      debugPrint('Error fetching chart data: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch chart data')),
      );
    }
  }

  String metalFilter = 'Silver'; // Default filter for candlestick chart

  String detectMetalData(List<MetalCandleChartEntry> data) {
    final hasGoldData = data.any(
      (d) =>
          d.openGold > 0 || d.highGold > 0 || d.lowGold > 0 || d.closeGold > 0,
    );
    final hasSilverData = data.any(
      (d) =>
          d.openSilver > 0 ||
          d.highSilver > 0 ||
          d.lowSilver > 0 ||
          d.closeSilver > 0,
    );
    // Check if Silver data is available, if not, fallback to Gold
    if (!hasSilverData && metalFilter == 'Silver') {
      metalFilter =
          'Gold'; // Automatically select 'Gold' if 'Silver' is unavailable
    }

    if (!hasGoldData && hasSilverData) {
      return 'Silver';
    } else if (hasGoldData && !hasSilverData) {
      return 'Gold';
    } else {
      return 'All'; // Default fallback
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
      final String baseUrl = dotenv.env['API_URL']!;

      final response = await http.post(
        Uri.parse('$baseUrl/Portfolio/UpdateCustomerPortfolioSettings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestData),
      );

      if (response.statusCode == 200) {
        // Call the fetchPortfolioData after a successful response
        fetchChartData(frequency);
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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: const CommonAppBar(title: 'Portfolio Charts'),
      drawer: const CommonDrawer(),
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
          final portfolioSettings = portfolioData.data[0].portfolioSettings;
          showGoldPrediction = portfolioSettings.showGoldPrediction;
          showSilverPrediction = portfolioSettings.showSilverPrediction;
          showTotalPrediction = portfolioSettings.showTotalPrediction;

          if (selectedTab == 'Gold Holdings') {
            _isPredictionView = !showGoldPrediction;
          } else if (selectedTab == 'Silver Holdings') {
            _isPredictionView = !showSilverPrediction;
          } else if (selectedTab == 'Total Holdings') {
            _isPredictionView = !showTotalPrediction;
          }

          detectMetalData(metalCandleChartData);
          final hasGoldData = metalCandleChartData.any(
            (d) =>
                d.openGold > 0 ||
                d.highGold > 0 ||
                d.lowGold > 0 ||
                d.closeGold > 0,
          );

          final hasSilverData = metalCandleChartData.any(
            (d) =>
                d.openSilver > 0 ||
                d.highSilver > 0 ||
                d.lowSilver > 0 ||
                d.closeSilver > 0,
          );
          final hasAllData = metalCandleChartData.any(
            (d) =>
                d.openMetal > 0 ||
                d.highMetal > 0 ||
                d.lowMetal > 0 ||
                d.closeMetal > 0,
          );
          // Dynamically build button list
          final List<String> filterOptions = [];

          if (hasGoldData && hasSilverData) {
            filterOptions.addAll(['All', 'Gold', 'Silver']);
          } else if (hasGoldData) {
            filterOptions.add('Gold');
          } else if (hasSilverData) {
            filterOptions.add('Silver');
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 5),
                // Tab buttons for selection
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Wrap(
                    spacing: 3,
                    alignment: WrapAlignment.center,
                    children: tabOptions.map((label) {
                      final isSelected = selectedTab == label;
                      return ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedTab = label;
                            if (selectedTab == 'Candle Chart') {
                              frequency = '1D';
                            } else {
                              frequency = '3M';
                            }
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
                if (selectedTab == 'Total Holdings' ||
                    selectedTab == 'Gold Holdings' ||
                    selectedTab == 'Silver Holdings' ||
                    selectedTab == 'Candle Chart')
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Wrap(
                      spacing: 4,
                      alignment: WrapAlignment.center,
                      children: timePeriods.map((period) {
                        final isSelected = frequency == period;
                        return OutlinedButton(
                          onPressed: () {
                            setState(() {
                              frequency = period;
                              portfolioProvider.frequency =
                                  period; // Save the selected frequency
                              fetchChartData(frequency);
                              // Optionally trigger a fetchChartData() or update chart logic
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: isSelected
                                ? Colors.black
                                : Colors.transparent,
                            side: BorderSide(color: Colors.black),
                            minimumSize: const Size(40, 32),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: Text(
                            period,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                Container(
                  height: 400,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: selectedTab == 'Candle Chart'
                        ? Column(
                            children: [
                              if (filterOptions.isNotEmpty)
                                Container(
                                  color: const Color(0xFF111827),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 16,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
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
                              Expanded(
                                child: MetalCandleChart(
                                  candleChartData: metalCandleChartData,
                                  selectedMetal: metalFilter,
                                  showCombined: metalFilter == 'All',
                                ),
                              ),
                            ],
                          )
                        : selectedTab == 'Asset Allocation'
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
                            selectedTab: selectedTab,
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
