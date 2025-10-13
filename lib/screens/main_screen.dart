import 'package:bold_portfolio/models/portfolio_model.dart';
import 'package:bold_portfolio/screens/landingSplashpage.dart';
import 'package:bold_portfolio/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/portfolio_provider.dart';
import '../utils/app_colors.dart';
import 'graphs_screen.dart';
import 'holdings_screen.dart';
import '../widgets/common_drawer.dart';
import 'NewDashBoardUI.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late Widget _currentScreen;

  final List<Widget> _screens = [
    const BullionDashboard(),
    const GraphsScreen(),
    const HoldingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentScreen = _screens[_currentIndex];
  }

  void onNavigationTap(int index) {
    setState(() {
      _currentIndex = index;
      _currentScreen = _screens[index];
    });
  }

  // ✅ Used to show screens like HoldingDetailScreen
  void navigateToScreen(Widget screen) {
    setState(() {
      _currentScreen = screen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final portfolioProvider = Provider.of<PortfolioProvider>(context);
    final portfolioData = portfolioProvider.portfolioData;

    final customerData = (portfolioData?.data.isNotEmpty ?? false)
        ? portfolioData!.data[0]
        : CustomerData.empty();

    final portfolioSettings = customerData.portfolioSettings;
    final investmentData = customerData.investment;

    bool shouldDisableTabs =
        investmentData.customerId == 0 && portfolioSettings.customerId == 0;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
          (Route<dynamic> route) => false,
        );

        return false; // Prevent default back behavior
      },
      child: Scaffold(
        body: _currentScreen, // ✅ Show current screen
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
              if (shouldDisableTabs && (index == 1 || index == 2)) return;
              onNavigationTap(index);
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.black,
            selectedItemColor: Colors.orangeAccent,
            unselectedItemColor: Colors.white.withOpacity(0.6),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.show_chart),
                label: 'Graphs',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.inventory_2),
                label: 'Holdings',
              ),
            ],
          ),
        ),
        drawer: CommonDrawer(onNavigationTap: onNavigationTap),
      ),
    );
  }
}
