import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryYellow = Color(0xFFFFD700);
  static const Color primaryYellowDark = Color(0xFFFFC107);
  
  // Dark Palette
  static const Color darkBg = Color(0xFF0F111A);
  static const Color darkSurface = Color(0xFF1B1E2B);
  static const Color darkTextPrimary = Color(0xFFE1E1E6);
  static const Color darkTextSecondary = Color(0xFFA1A1B2);

  // Light Palette
  static const Color lightBg = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF212529);
  static const Color lightTextSecondary = Color(0xFF6C757D);

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
    ),
    scaffoldBackgroundColor: darkBg,
    textTheme: GoogleFonts.interTextTheme().apply(
      bodyColor: darkTextPrimary,
      displayColor: darkTextPrimary,
    ),
    cardTheme: CardThemeData(
      color: darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: darkBg,
      selectedIconTheme: IconThemeData(color: primaryYellow),
      unselectedIconTheme: IconThemeData(color: darkTextSecondary),
      indicatorColor: Colors.transparent,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: darkBg,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: darkTextPrimary,
      ),
    ),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: primaryYellowDark,
      onPrimary: Colors.black,
      secondary: primaryYellowDark,
      surface: lightSurface,
      background: lightBg,
      onSurface: lightTextPrimary,
      onBackground: lightTextPrimary,
    ),
    scaffoldBackgroundColor: lightBg,
    textTheme: GoogleFonts.interTextTheme().apply(
      bodyColor: lightTextPrimary,
      displayColor: lightTextPrimary,
    ),
    cardTheme: CardThemeData(
      color: lightSurface,
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: lightBg,
      selectedIconTheme: IconThemeData(color: primaryYellowDark),
      unselectedIconTheme: IconThemeData(color: lightTextSecondary),
      indicatorColor: Colors.transparent,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: lightBg,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: lightTextPrimary,
      ),
    ),
  );
}
