import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WebTheme {
  static const Color primaryYellow = Color(0xFFFFD700);
  static const Color primaryGold = Color(0xFFB8960F);
  static const Color primaryAmber = Color(0xFFB45309);

  // Dark palette
  static const Color darkBg = Color(0xFF0A0A0A);
  static const Color darkSurface = Color(0xFF141414);
  static const Color darkSurfaceAlt = Color(0xFF1A1A1A);
  static const Color darkText = Color(0xFFF5F5F7);
  static const Color darkTextSecondary = Color(0xFF86868B);
  static const Color darkBorder = Color(0xFF2C2C2E);

  // Light palette
  static const Color lightBg = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceAlt = Color(0xFFF5F5F5);
  static const Color lightText = Color(0xFF1D1D1F);
  static const Color lightTextSecondary = Color(0xFF6E6E73);
  static const Color lightBorder = Color(0xFFE5E5EA);

  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: GoogleFonts.sourceSerif4(
        fontSize: 72,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        height: 1.05,
        color: primary,
      ),
      displayMedium: GoogleFonts.sourceSerif4(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        height: 1.1,
        color: primary,
      ),
      displaySmall: GoogleFonts.sourceSerif4(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        height: 1.15,
        color: primary,
      ),
      headlineMedium: GoogleFonts.sourceSerif4(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        color: primary,
      ),
      headlineSmall: GoogleFonts.nunitoSans(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleLarge: GoogleFonts.nunitoSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      bodyLarge: GoogleFonts.nunitoSans(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.7,
        color: secondary,
      ),
      bodyMedium: GoogleFonts.nunitoSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: secondary,
      ),
      labelLarge: GoogleFonts.nunitoSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
    );
  }

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primaryYellow,
      onPrimary: Colors.black,
      secondary: primaryYellow,
      surface: darkSurface,
      onSurface: darkText,
      outline: darkBorder,
    ),
    scaffoldBackgroundColor: darkBg,
    textTheme: _buildTextTheme(darkText, darkTextSecondary),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primaryGold,
      onPrimary: Colors.black,
      secondary: primaryGold,
      surface: lightSurface,
      onSurface: lightText,
      outline: lightBorder,
    ),
    scaffoldBackgroundColor: lightBg,
    textTheme: _buildTextTheme(lightText, lightTextSecondary),
  );
}
