import 'package:bold_portfolio/models/portfolio_model.dart';
import 'package:bold_portfolio/screens/guestScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/portfolio_provider.dart';
import 'graphs_screen.dart';
import 'holdings_screen.dart';
import 'NewDashBoardUI.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _currentIndex = 1;

  final List<Widget> _screens = const [
    Guestscreen(),
    BullionDashboard(),
    GraphsScreen(),
    HoldingsScreen(),
  ];

  void onNavigationTap(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: PopScope(
        canPop: false, // 👈 REQUIRED for Android back handling
        onPopInvoked: (didPop) {
          if (didPop) return;

          // Graphs or Holdings → Dashboard
          if (_currentIndex == 2 || _currentIndex == 3) {
            setState(() => _currentIndex = 1);
            return;
          }

          // Dashboard → Home
          if (_currentIndex == 1) {
            setState(() => _currentIndex = 0);
            return;
          }

          // Home → Exit app
          SystemNavigator.pop();
        },
        child: Scaffold(
          body: IndexedStack(index: _currentIndex, children: _screens),
          bottomNavigationBar: _currentIndex == 0
              ? const SizedBox.shrink()
              : BottomNavigationBar(
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
