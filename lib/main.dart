import 'dart:async';
import 'package:bold_portfolio/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

// Providers
import 'widgets/timer_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/portfolio_provider.dart';

// UI
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment file (safe before UI)
  const envFile = String.fromEnvironment(
    'ENV_FILE',
    defaultValue: 'assets/env/.env.stagging',
  );

  try {
    await dotenv.load(fileName: envFile);
    debugPrint('✅ .env loaded: $envFile');
  } catch (e) {
    debugPrint('❌ .env load failed: $e');
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => TimerProvider(),
      child: const BoldPortfolioApp(),
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

/// 🔹 Call this ONLY after user opens app / logs in
Future<void> startBackgroundService() async {
  if (kIsWeb) return;

  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      initialNotificationTitle: 'Bold Portfolio',
      initialNotificationContent: 'Syncing data securely',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(),
  );

  service.startService();
}

/// 🔥 Background service entry point (separate isolate)
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // ✅ Initialize dotenv again inside background isolate
  try {
    await dotenv.load(fileName: 'assets/env/.env.stagging');
    debugPrint('✅ dotenv loaded in background isolate');
  } catch (e) {
    debugPrint('❌ dotenv load failed in background: $e');
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  Timer.periodic(const Duration(minutes: 1), (timer) async {
    debugPrint('⏰ Background service heart-beat');

    final baseUrl = dotenv.env['API_URL'];
    if (baseUrl == null) {
      debugPrint('❌ API_URL missing');
      return;
    }

    try {
      final response = await http.get(Uri.parse(baseUrl));
      debugPrint('✅ API status: ${response.statusCode}');
    } catch (e) {
      debugPrint('❌ API error: $e');
    }
  });
}




// import 'dart:async';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:provider/provider.dart';
// import 'package:http/http.dart' as http;

// // Providers & Screens
// import 'widgets/timer_provider.dart';
// import 'providers/auth_provider.dart';
// import 'providers/portfolio_provider.dart';
// import 'screens/splash_screen.dart';
// import 'utils/app_theme.dart';

// // 1. Global Navigator Key to allow locking from background
// // final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   if (!kIsWeb) {
//     FlutterBackgroundService().configure(
//       androidConfiguration: AndroidConfiguration(
//         onStart: onStart,
//         isForegroundMode: true,
//         initialNotificationTitle: "Service Running",
//         initialNotificationContent: "Background service is active...",
//         foregroundServiceNotificationId: 888,
//       ),
//       iosConfiguration: IosConfiguration(),
//     );
//   }

//   const envFile = String.fromEnvironment(
//     'ENV_FILE',
//     defaultValue: 'assets/env/.env.stagging',
//   );

//   try {
//     await dotenv.load(fileName: envFile);
//     debugPrint('✅ .env file loaded: $envFile');
//   } catch (e) {
//     debugPrint('❌ Failed to load .env file: $e');
//   }

//   runApp(
//     // Wrapping at the very top so TimerProvider is available everywhere
//     ChangeNotifierProvider(
//       create: (_) => TimerProvider(),
//       child: const BoldPortfolioApp(),
//     ),
//   );
// }

// class BoldPortfolioApp extends StatelessWidget {
//   const BoldPortfolioApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     throw UnimplementedError();
//   }

//   // @override
//   // State<BoldPortfolioApp> createState() => _BoldPortfolioAppState();
// }

// Widget build(BuildContext context) {
//   return MultiProvider(
//     providers: [
//       ChangeNotifierProvider(create: (_) => AuthProvider()),
//       ChangeNotifierProvider(create: (_) => PortfolioProvider()),
//     ],
//     child: MaterialApp(
//       title: 'Bold Bullion Portfolio',
//       theme: AppTheme.lightTheme,
//       home: const SplashScreen(),
//       debugShowCheckedModeBanner: false,
//     ),
//   );
// }

// // /// 🔥 Background service entry point (Runs in a separate Isolate)
// @pragma('vm:entry-point')
// void onStart(ServiceInstance service) async {
//   // Re-load dotenv inside isolate if needed for API calls
//   service.on("stopService").listen((event) {
//     service.stopSelf();
//   });

//   Timer.periodic(const Duration(minutes: 1), (timer) async {
//     debugPrint("⏰ Background service heart-beat");
//     final String baseUrl = dotenv.env['API_URL']!;

//     try {
//       final response = await http.get(baseUrl as Uri);
//       if (response.statusCode == 200) {
//         debugPrint("API Response: ${response.body}");
//       } else {
//         debugPrint("Failed to fetch data, status code: ${response.statusCode}");
//       }
//     } catch (e) {
//       debugPrint("Error during API call: $e");
//     }
//   });
// }











// // 2. Add WidgetsBindingObserver to detect when app is closed/opened
// // class _BoldPortfolioAppState extends State<BoldPortfolioApp>
// //     with WidgetsBindingObserver {
// //   @override
// //   void initState() {
// //     super.initState();
// //     // Start listening to app lifecycle (background/foreground)
// //     WidgetsBinding.instance.addObserver(this);
// //   }

// //   @override
// //   void dispose() {
// //     WidgetsBinding.instance.removeObserver(this);
// //     super.dispose();
// //   }

// //   // 3. Logic to handle background timing
// //   @override
// //   void didChangeAppLifecycleState(AppLifecycleState state) {
// //     final timerProvider = Provider.of<TimerProvider>(context, listen: false);

// //     if (state == AppLifecycleState.paused) {
// //       // User minimized the app
// //       timerProvider.recordStartTime();
// //       debugPrint("📱 App moved to background");
// //     } else if (state == AppLifecycleState.resumed) {
// //       // User returned to the app
// //       debugPrint("📱 App returned to foreground");
// //       if (timerProvider.shouldLockApp()) {
// //         debugPrint("🔒 5 minutes passed. Locking app.");
// //         _lockApp();
// //       }
// //     }
// //   }

// //   void _lockApp() {
// //     final authProvider = Provider.of<AuthProvider>(context, listen: false);
// //     if (authProvider.isAuthenticated) {
// //       // Navigates to PIN screen and clears navigation history
// //       navigatorKey.currentState?.pushAndRemoveUntil(
// //         MaterialPageRoute(
// //           builder: (_) => const NewPinEntryScreen(isFromSettings: false),
// //         ),
// //         (route) => false,
// //       );
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return MultiProvider(
// //       providers: [
// //         ChangeNotifierProvider(create: (_) => AuthProvider()),
// //         ChangeNotifierProvider(create: (_) => PortfolioProvider()),
// //       ],
// //       child: Listener(
// //         behavior: HitTestBehavior.translucent,
// //         onPointerDown: (_) {
// //           // Keep the existing "In-App" inactivity timer working
// //           Provider.of<TimerProvider>(context, listen: false).resetTimersForPin(
// //             () {
// //               _lockApp();
// //             },
// //           );
// //         },
// //         child: MaterialApp(
// //           navigatorKey: navigatorKey, // Connect the Global Key
// //           title: 'Bold Bullion Portfolio',
// //           theme: AppTheme.lightTheme,
// //           home: const SplashScreen(),
// //           debugShowCheckedModeBanner: false,
// //         ),
// //       ),
// //     );
// //   }
// // }
