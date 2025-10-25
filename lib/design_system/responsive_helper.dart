import 'package:flutter/material.dart';

class ResponsiveHelper {
  static const double breakpointSmall = 600;
  static const double breakpointMedium = 900;
  static const double breakpointLarge = 1200;

  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < breakpointSmall;
  }

  static bool isMediumScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= breakpointSmall &&
        MediaQuery.of(context).size.width < breakpointMedium;
  }

  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= breakpointMedium;
  }

  static double getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < breakpointSmall) return 16;
    if (width < breakpointMedium) return 24;
    return width * 0.1;
  }

  static int getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < breakpointSmall) return 2;
    if (width < breakpointMedium) return 3;
    return 4;
  }

  static double getCardHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < breakpointSmall) return 180;
    if (width < breakpointMedium) return 200;
    return 220;
  }

  static double getFontScale(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < breakpointSmall) return 1.0;
    if (width < breakpointMedium) return 1.1;
    return 1.2;
  }
}
