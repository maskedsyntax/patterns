import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryYellow = Color(0xFFFFD700); // Bright Yellow for Dark
  static const Color primaryGold = Color(0xFFB8960F); // Deep Gold for Light (readable on white)
  static const Color primaryAmber = Color(0xFFB45309); // Darker Amber (unused, kept for reference)
  
  // Refined Dark Palette
  static const Color darkBg = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF000000);
  static const Color darkTextPrimary = Color(0xFFF5F5F7);
  static const Color darkTextSecondary = Color(0xFF86868B);
  static const Color darkBorder = Color(0xFF2C2C2E);

  // Refined Light Palette
  static const Color lightBg = Color(0xFFFFFFFF); // Pure white background
  static const Color lightSurface = Color(0xFFFFFFFF); // Pure white surface
  static const Color lightTextPrimary = Color(0xFF1D1D1F);
  static const Color lightTextSecondary = Color(0xFF6E6E73);
  static const Color lightBorder = Color(0xFFD1D1D6);

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: primaryYellow,
      onPrimary: Colors.black,
      secondary: primaryYellow,
      surface: darkSurface,
      background: darkBg,
      onSurface: darkTextPrimary,
      onBackground: darkTextPrimary,
      outline: darkBorder,
    ),
    scaffoldBackgroundColor: darkBg,
    dividerColor: darkBorder,
    fontFamily: 'Inter',
    textTheme: const TextTheme().apply(
      bodyColor: darkTextPrimary,
      displayColor: darkTextPrimary,
      fontFamily: 'Inter',
    ),
    cardTheme: CardThemeData(
      color: darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: darkBorder, width: 1),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: darkTextPrimary,
        fontFamily: 'Inter',
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryYellow,
        foregroundColor: Colors.black,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.2, fontFamily: 'Inter'),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryYellow,
        side: const BorderSide(color: primaryYellow, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.2, fontFamily: 'Inter'),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryYellow, width: 2.0),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: primaryGold,
      onPrimary: Colors.black,
      secondary: primaryGold,
      surface: lightSurface,
      background: lightBg,
      onSurface: lightTextPrimary,
      onBackground: lightTextPrimary,
      outline: lightBorder,
    ),
    scaffoldBackgroundColor: lightBg,
    dividerColor: lightBorder,
    fontFamily: 'Inter',
    textTheme: const TextTheme().apply(
      bodyColor: lightTextPrimary,
      displayColor: lightTextPrimary,
      fontFamily: 'Inter',
    ),
    cardTheme: CardThemeData(
      color: lightSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: lightBorder, width: 1),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: lightBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: lightTextPrimary,
        fontFamily: 'Inter',
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGold,
        foregroundColor: Colors.black,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.2, fontFamily: 'Inter'),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black,
        side: const BorderSide(color: primaryGold, width: 2.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.2, fontFamily: 'Inter'),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryGold, width: 2.0),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );
}
