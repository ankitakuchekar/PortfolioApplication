import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart'; // Import flutter_dotenv
import 'providers/auth_provider.dart';
import 'providers/portfolio_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  const envFile = String.fromEnvironment(
    'ENV_FILE',
    defaultValue: 'env/.env.stagging',
  );
  await dotenv.load(fileName: envFile);
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
