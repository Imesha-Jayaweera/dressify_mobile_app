import 'package:flutter/material.dart';
import 'pages/sign_up_page.dart';
import 'pages/sign_in_page.dart';
import 'pages/landing_page.dart';
import 'pages/image_analysis_page.dart';
import 'pages/body_measurement_page.dart';

void main() {
  runApp(const MyApp());
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
      },
    );
  }
}

