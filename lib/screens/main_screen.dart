import 'package:bold_portfolio/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'guestScreen.dart';
import 'graphs_screen.dart';
import 'holdings_screen.dart';
import 'NewDashBoardUI.dart';
import '../providers/auth_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 1;

  DateTime? _backgroundTime;
  bool _pinForced = false;

  final List<Widget> _screens = const [
    Guestscreen(),
    BullionDashboard(),
    GraphsScreen(),
    HoldingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  bool _wentToBackground = false;

  // ---------------- LIFECYCLE ----------------
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    print("Lifecycle: $state");

    if (state == AppLifecycleState.paused) {
      _backgroundTime = DateTime.now();
      _wentToBackground = true;
      print("App really background at $_backgroundTime $_currentIndex");
    }

    if (state == AppLifecycleState.resumed && _wentToBackground) {
      print("App resumed after background");
      _checkIfPinRequired();
      _wentToBackground = false;
    }

    // 🔥 APP KILLED / REMOVED FROM RECENTS
    if (state == AppLifecycleState.detached) {
      final AuthService authService = AuthService();
      print("App detached — resetting update popup flag");
      authService.setNotNowFlag(false);
    }
  }

  // ---------------- PIN CHECK ----------------
  void _checkIfPinRequired() {
    if (_backgroundTime == null || _pinForced) return;

    print("background time: $_backgroundTime");

    final diff = DateTime.now().difference(_backgroundTime!);
    print("Background duration:  ${diff.inMinutes} min");
    print("_currentIndex: $_currentIndex");
    if (diff.inMinutes >= 2) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final authService = AuthService();
      if (_currentIndex == 0) {
        setState(() => _currentIndex = 0);
      } else {
        if (authProvider.isAuthenticated) {
          authService.getPin().then((fetchedUserPin) {
            print("Fetched User PIN: $fetchedUserPin");
            if (fetchedUserPin == null || fetchedUserPin == '0') {
              setState(() {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const MainScreen()),
                );
              });
            } else {
              setState(() {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const Guestscreen(
                      initialView: GuestView.pin,
                      initialIndex: 1,
                    ),
                  ),
                  (_) => false,
                );
                _pinForced = true;
              });
            }
          });
        } else {
          setState(() {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => const Guestscreen(
                  initialView: GuestView.login,
                  initialIndex: 1,
                ),
              ),
              (_) => false,
            );
          });
        }
      }
    }
  }

  void onNavigationTap(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;

          // Graphs / Holdings → Dashboard
          if (_currentIndex == 2 || _currentIndex == 3) {
            setState(() => _currentIndex = 1);
            return;
          }

          // Dashboard → Home
          if (_currentIndex == 1) {
            setState(() => _currentIndex = 0);
            return;
          }

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
