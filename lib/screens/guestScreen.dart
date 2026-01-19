import 'package:bold_portfolio/screens/spot_priceScreen.dart';
import 'package:bold_portfolio/screens/login_screen.dart'; // import login screen
import 'package:flutter/material.dart';

// Define your colors globally or import from a constants file
const bgLightYellow = Color.fromARGB(255, 246, 229, 189);
const snapYellow = Color.fromARGB(255, 220, 166, 2);
const darkBlack = Color(0xFF000000);

class Guestscreen extends StatefulWidget {
  const Guestscreen({super.key});

  @override
  State<Guestscreen> createState() => _GuestscreenState();
}

class _GuestscreenState extends State<Guestscreen> {
  int selectedIndex = 0;

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

  @override
  Widget build(BuildContext context) {
    // Screens for the tabs
    final List<Widget> screens = [
      const SpotPriceScreen(), // Home tab shows SpotPriceScreen
      const LoginScreen(
        isForgotPassClick: false,
      ), // Portfolio tab shows LoginScreen
      const SizedBox(), // More tab is empty, menu shown separately
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkBlack,
        title: const Text(
          "BOLD Bullion Portfolio",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: IndexedStack(index: selectedIndex, children: screens),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        selectedItemColor: snapYellow,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 2) {
            _showMoreMenu();
            return;
          }
          setState(() => selectedIndex = index);
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
}
