import 'package:flutter/material.dart';

// COMMON COLORS
const Color kBackgroundColor = Color(0xFFF6F0FA);
const Color kPrimaryPurple = Color(0xFF8E2DE2);
const Color kPrimaryPink = Color(0xFFEC008C);
const Color kBrandPurple = Color(0xFFB23BC7);
const Color kWhiteBackgroundColor = Color(0xFFFFFFFF);
const Color kInputBackground = Color(0xFFF4F4F4);
const Color kSelectorBackground = Color(0xFFF2F2F2);

// TEXT COLORS
const Color kPrimaryTextColor = Color(0xFF3A2E1F);
const Color kSecondaryTextColor = Color(0xFF55490D);
const Color kTernaryTextColor = Color(0xFF999999);
const Color kTextPrimary = Colors.black87;
const Color kTextSecondary = Colors.black54;
const Color kTextLight = Colors.white;

// GRADIENTS
const LinearGradient kPrimaryGradient = LinearGradient(
  colors: [kPrimaryPurple, kPrimaryPink],
);

// API CONFIGURATION
const SUCCESS_CODES = [200, 201];
const BASE_URL = 'http://localhost:3000';
const DEFAULT_ERROR_MSG = "Please contact system administrator.";

// ASSETS
const logo = "assets/images/logo.png";
const landing_bg = "assets/images/landing_bg.jpg";

// DIMENSIONS
const kDefaultHorizontalPadding = 12.0;
const kDefaultVerticalPadding = 12.0;
const kButtonPadding = 16.0;
const kDefaultRadius = 12.0;
const kDefaultMargin = 10.0;

// NAVIGATOR KEY
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();