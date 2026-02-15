// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/body_analysis_provider.dart';
import 'providers/order_provider.dart';
import 'providers/product_provider.dart';
import 'screens/landing_page.dart';
import 'screens/sign_up_page.dart';
import 'screens/sign_in_page.dart';
import 'screens/image_analysis_page.dart';
import 'screens/body_measurement_page.dart';
import 'screens/shopping_center_dashboard.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BodyAnalysisProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dressify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LandingPage(),
      routes: {
        '/landing': (context) => const LandingPage(),
        '/signup': (context) => const SignUpPage(),
        '/signin': (context) => const SignInPage(),
        '/image-analysis': (context) => const AIImageAnalyzerPage(),
        '/ai-image-analysis': (context) => const BodyMeasurementPage(),
        '/shopping-center-dashboard': (context) => const ShoppingCenterDashboard(),
      },
    );
  }
}