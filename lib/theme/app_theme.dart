import 'package:flutter/material.dart';

class AppTheme {
  static const String sansFamily = 'PlusJakartaSans';
  static const String displayFamily = 'Fraunces';

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

  static TextTheme _buildTextTheme(Color body, Color muted) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: displayFamily,
        fontWeight: FontWeight.w500,
        fontSize: 56,
        height: 1.05,
        letterSpacing: -1.2,
        color: body,
      ),
      displayMedium: TextStyle(
        fontFamily: displayFamily,
        fontWeight: FontWeight.w500,
        fontSize: 44,
        height: 1.08,
        letterSpacing: -0.9,
        color: body,
      ),
      displaySmall: TextStyle(
        fontFamily: displayFamily,
        fontWeight: FontWeight.w500,
        fontSize: 34,
        height: 1.12,
        letterSpacing: -0.6,
        color: body,
      ),
      headlineLarge: TextStyle(
        fontFamily: displayFamily,
        fontWeight: FontWeight.w500,
        fontSize: 28,
        height: 1.18,
        letterSpacing: -0.4,
        color: body,
      ),
      headlineMedium: TextStyle(
        fontFamily: sansFamily,
        fontWeight: FontWeight.w700,
        fontSize: 22,
        height: 1.22,
        letterSpacing: -0.3,
        color: body,
      ),
      headlineSmall: TextStyle(
        fontFamily: sansFamily,
        fontWeight: FontWeight.w700,
        fontSize: 18,
        height: 1.25,
        letterSpacing: -0.2,
        color: body,
      ),
      titleLarge: TextStyle(
        fontFamily: sansFamily,
        fontWeight: FontWeight.w700,
        fontSize: 17,
        height: 1.3,
        letterSpacing: -0.2,
        color: body,
      ),
      titleMedium: TextStyle(
        fontFamily: sansFamily,
        fontWeight: FontWeight.w600,
        fontSize: 15,
        height: 1.35,
        letterSpacing: -0.1,
        color: body,
      ),
      titleSmall: TextStyle(
        fontFamily: sansFamily,
        fontWeight: FontWeight.w600,
        fontSize: 13,
        height: 1.4,
        letterSpacing: 0,
        color: body,
      ),
      bodyLarge: TextStyle(
        fontFamily: sansFamily,
        fontWeight: FontWeight.w400,
        fontSize: 16,
        height: 1.5,
        letterSpacing: -0.1,
        color: body,
      ),
      bodyMedium: TextStyle(
        fontFamily: sansFamily,
        fontWeight: FontWeight.w400,
        fontSize: 14,
        height: 1.5,
        letterSpacing: 0,
        color: body,
      ),
      bodySmall: TextStyle(
        fontFamily: sansFamily,
        fontWeight: FontWeight.w400,
        fontSize: 12.5,
        height: 1.45,
        letterSpacing: 0.05,
        color: muted,
      ),
      labelLarge: TextStyle(
        fontFamily: sansFamily,
        fontWeight: FontWeight.w600,
        fontSize: 14,
        height: 1.2,
        letterSpacing: 0.1,
        color: body,
      ),
      labelMedium: TextStyle(
        fontFamily: sansFamily,
        fontWeight: FontWeight.w600,
        fontSize: 12,
        height: 1.2,
        letterSpacing: 0.2,
        color: body,
      ),
      labelSmall: TextStyle(
        fontFamily: sansFamily,
        fontWeight: FontWeight.w600,
        fontSize: 11,
        height: 1.2,
        letterSpacing: 0.4,
        color: muted,
      ),
    );
  }

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
    fontFamily: sansFamily,
    textTheme: _buildTextTheme(textPrimary, textSecondary),
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
        fontFamily: displayFamily,
        fontSize: 28,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.4,
        color: textPrimary,
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
          fontFamily: sansFamily,
          fontWeight: FontWeight.w700,
          fontSize: 15,
          letterSpacing: -0.1,
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
          fontFamily: sansFamily,
          fontWeight: FontWeight.w700,
          fontSize: 15,
          letterSpacing: -0.1,
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
    fontFamily: sansFamily,
    textTheme: _buildTextTheme(lightTextPrimary, lightTextSecondary),
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
        fontFamily: displayFamily,
        fontSize: 20,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.3,
        color: lightTextPrimary,
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
          fontFamily: sansFamily,
          fontWeight: FontWeight.w700,
          fontSize: 14,
          letterSpacing: -0.1,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black,
        side: const BorderSide(color: primaryGold, width: 2.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(
          fontFamily: sansFamily,
          fontWeight: FontWeight.w700,
          fontSize: 14,
          letterSpacing: -0.1,
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
