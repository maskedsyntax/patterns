import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryYellow = Color(0xFFFFD700);
  static const Color primaryYellowDark = Color(0xFFFFC107);
  
  // Refined Dark Palette (Blackish)
  static const Color darkBg = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF111111);
  static const Color darkCard = Color(0xFF161616);
  static const Color darkTextPrimary = Color(0xFFF5F5F7);
  static const Color darkTextSecondary = Color(0xFF86868B);
  static const Color darkBorder = Color(0xFF2C2C2E);

  // Refined Light Palette
  static const Color lightBg = Color(0xFFFBFBFD);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF1D1D1F);
  static const Color lightTextSecondary = Color(0xFF86868B);
  static const Color lightBorder = Color(0xFFD2D2D7);

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
    textTheme: GoogleFonts.interTextTheme().apply(
      bodyColor: darkTextPrimary,
      displayColor: darkTextPrimary,
    ),
    cardTheme: CardThemeData(
      color: darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: darkBorder, width: 1),
      ),
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: darkBg,
      selectedIconTheme: IconThemeData(color: primaryYellow, size: 24),
      unselectedIconTheme: IconThemeData(color: darkTextSecondary, size: 24),
      indicatorColor: Colors.transparent,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: darkBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: darkTextPrimary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryYellow,
        foregroundColor: Colors.black,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
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
        borderSide: const BorderSide(color: primaryYellow, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
      outline: lightBorder,
    ),
    scaffoldBackgroundColor: lightBg,
    dividerColor: lightBorder,
    textTheme: GoogleFonts.interTextTheme().apply(
      bodyColor: lightTextPrimary,
      displayColor: lightTextPrimary,
    ),
    cardTheme: CardThemeData(
      color: lightSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: lightBorder, width: 1),
      ),
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: lightBg,
      selectedIconTheme: IconThemeData(color: primaryYellowDark, size: 24),
      unselectedIconTheme: IconThemeData(color: lightTextSecondary, size: 24),
      indicatorColor: Colors.transparent,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: lightBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: lightTextPrimary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryYellowDark,
        foregroundColor: Colors.black,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
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
        borderSide: const BorderSide(color: primaryYellowDark, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );
}
