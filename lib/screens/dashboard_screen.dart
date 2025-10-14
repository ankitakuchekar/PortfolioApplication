import 'package:bold_portfolio/models/portfolio_model.dart';
import 'package:bold_portfolio/services/auth_service.dart';
import 'package:bold_portfolio/widgets/ActualPriceOption.dart';
import 'package:bold_portfolio/widgets/InvestmentFeature.dart';
import 'package:bold_portfolio/widgets/add_holding_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/portfolio_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/profit_loss_cards.dart';
import '../widgets/value_cost_cards.dart';
import '../widgets/metal_portfolio_section.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/common_drawer.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isPremiumIncluded = true; // This might map to 'show actual price'
  bool isLoadingToggle = false; // Tracks loading state for toggle action
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
    final fetchedUser = await authService.getUser();
    setState(() {
      userId = fetchedUser?.id;
    });
  }

  Future<void> fetchChartData() async {
    try {
      final provider = Provider.of<PortfolioProvider>(context, listen: false);
      await provider.refreshDataFromAPIs(provider.frequency);
    } catch (error) {
      debugPrint('Error fetching chart data: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch chart data')),
      );
    }
  }

  Future<void> handleToggle(bool value) async {
    setState(() {
      isLoadingToggle = true;
    });

    // Call your API to update the setting
    bool result = await updatePortfolioSettings(
      customerId: int.tryParse(userId ?? '0') ?? 0,
      settings: Provider.of<PortfolioProvider>(
        context,
        listen: false,
      ).portfolioData!.data[0].portfolioSettings,
      showActualPrice: value,
      token: token ?? '',
    );

    if (result) {
      setState(() {
        isPremiumIncluded = value;
      });
      await fetchChartData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          // margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
          content: Text(
            value ? 'Premium price included' : 'Premium price excluded',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update settings')),
      );
    }

    setState(() {
      isLoadingToggle = false;
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: const CommonAppBar(title: 'Bullion Portfolio'),
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

          final customerData = (portfolioData?.data.isNotEmpty ?? false)
              ? portfolioData!.data[0]
              : CustomerData.empty();

          final portfolioSettings = customerData.portfolioSettings;
          final spotPrices = portfolioProvider.spotPrices?.data;
          final holdingData =
              portfolioProvider.portfolioData?.data[0].productHoldings;
          final silverHoldings =
              holdingData
                  ?.where((holding) => holding.metal == "Silver")
                  .toList() ??
              [];
          final goldrHoldings =
              holdingData
                  ?.where((holding) => holding.metal == "Gold")
                  .toList() ??
              [];
          if (customerData.productHoldings.isEmpty ||
              portfolioData == null ||
              portfolioData.data.isEmpty) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      'https://res.cloudinary.com/bold-pm/image/upload/Graphics/Bullion-invesment-Portfolio.webp',
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Why is it Important to Build\nand Track Your Bullion Investment',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.black,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
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
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.amber[600],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      onPressed: () {
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
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                ProfitLossCards(portfolioData: portfolioData),
                const SizedBox(height: 16),
                ValueCostCards(portfolioData: portfolioData),
                const SizedBox(height: 16),
                MetalPortfolioSection(
                  portfolioData: portfolioData,
                  metalType: "Silver",
                  spotPrice: spotPrices,
                  holdingData: silverHoldings,
                ),
                const SizedBox(height: 16),
                MetalPortfolioSection(
                  portfolioData: portfolioData,
                  metalType: "Gold",
                  spotPrice: spotPrices,
                  holdingData: goldrHoldings,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
