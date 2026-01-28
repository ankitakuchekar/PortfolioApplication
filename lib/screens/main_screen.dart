import 'package:bold_portfolio/models/portfolio_model.dart';
// import 'package:bold_portfolio/screens/biometric_login_screen.dart';
import 'package:bold_portfolio/screens/guestScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 1;
  late Widget _currentScreen;

  final List<Widget> _screens = [
    const Guestscreen(),
    const BullionDashboard(),
    const GraphsScreen(),
    const HoldingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentScreen = _screens[_currentIndex];
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void onNavigationTap(int index) {
    setState(() {
      _currentIndex = index;
      _currentScreen = _screens[index];
    });
  }

  DateTime? lastPressed;
  Future<bool> _onWillPop() async {
    if (_currentIndex == 2 || _currentIndex == 3) {
      // Graphs or Holdings → Dashboard
      setState(() {
        _currentIndex = 1;
        _currentScreen = _screens[1];
      });
      return false;
    }

    if (_currentIndex == 1) {
      // Dashboard → GuestScreen Home
      Navigator.pop(context, 'go_home'); // 👈 send signal

      return false;
    }

    return true;
  }

  // Future<bool> _onWillPop() async {
  //   if (_currentIndex != 0) {
  //     setState(() {
  //       _currentIndex = 0;
  //       _currentScreen = _screens[0];
  //     });
  //     return false;
  //   }

  //   final now = DateTime.now();
  //   final backButtonHasNotBeenPressedTwice =
  //       lastPressed == null ||
  //       now.difference(lastPressed!) > const Duration(seconds: 2);

  //   if (backButtonHasNotBeenPressedTwice) {
  //     lastPressed = now;
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text('Press back again to exit')));
  //     return false;
  //   }

  //   SystemNavigator.pop();
  //   return true;
  // }

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

    return SafeArea(
      bottom: true, // ✅ CRITICAL FIX
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          body: _currentScreen,

          bottomNavigationBar: _currentIndex == 0
              ? const SizedBox.shrink()
              : Stack(
                  children: [
                    BottomNavigationBar(
                      currentIndex: _currentIndex,
                      onTap: onNavigationTap,
                      type: BottomNavigationBarType.fixed,
                      backgroundColor: Colors.black,
                      selectedItemColor: Colors.orangeAccent,
                      unselectedItemColor: Colors.white54,
                      items: const [
                        BottomNavigationBarItem(
                          icon: Icon(Icons.home),
                          label: 'Home',
                        ),
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

                    Positioned(
                      left: 80,
                      top: 1,
                      bottom: 1,
                      child: Container(width: 1, color: Colors.white38),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}






  // DateTime? _backgroundTime;
  // bool _isBiometricShown = false;

  
  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.paused ||
  //       state == AppLifecycleState.inactive) {
  //     _backgroundTime = DateTime.now();
  //   }

  //   if (state == AppLifecycleState.resumed) {
  //     if (_backgroundTime == null) return;

  //     final difference = DateTime.now().difference(_backgroundTime!);

  //     if (difference.inMinutes >= 15 && !_isBiometricShown) {
  //       _showBiometricLock();
  //     }
  //   }
  // }

  // void _showBiometricLock() {
  //   _isBiometricShown = true;

  //   Navigator.of(context).push(
  //     PageRouteBuilder(
  //       opaque: false,
  //       pageBuilder: (_, __, ___) => BiometricLoginScreen(
  //         onSuccess: () {
  //           _isBiometricShown = false;
  //           Navigator.of(context).pop();
  //         },
  //       ),
  //     ),
  //   );
  // }
