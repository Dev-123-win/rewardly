import 'package:flutter/material.dart';

// Neuromorphic Colors
const Color kBackgroundColor = Color(0xFFE0E0E0); // Light grey
const Color kLightShadowColor = Color(0xFFFFFFFF); // White for top-left shadow
const Color kDarkShadowColor = Color(0xFFA7A7A7); // Dark grey for bottom-right shadow
const Color kPrimaryColor = Color(0xFF6200EE); // A primary accent color
const Color kAccentColor = Color(0xFF03DAC6); // An accent color
const Color kTextColor = Color(0xFF333333); // Dark text color
const Color kDisabledColor = Color(0xFFB0B0B0); // Color for disabled elements
const Color kSurfaceColor = kBackgroundColor; // Color for card surfaces

// Neuromorphic Dimensions
const double kDefaultPadding = 16.0;
const double kDefaultBorderRadius = 15.0;
const double kBlurRadius = 10.0;
const double kSpreadRadius = 2.0;

// Neuromorphic Box Shadows
const List<BoxShadow> kNeumorphicShadows = [
  BoxShadow(
    color: kDarkShadowColor,
    offset: Offset(5, 5),
    blurRadius: kBlurRadius,
    spreadRadius: kSpreadRadius,
  ),
  BoxShadow(
    color: kLightShadowColor,
    offset: Offset(-5, -5),
    blurRadius: kBlurRadius,
    spreadRadius: kSpreadRadius,
  ),
];

const List<BoxShadow> kNeumorphicPressedShadows = [
  BoxShadow(
    color: kDarkShadowColor,
    offset: Offset(2, 2),
    blurRadius: kBlurRadius,
    spreadRadius: kSpreadRadius,
  ),
  BoxShadow(
    color: kLightShadowColor,
    offset: Offset(-2, -2),
    blurRadius: kBlurRadius,
    spreadRadius: kSpreadRadius,
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
