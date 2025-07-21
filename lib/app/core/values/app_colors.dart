import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primaryColor = Color(0xFF1976D2);
  static const Color primaryLightColor = Color(0xFF42A5F5);
  static const Color primaryDarkColor = Color(0xFF1565C0);
  static const Color accentColor = Color(0xFFFFA000);

  // Secondary colors
  static const Color secondaryColor = Color(0xFFFFA000);
  static const Color secondaryLightColor = Color(0xFFFFD54F);
  static const Color secondaryDarkColor = Color(0xFFFF8F00);

  // Text colors
  static const Color textLightColor = Color(0xFF757575);
  static const Color textDarkColor = Color(0xFFE0E0E0);
  static const Color textDarkLightColor = Color(0xFFAAAAAA);

  // Module-specific colors
  static const Color gateEntryColor = Color(0xFF4CAF50);
  static const Color weighbridgeColor = Color(0xFF2196F3);
  static const Color billingColor = Color(0xFFF44336);
  static const Color reportsColor = Color(0xFF9C27B0);


  // Background colors
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Colors.white;
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkSurfaceColor = Color(0xFF1E1E1E);

  // Text colors
  static const Color textColor = Color(0xFF212121);
  static const Color secondaryTextColor = Color(0xFF757575);
  static const Color darkTextColor = Color(0xFFE0E0E0);
  static const Color darkSecondaryTextColor = Color(0xFFAAAAAA);

  // Status colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color errorColor = Color(0xFFF44336);
  static const Color infoColor = Color(0xFF2196F3);

  // Border colors
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color darkBorderColor = Color(0xFF424242);

  // Divider colors
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color darkDividerColor = Color(0xFF424242);

  // Shimmer colors
  static const Color shimmerBaseColor = Color(0xFFE0E0E0);
  static const Color shimmerHighlightColor = Color(0xFFF5F5F5);
  static const Color darkShimmerBaseColor = Color(0xFF3A3A3A);
  static const Color darkShimmerHighlightColor = Color(0xFF4A4A4A);

  // Get color scheme for light theme
  static ColorScheme get lightColorScheme => const ColorScheme(
        primary: primaryColor,
        primaryContainer: primaryDarkColor,
        secondary: accentColor,
        secondaryContainer: Color(0xFFFFD54F),
        surface: surfaceColor,
        background: backgroundColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: textColor,
        onBackground: textColor,
        onError: Colors.white,
        brightness: Brightness.light,
      );

  // Get color scheme for dark theme
  static ColorScheme get darkColorScheme => const ColorScheme(
        primary: primaryColor,
        primaryContainer: primaryLightColor,
        secondary: accentColor,
        secondaryContainer: Color(0xFFFFD54F),
        surface: darkSurfaceColor,
        background: darkBackgroundColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: darkTextColor,
        onError: Colors.white,
        brightness: Brightness.dark,
      );
}

