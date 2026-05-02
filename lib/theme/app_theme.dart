import 'package:flutter/material.dart';

class AppTheme {
  static const Color warmYellow = Color(0xFFF4C95D);
  static const Color deepCharcoal = Color(0xFF141414);
  static const Color charcoalCard = Color(0xFF1E1E1E);
  static const Color charcoalInput = Color(0xFF252525);
  static const Color softBorder = Color(0xFF343434);
  static const Color textPrimary = Color(0xFFF4F0E8);
  static const Color textSecondary = Color(0xFFA9A39A);
  static const Color mutedRed = Color(0xFFD26A6A);
  static const Color softGreen = Color(0xFF7BBF91);

  static const Color primaryGold = Color(0xFFB8960F);
  static const Color lightBg = Color(0xFFFBFAF7);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF1D1D1F);
  static const Color lightTextSecondary = Color(0xFF6E6E73);
  static const Color lightBorder = Color(0xFFE3DED4);

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: warmYellow,
      onPrimary: const Color(0xFF17130A),
      secondary: softGreen,
      error: mutedRed,
      surface: charcoalCard,
      onSurface: textPrimary,
      outline: softBorder,
    ),
    scaffoldBackgroundColor: deepCharcoal,
    dividerColor: softBorder,
    fontFamily: 'Inter',
    textTheme: const TextTheme().apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
      fontFamily: 'Inter',
    ),
    cardTheme: CardThemeData(
      color: charcoalCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: softBorder, width: 1),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: deepCharcoal,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        fontFamily: 'Inter',
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: warmYellow,
        foregroundColor: const Color(0xFF17130A),
        elevation: 0,
        minimumSize: const Size(0, 54),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontFamily: 'Inter',
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textPrimary,
        minimumSize: const Size(0, 54),
        side: const BorderSide(color: softBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontFamily: 'Inter',
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: charcoalInput,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: softBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: softBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: warmYellow, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: warmYellow,
      thumbColor: warmYellow,
      inactiveTrackColor: softBorder,
      overlayColor: Color(0x29F4C95D),
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
      onSurface: lightTextPrimary,
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
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          fontFamily: 'Inter',
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black,
        side: const BorderSide(color: primaryGold, width: 2.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          fontFamily: 'Inter',
        ),
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
