import 'package:flutter/material.dart';

// Neuromorphic Colors
// Neuromorphic Colors (Purple, Blue, Gold Theme)
// Neuromorphic Colors (Subtle White Theme)
const Color kBackgroundColor = Colors.white; // White background
const Color kLightShadowColor = Color(0xFFF0F0F0); // Very light grey for top-left shadow
const Color kDarkShadowColor = Color(0xFFD0D0D0); // Light grey for bottom-right shadow
const Color kPrimaryColor = Color(0xFF6200EE); // Retain a primary accent color (Purple)
const Color kAccentColor = Color(0xFF03DAC6); // Retain an accent color (Teal)
const Color kTextColor = Color(0xFF333333); // Dark text color
const Color kDisabledColor = Color(0xFFE0E0E0); // Color for disabled elements
const Color kSurfaceColor = kBackgroundColor; // Color for card surfaces

// Neuromorphic Dimensions
const double kDefaultPadding = 16.0;
const double kDefaultBorderRadius = 15.0;
const double kBlurRadius = 8.0; // Slightly reduced blur for subtlety
const double kSpreadRadius = 1.0; // Reduced spread for subtlety

// Neuromorphic Box Shadows
const List<BoxShadow> kNeumorphicShadows = [
  BoxShadow(
    color: Colors.transparent,
    offset: Offset(0, 0),
    blurRadius: 0,
    spreadRadius: 0,
  ),
  BoxShadow(
    color: Colors.transparent,
    offset: Offset(0, 0),
    blurRadius: 0,
    spreadRadius: 0,
  ),
];

const List<BoxShadow> kNeumorphicPressedShadows = [
  BoxShadow(
    color: Colors.transparent,
    offset: Offset(0, 0),
    blurRadius: 0,
    spreadRadius: 0,
  ),
  BoxShadow(
    color: Colors.transparent,
    offset: Offset(0, 0),
    blurRadius: 0,
    spreadRadius: 0,
  ),
];

// Neuromorphic Box Decoration (function for dynamic use)
BoxDecoration kNeuromorphicBoxDecoration({
  required bool isPressed,
  double borderRadius = kDefaultBorderRadius,
  Color backgroundColor = kBackgroundColor,
}) {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(borderRadius),
    color: backgroundColor,
    boxShadow: isPressed ? kNeumorphicPressedShadows : kNeumorphicShadows,
  );
}
