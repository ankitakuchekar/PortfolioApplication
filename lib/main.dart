import 'dart:async';
import 'package:bold_portfolio/widgets/timer_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

import 'providers/auth_provider.dart';
import 'providers/portfolio_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required for async + background service

  if (!kIsWeb) {
    // ✅ Configure background service before runApp
    FlutterBackgroundService().configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        isForegroundMode: true, // persistent notification required on Android
      ),
      iosConfiguration: IosConfiguration(), // iOS has limited support
    );
  }
  // ✅ Load environment variables
  const envFile = String.fromEnvironment(
    'ENV_FILE',
    defaultValue: 'assets/env/.env.stagging',
  );

  try {
    await dotenv.load(fileName: envFile);
    debugPrint('✅ .env file loaded: $envFile');
    debugPrint('🔧 API_URL: ${dotenv.env['API_URL']}'); // Debug check
  } catch (e) {
    debugPrint('❌ Failed to load .env file: $e');
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => TimerProvider(), // Provide the TimerProvider
      child: BoldPortfolioApp(),
    ),
  );
}

class BoldPortfolioApp extends StatelessWidget {
  const BoldPortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PortfolioProvider()),
      ],
      child: MaterialApp(
        title: 'Bold Bullion Portfolio',
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

/// 🔥 Background service entry point
void onStart(ServiceInstance service) {
  // Allows stopping the service
  service.on("stopService").listen((event) {
    service.stopSelf();
  });

  // Example: periodic API call every minute
  Timer.periodic(const Duration(minutes: 1), (timer) async {
    debugPrint("⏰ Background service running... Fetching API");

    // TODO: Replace with your real API call using http/dio
    // Example:
    // final response = await http.get(Uri.parse(dotenv.env['API_URL']!));
    // debugPrint("API Response: ${response.body}");
  });
}
