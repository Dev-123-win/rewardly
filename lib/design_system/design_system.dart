import 'package:flutter/material.dart';

class DesignSystem {
  // ============ COLOR PALETTE ============

  // Primary Colors
  static const Color primary = Color(0xFF8A2BE2);      // Blue Violet
  static const Color primaryLight = Color(0xFFA855F7); // Lighter purple
  static const Color primaryDark = Color(0xFF6B1FB8);  // Darker purple

  // Secondary Colors
  static const Color secondary = Color(0xFF4169E1);    // Royal Blue
  static const Color secondaryLight = Color(0xFF6B8FFF);
  static const Color secondaryDark = Color(0xFF1E40AF);

  // Semantic Colors
  static const Color success = Color(0xFF10B981);      // Green
  static const Color successLight = Color(0xFFD4EDDA);
  static const Color successDark = Color(0xFF065F46);

  static const Color warning = Color(0xFFF59E0B);      // Amber
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFF92400E);

  static const Color error = Color(0xFFEF4444);        // Red
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFF7F1D1D);

  static const Color info = Color(0xFF3B82F6);         // Blue
  static const Color infoLight = Color(0xFFDEF2F9);
  static const Color infoDark = Color(0xFF1E3A8A);

  // Neutral Colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF9FAFB);
  static const Color surfaceVariant = Color(0xFFF3F4F6);
  static const Color outline = Color(0xFFE5E7EB);
  static const Color outlineVariant = Color(0xFFD1D5DB);

  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textDisabled = Color(0xFFD1D5DB);

  // Accent Colors
  static const Color accent = Color(0xFFFFD700);       // Gold
  static const Color accentLight = Color(0xFFFFE55C);
  static const Color accentDark = Color(0xFFFBC02D);

  // ============ TYPOGRAPHY ============

  static const String fontPrimary = 'Poppins';
  static const String fontSecondary = 'Lato';

  // Display Styles
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontPrimary,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontPrimary,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.25,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontPrimary,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.33,
    letterSpacing: 0,
  );

  // Headline Styles
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontPrimary,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.15,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: 0.1,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0.15,
  );

  // Title Styles
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0.15,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.43,
    letterSpacing: 0.1,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontPrimary,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.33,
    letterSpacing: 0.1,
  );

  // Body Styles
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontSecondary,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.15,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontSecondary,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
    letterSpacing: 0.1,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontSecondary,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.33,
    letterSpacing: 0.4,
  );

  // Label Styles
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontSecondary,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.43,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontSecondary,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.33,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontSecondary,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.45,
    letterSpacing: 0.5,
  );

  // Overline Style
  static const TextStyle overline = TextStyle(
    fontFamily: fontSecondary,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.6,
    letterSpacing: 1.5,
  );

  // ============ SPACING SYSTEM (8dp Grid) ============

  static const double spacing0 = 0;
  static const double spacing1 = 4;
  static const double spacing2 = 8;
  static const double spacing3 = 12;
  static const double spacing4 = 16;
  static const double spacing5 = 20;
  static const double spacing6 = 24;
  static const double spacing7 = 32;
  static const double spacing8 = 40;
  static const double spacing9 = 48;
  static const double spacing10 = 56;

  // ============ BORDER RADIUS ============

  static const double radiusSmall = 8;
  static const double radiusMedium = 12;
  static const double radiusLarge = 16;
  static const double radiusXL = 20;
  static const double radiusXXL = 24;
  static const double radiusCircle = 999;

  // ============ SHADOWS ============

  static const BoxShadow shadowSmall = BoxShadow(
    color: Color(0x0A000000),
    blurRadius: 2,
    offset: Offset(0, 1),
  );

  static const BoxShadow shadowMedium = BoxShadow(
    color: Color(0x0F000000),
    blurRadius: 4,
    offset: Offset(0, 2),
  );

  static const BoxShadow shadowLarge = BoxShadow(
    color: Color(0x14000000),
    blurRadius: 8,
    offset: Offset(0, 4),
  );

  static const BoxShadow shadowXL = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 16,
    offset: Offset(0, 8),
  );

  // ============ ICON SYSTEM ============

  static const double iconSizeXS = 16;
  static const double iconSizeSmall = 20;
  static const double iconSizeMedium = 24;
  static const double iconSizeLarge = 32;
  static const double iconSizeXL = 40;
  static const double iconSizeXXL = 48;

  // ============ TOUCH TARGETS ============

  static const double minTouchSize = 48;
  static const double minTouchSizeCompact = 40;

  // ============ ANIMATION DURATIONS ============

  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
  static const Duration durationVerySlow = Duration(milliseconds: 800);

  // ============ GRADIENTS ============

  static const LinearGradient gradientPrimary = LinearGradient(
    colors: [Color(0xFF8A2BE2), Color(0xFF4169E1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientSuccess = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientWarning = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientError = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
