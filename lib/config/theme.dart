import 'package:flutter/material.dart';

class AppTheme {
  // Primary colors
  static const Color primaryColor = Color(0xFF8BBEE8); // Light pastel blue
  static const Color secondaryColor = Color(0xFFA7D7C5); // Soft mint green
  static const Color accentColor = Color(0xFFF9C8C8); // Soft peach

  // Background colors
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color surfaceColor = Colors.white;

  // Text colors
  static const Color textPrimaryColor = Color(0xFF2C3E50);
  static const Color textSecondaryColor = Color(0xFF7F8C8D);
  static const Color textLightColor = Color(0xFFBDC3C7);

  // Status colors
  static const Color successColor = Color(0xFF93D7AF); // Pastel green
  static const Color errorColor = Color(0xFFF8AFA6); // Pastel red
  static const Color warningColor = Color(0xFFFADAA3); // Pastel yellow
  static const Color infoColor = Color(0xFFA3BFFA); // Pastel blue

  // Sizing
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double buttonHeight = 52.0;

  // Font sizes
  static const double fontSizeSmall = 12.0;
  static const double fontSizeRegular = 14.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 18.0;
  static const double fontSizeXLarge = 24.0;

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      background: backgroundColor,
      error: errorColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        minimumSize: const Size(double.infinity, buttonHeight),
        side: const BorderSide(color: primaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: textLightColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: errorColor),
      ),
      hintStyle: const TextStyle(color: textLightColor),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: textPrimaryColor, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: textPrimaryColor, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(color: textPrimaryColor, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: textPrimaryColor, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(color: textPrimaryColor, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: textPrimaryColor, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: textPrimaryColor),
      titleSmall: TextStyle(color: textSecondaryColor),
      bodyLarge: TextStyle(color: textPrimaryColor),
      bodyMedium: TextStyle(color: textPrimaryColor),
      bodySmall: TextStyle(color: textSecondaryColor),
      labelLarge: TextStyle(color: textPrimaryColor, fontWeight: FontWeight.w500),
    ),
  );
}