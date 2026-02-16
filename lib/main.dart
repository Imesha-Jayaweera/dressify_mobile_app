import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/body_analysis_provider.dart';
import 'providers/order_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/custom_order_provider.dart';
import 'screens/landing_page.dart';
import 'screens/sign_up_page.dart';
import 'screens/sign_in_page.dart';
import 'screens/image_analysis_page.dart';
import 'screens/shopping_center_dashboard.dart';
import 'screens/customer_dashboard.dart';
import 'screens/body_measurement_page.dart';
import 'screens/shop_page.dart';
import 'screens/cart_page.dart';
import 'screens/orders_page.dart';
import 'screens/tailor_dashboard.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BodyAnalysisProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => CustomOrderProvider()),
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
      onGenerateRoute: (settings) {
        // ✅ Handle customer dashboard with arguments
        if (settings.name == '/customer-dashboard') {
          final args = settings.arguments as Map<String, dynamic>?;
          final initialTab = args?['initialTab'] ?? 0;
          return MaterialPageRoute(
            builder: (context) => CustomerDashboard(initialTab: initialTab),
          );
        }

        switch (settings.name) {
          case '/landing':
            return MaterialPageRoute(builder: (context) => const LandingPage());
          case '/signup':
            return MaterialPageRoute(builder: (context) => const SignUpPage());
          case '/signin':
            return MaterialPageRoute(builder: (context) => const SignInPage());
          case '/image-analysis':
            return MaterialPageRoute(builder: (context) => const AIImageAnalyzerPage());
          case '/shopping-center-dashboard':
            return MaterialPageRoute(builder: (context) => const ShoppingCenterDashboard());
          case '/tailor-dashboard':
            return MaterialPageRoute(builder: (context) => const TailorDashboard());
          default:
            return MaterialPageRoute(builder: (context) => const LandingPage());

        }
      },
    );
  }
}