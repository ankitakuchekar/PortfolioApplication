import 'package:bold_portfolio/models/spot_price_model.dart';
import 'package:bold_portfolio/screens/BlogsListPageScreen.dart';
import 'package:bold_portfolio/screens/ROICalculator_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:bold_portfolio/screens/spot_priceScreen.dart';
import 'package:bold_portfolio/screens/enter_pin_screen.dart';
import 'package:bold_portfolio/screens/login_screen.dart';
import 'package:bold_portfolio/screens/main_screen.dart';
import 'package:bold_portfolio/services/auth_service.dart';
import 'package:bold_portfolio/providers/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';

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

class _GuestscreenState extends State<Guestscreen> with WidgetsBindingObserver {
  int selectedIndex = 0;
  bool isCheckingPin = false;
  late GuestView currentView;
  DateTime? _backgroundTime;
  SpotData? parentSpotPrice;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    currentView = widget.initialView;
    print("Initial View: $currentView");
    if (currentView == GuestView.login || currentView == GuestView.pin) {
      selectedIndex = 1; // Portfolio tab
    } else {
      selectedIndex = widget.initialIndex;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ---------------- APP LIFECYCLE HANDLER ----------------
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // The app is in the background, save the current timestamp
      _backgroundTime = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      // The app is in the foreground, check the time difference
      if (_backgroundTime != null) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final difference = DateTime.now().difference(_backgroundTime!);
        if (difference.inMinutes > 15 && authProvider.isAuthenticated) {
          print("insude ankita1");
          setState(() {
            currentView = GuestView.pin;
            selectedIndex = 1; // Ensure it's showing the "Portfolio" tab
          });
        } else {
          print("insude ankita2");
          _checkForPinOrLogin();
        }
      }
    }
  }

  void _showMoreMenu(SpotData? spotPrice) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,
      barrierColor: Colors.transparent, // important
      backgroundColor: Colors.transparent,
      builder: (_) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.pop(context), // 👈 tap anywhere closes
          child: Stack(
            children: [
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 100, right: 16),
                  child: GestureDetector(
                    onTap: () {}, // 👈 prevent closing when tapping menu itself
                    child: Container(
                      width: 180,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: darkBlack,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _moreItem(Icons.calculate, "Calculator", spotPrice),
                          _divider(),
                          _moreItem(Icons.article, "Blogs/News", spotPrice),
                          _divider(),
                          _moreItem(Icons.store, "Visit BOLD Store", spotPrice),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _moreItem(IconData icon, String label, SpotData? spotPrice) {
    final String redirectionUrl = dotenv.env['URL_Redirection'] ?? '';

    Future<void> _launchUrl() async {
      final Uri uri = Uri.parse(redirectionUrl);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $redirectionUrl');
      }
    }

    return InkWell(
      onTap: () {
        if (label == "Blogs") {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => BlogListPage(),
              settings: RouteSettings(arguments: {'page': 1}),
            ),
          );
        } else if (label == "Calculator") {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => ROICalculator(spotPrice: spotPrice!),
              settings: RouteSettings(arguments: {'page': 2}),
            ),
          );
        } else {
          _launchUrl(); // Close the current page for other items
        }
      },
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
          SpotPriceScreen(
            onLatestSpotPriceChanged: (spotData) {
              // Handle the updated spot price here if needed
              print("Latest spot price updated: $spotData");
              setState(() {
                parentSpotPrice = spotData;
              });
            },
          ),
          _buildPortfolioContent(),
        ],
      ),

      // ---------------- CUSTOM BOTTOM NAV ----------------
      bottomNavigationBar: SafeArea(
        top: false,
        child: SizedBox(
          height: 80, // reduced height
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              /// Bottom Black Bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 56, // standard bottom bar height
                  color: darkBlack,
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _bottomItem(
                        icon: Icons.home,
                        label: "Home",
                        index: 0,
                        spotPrice: parentSpotPrice,
                      ),

                      const SizedBox(width: 70),

                      _bottomItem(
                        icon: Icons.more_horiz,
                        label: "More",
                        index: 2,
                        spotPrice: parentSpotPrice,
                      ),
                    ],
                  ),
                ),
              ),

              /// ⭐ Center Portfolio Button
              Positioned(
                top: -6,
                left: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    _handlePortfolioNavigation(authProvider, authService);
                    setState(() => selectedIndex = 1);
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.pie_chart,
                              size: 34,
                              color: Colors.black,
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Portfolio",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomItem({
    required IconData icon,
    required String label,
    required int index,
    required spotPrice,
  }) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        if (index == 2) {
          _showMoreMenu(spotPrice);
          return;
        }
        setState(() {
          selectedIndex = index;
          if (selectedIndex == 0) {
            currentView = GuestView.home;
          } else if (selectedIndex == 1) {
            _checkForPinOrLogin();
          }
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: isSelected ? Colors.white : Colors.grey),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.white : Colors.grey,
            ),
          ),
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

  // Check if the user should see the pin entry or login screen
  void _checkForPinOrLogin() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final authService = AuthService();
    print("check for pun ${currentView} ${selectedIndex}");
    if (selectedIndex == 0) {
      setState(() {
        selectedIndex = 0;
        currentView = GuestView.home;
      });
    } else if (authProvider.isAuthenticated) {
      authService.getPin().then((fetchedUserPin) {
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
      });
    } else {
      setState(() {
        selectedIndex = 1;
        currentView = GuestView.login;
      });
    }
  }
}
