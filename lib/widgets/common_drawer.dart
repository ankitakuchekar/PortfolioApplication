import 'package:bold_portfolio/models/portfolio_model.dart';
import 'package:bold_portfolio/screens/BullionPortfolioGuideScreen.dart';
import 'package:bold_portfolio/screens/PrivacyPolicyScreen.dart';
import 'package:bold_portfolio/screens/TaxReportScreen.dart';
import 'package:bold_portfolio/screens/guestScreen.dart';
import 'package:bold_portfolio/screens/setting_pin_screen.dart';
import 'package:bold_portfolio/services/api_service.dart';
import 'package:bold_portfolio/widgets/FeedbackPopup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/portfolio_provider.dart';
import '../utils/app_colors.dart';
import '../screens/login_screen.dart';
import '../services/auth_service.dart';

class CommonDrawer extends StatefulWidget {
  final Function(int)? onNavigationTap;

  const CommonDrawer({super.key, this.onNavigationTap});

  @override
  State<CommonDrawer> createState() => _CommonDrawerState();
}

class _CommonDrawerState extends State<CommonDrawer> {
  bool isPremiumIncluded = false;
  bool isLoadingToggle = false;
  String? token;
  String? userId;
  String? firstName;
  String? lastName;

  @override
  void initState() {
    super.initState();
    _loadToken();
    _loadUserId();

    // Load portfolio data after build
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Provider.of<PortfolioProvider>(
    //     context,
    //     listen: false,
    //   ).loadPortfolioData();
    // });
  }

  Future<void> _loadToken() async {
    final authService = AuthService();
    final fetchedToken = await authService.getToken();
    setState(() {
      token = fetchedToken;
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

  Future<void> _loadUserId() async {
    final authService = AuthService();
    final fetchedUser = await authService.getUser();
    setState(() {
      userId = fetchedUser?.id;
      firstName = fetchedUser?.firstName;
      lastName = fetchedUser?.lastName;
    });
  }

  Future<void> handleToggle(bool value) async {
    setState(() {
      isLoadingToggle = true;
    });

    try {
      final provider = Provider.of<PortfolioProvider>(context, listen: false);
      bool result = await updatePortfolioSettings(
        customerId: int.tryParse(userId ?? '0') ?? 0,
        settings: provider.portfolioData!.data[0].portfolioSettings,
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
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }

    setState(() {
      isLoadingToggle = false;
    });
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();

    if (!context.mounted) return;

    // Navigate to Guestscreen with Login
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const Guestscreen(initialView: GuestView.login),
      ),
      (route) => false,
    );
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;

    return text
        .split(' ')
        .map((word) {
          return word.isNotEmpty
              ? word[0].toUpperCase() + word.substring(1).toLowerCase()
              : '';
        })
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    // Get provider instance
    final portfolioProvider = Provider.of<PortfolioProvider>(context);

    final portfolioData = portfolioProvider.portfolioData;

    final customerData = (portfolioData?.data.isNotEmpty ?? false)
        ? portfolioData!.data[0]
        : CustomerData.empty();

    // final portfolioSettings = customerData?.portfolioSettings;
    // final holdingData =
    //     portfolioProvider.portfolioData?.data[0].productHoldings;

    final portfolioSettings = customerData.portfolioSettings;
    final holdingData = customerData.productHoldings;
    return Drawer(
      child: Column(
        children: [
          Container(
            height:
                100, // Set a specific height for the header (adjust as needed)
            child: DrawerHeader(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              decoration: const BoxDecoration(color: AppColors.black),
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.network(
                      "https://res.cloudinary.com/bold-pm/image/upload/v1629887471/Graphics/email/BPM-White-Logo.png",
                      width: 150,
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      "Hello, ${capitalizeFirstLetter(firstName ?? '')} ${capitalizeFirstLetter(lastName ?? '')}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Icon(Icons.info_outline, size: 18, color: Colors.grey),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),

          // Premium Toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      portfolioSettings.showActualPrice ?? false
                          ? "Premium Included"
                          : "Premium Excluded",
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Icon(Icons.info_outline, size: 18, color: Colors.grey), // Uncomment if needed
                  ],
                ),
                isLoadingToggle
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Switch(
                        value: portfolioSettings.showActualPrice ?? false,
                        onChanged: isLoadingToggle || holdingData!.isEmpty
                            ? null // Disable the switch when holdingData is null
                            : handleToggle, // Use the handleToggle function when holdingData is not null
                        activeColor: Colors.blue, // Color when switch is on
                        inactiveThumbColor:
                            Colors.grey, // Color when switch is off
                        inactiveTrackColor: Colors
                            .grey
                            .shade300, // Track color when switch is off
                      ),
              ],
            ),
          ),

          const Divider(),

          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.description_outlined,
                    color: Colors.blue,
                  ),
                  title: const Text("Tax Report"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TaxReportScreen(
                          token: token ?? '',
                          customerId: userId ?? '',
                          selectedYear: '',
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.green,
                  ),
                  title: const Text("Feedback"),
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (context) => FeedbackPopup(),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.menu_book_outlined,
                    color: Colors.orange,
                  ),
                  title: const Text("Guide"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BullionPortfolioGuideScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.shield_outlined,
                    color: Colors.purple,
                  ),
                  title: const Text("Privacy Policy"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PrivacyPolicyScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.settings_outlined,
                    color: Colors.teal,
                  ),
                  title: const Text("Settings"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SettingPinScreen(isSettingPage: true),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () => _handleLogout(context),
                ),
              ],
            ),
          ),

          // Logout
          // const Divider(),
          // ListTile(
          //   leading: const Icon(Icons.logout, color: Colors.red),
          //   title: const Text('Logout', style: TextStyle(color: Colors.red)),
          //   onTap: () => _handleLogout(context),
          // ),
        ],
      ),
    );
  }
}
