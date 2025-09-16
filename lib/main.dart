import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/portfolio_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required for async in main()

  const envFile = String.fromEnvironment(
    'ENV_FILE',
    defaultValue:
        'assets/env/.env.stagging', // ✅ Make sure this matches your actual file path
  );

  try {
    await dotenv.load(fileName: envFile);
    debugPrint('✅ .env file loaded: $envFile');
    debugPrint('🔧 API_URL: ${dotenv.env['API_URL']}'); // Optional: for debug
  } catch (e) {
    debugPrint('❌ Failed to load .env file: $e');
  }

  runApp(const BoldPortfolioApp());
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
        title: 'BOLD Portfolio',
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
