import 'package:bold_portfolio/screens/spot_priceScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bold_portfolio/providers/auth_provider.dart';
import 'package:bold_portfolio/screens/enter_pin_screen.dart';
import 'package:bold_portfolio/screens/login_screen.dart';
import 'package:bold_portfolio/screens/main_screen.dart';
import 'package:bold_portfolio/services/auth_service.dart';

// Colors
const snapYellow = Color.fromARGB(255, 220, 166, 2);
const darkBlack = Color(0xFF000000);

// ---------------- ENUM FOR VIEW STATE ----------------
enum GuestView { home, login, pin }

class Guestscreen extends StatefulWidget {
  final GuestView initialView;
  final int initialIndex;

  const Guestscreen({
    super.key,
    this.initialView = GuestView.home,
    this.initialIndex = 0,
  });

  @override
  State<Guestscreen> createState() => _GuestscreenState();
}

class _GuestscreenState extends State<Guestscreen> {
  int selectedIndex = 0;

  bool isCheckingPin = false;
  late GuestView currentView;

  @override
  void initState() {
    super.initState();
    currentView = widget.initialView;
    if (currentView == GuestView.login || currentView == GuestView.pin) {
      selectedIndex = 1; // Portfolio tab
    } else {
      selectedIndex = widget.initialIndex;
    }
  }

  // ---------------- MORE MENU ----------------
  void _showMoreMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: Align(
            alignment: Alignment.bottomRight,
            child: Container(
              width: 240,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: darkBlack,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _moreItem(Icons.calculate, "Calculator"),
                  _divider(),
                  _moreItem(Icons.article, "Blogs"),
                  _divider(),
                  _moreItem(Icons.store, "Visit BOLD Store"),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _moreItem(IconData icon, String label) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: snapYellow),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(color: Colors.white.withOpacity(0.2));
  }

  // ---------------- BUILD ----------------
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkBlack,
        centerTitle: true,
        title: const Text(
          "BOLD Bullion Portfolio",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      // ---------------- BODY ----------------
      body: IndexedStack(
        index: selectedIndex,
        children: [
          // HOME TAB
          const SpotPriceScreen(),

          // PORTFOLIO TAB
          _buildPortfolioContent(),
        ],
      ),

      // ---------------- BOTTOM NAV ----------------
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        selectedItemColor: snapYellow,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 2) {
            _showMoreMenu();
            return;
          }

          if (index == 1) {
            _handlePortfolioNavigation(authProvider, authService);
          } else {
            setState(() {
              selectedIndex = index;
              currentView = GuestView.home;
            });
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: "Portfolio",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: "More"),
        ],
      ),
    );
  }

  // ---------------- PORTFOLIO CONTENT ----------------
  Widget _buildPortfolioContent() {
    switch (currentView) {
      case GuestView.login:
        return const LoginScreen(isForgotPassClick: false);
      case GuestView.pin:
        return const NewPinEntryScreen(isFromSettings: false);
      default:
        return const Center(
          child: Text("Access your portfolio", style: TextStyle(fontSize: 16)),
        );
    }
  }

  // ---------------- AUTH / PIN LOGIC ----------------
  Future<void> _handlePortfolioNavigation(
    AuthProvider authProvider,
    AuthService authService,
  ) async {
    if (isCheckingPin) return;

    setState(() {
      isCheckingPin = true;
    });

    final fetchedUserPin = await authService.getPin();

    if (authProvider.isAuthenticated) {
      if (fetchedUserPin == null || fetchedUserPin == '0') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      } else {
        setState(() {
          selectedIndex = 1;
          currentView = GuestView.pin;
        });
      }
    } else {
      setState(() {
        selectedIndex = 1;
        currentView = GuestView.login;
      });
    }

    setState(() {
      isCheckingPin = false;
    });
  }
}
