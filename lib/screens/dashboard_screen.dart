import 'package:bold_portfolio/models/portfolio_model.dart';
import 'package:bold_portfolio/services/auth_service.dart';
import 'package:bold_portfolio/widgets/ActualPriceOption.dart';
import 'package:bold_portfolio/widgets/InvestmentFeature.dart';
import 'package:bold_portfolio/widgets/add_holding_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/portfolio_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/asset_allocation_section.dart';
import '../widgets/profit_loss_cards.dart';
import '../widgets/value_cost_cards.dart';
import '../widgets/metal_portfolio_section.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/common_drawer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isPremiumIncluded = true; // <-- Added state variable
  String? token;
  String? userId;
  @override
  void initState() {
    super.initState();
    _loadToken();
    _loadUserId();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PortfolioProvider>(
        context,
        listen: false,
      ).loadPortfolioData();
    });
  }

  Future<void> _loadToken() async {
    final authService = AuthService();
    final fetchedToken = await authService.getToken();
    setState(() {
      token = fetchedToken;
    });
  }

  Future<void> _loadUserId() async {
    final authService = AuthService();
    final fetchedUserId = await authService.getUser();
    setState(() {
      userId = fetchedUserId?.id;
    });
  }

  Future<void> fetchChartData() async {
    try {
      final provider = Provider.of<PortfolioProvider>(context, listen: false);
      await provider
          .loadPortfolioData(); // Or refreshDataFromAPIs() depending on what you want
    } catch (error) {
      debugPrint('Error fetching chart data: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch chart data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CommonAppBar(title: 'Portfolio'),
      drawer: const CommonDrawer(),
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

          // Check if portfolioData is null or data is empty
          final customerData = (portfolioData?.data.isNotEmpty ?? false)
              ? portfolioData!.data[0]
              : CustomerData.empty();

          // Check if portfolioSettings is null and fall back to default
          final portfolioSettings = customerData.portfolioSettings;

          // Check if investmentData is null and fall back to default
          final investmentData = customerData.investment;
          // Check if portfolioData or its data is null/empty and handle the fallback UI
          if ((investmentData.customerId == 0 &&
                  portfolioSettings.customerId == 0) ||
              portfolioData == null ||
              portfolioData.data.isEmpty) {
            return Scaffold(
              backgroundColor: Colors.white,
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Banner
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        'https://res.cloudinary.com/bold-pm/image/upload/Graphics/Bullion-invesment-Portfolio.webp',
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit
                            .cover, // Ensures the image covers the container properly
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    const Text(
                      'Why is it Important to Build\nand Track Your Bullion Investment',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.black,
                        height: 1.5, // Increased line height for better spacing
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Features
                    InvestmentFeature(
                      icon: Icons.link,
                      text:
                          "Keeps all your gold and silver investments in one place.",
                    ),
                    InvestmentFeature(
                      icon: Icons.show_chart,
                      text:
                          "Helps assess the current value of your holdings compared to purchase prices.",
                    ),
                    InvestmentFeature(
                      icon: Icons.bar_chart,
                      text:
                          "Offers insights into the growth of your investments over time.",
                    ),
                    InvestmentFeature(
                      icon: Icons.settings,
                      text:
                          "Centralizes all data, making it easily accessible anytime and anywhere.",
                    ),
                    const SizedBox(height: 32),

                    // Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor:
                              Colors.amber[600], // Text and icon color
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              12,
                            ), // Rounded corners
                          ),
                          elevation: 5, // Add shadow for elevation effect
                        ),
                        onPressed: () {
                          // Navigation logic
                          showDialog(
                            context: context,
                            builder: (context) => AddHoldingForm(
                              onClose: () => Navigator.of(context).pop(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text(
                          "Add New Holdings",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ActualPriceBannerOption(
                  customerId: int.tryParse(userId ?? '') ?? 0,
                  settings: portfolioSettings,
                  token: token!,
                  fetchChartData: () async {
                    await fetchChartData(); // This must be defined somewhere
                  },
                  isActualPrice: portfolioSettings.showActualPrice,
                ),
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
