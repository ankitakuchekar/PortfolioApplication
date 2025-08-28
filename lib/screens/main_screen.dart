import 'package:bold_portfolio/models/portfolio_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/portfolio_provider.dart';
import '../utils/app_colors.dart';
import 'dashboard_screen.dart';
import 'graphs_screen.dart';
import 'holdings_screen.dart';
import '../widgets/common_drawer.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const GraphsScreen(),
    const HoldingsScreen(),
  ];

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

  void _onNavigationTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Accessing the provider correctly
    final portfolioProvider = Provider.of<PortfolioProvider>(context);
    final portfolioData = portfolioProvider.portfolioData;

    // Check if portfolioData is null or data is empty
    final customerData = (portfolioData?.data.isNotEmpty ?? false)
        ? portfolioData!.data[0]
        : CustomerData.empty();

    // Check if portfolioSettings is null and fall back to default
    final portfolioSettings = customerData.portfolioSettings;

    // Check if investmentData is null and fall back to default
    final investmentData = customerData.investment;

    // Condition to disable Graphs and Holdings tabs
    bool shouldDisableTabs =
        investmentData.customerId == 0 && portfolioSettings.customerId == 0;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.primary,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (shouldDisableTabs && (index == 1 || index == 2)) {
              // Do nothing if the tabs are disabled (Graphs or Holdings)
              return;
            }
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.black,
          selectedItemColor: Colors.orangeAccent,
          unselectedItemColor: Colors.white.withOpacity(0.6),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart),
              label: 'Graphs',
              // Set color to gray when disabled
              backgroundColor: shouldDisableTabs
                  ? Colors.transparent
                  : Colors.grey,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2),
              label: 'Holdings',
              // Set color to gray when disabled
              backgroundColor: shouldDisableTabs
                  ? Colors.transparent
                  : Colors.grey,
            ),
          ],
        ),
      ),
      drawer: CommonDrawer(onNavigationTap: _onNavigationTap),
    );
  }
}
