import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  // ---------- LIGHT THEME (DEFAULT) ----------
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      primaryColor: AppColors.primaryNavy,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryNavy,
        secondary: AppColors.celestialGold,
        surface: AppColors.lightCard,
        onSurface: AppColors.lightTextPrimary,
        onPrimary: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightCard,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.primaryNavy),
        titleTextStyle: GoogleFonts.cinzel(
          color: AppColors.primaryNavy,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightCard,
        selectedItemColor: AppColors.primaryNavy,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerColor: AppColors.lightDivider,
      textTheme: TextTheme(
        bodyLarge: GoogleFonts.lora(color: AppColors.lightTextPrimary),
        bodyMedium: GoogleFonts.lora(color: AppColors.lightTextPrimary),
        bodySmall: GoogleFonts.lora(color: AppColors.lightTextSecondary),
        titleLarge: GoogleFonts.cinzel(color: AppColors.lightTextPrimary),
        titleMedium: GoogleFonts.lora(color: AppColors.lightTextPrimary),
      ),
    );
  }

  // ---------- DARK THEME ----------
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.primaryNavy,
      primaryColor: AppColors.celestialGold,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.celestialGold,
        secondary: AppColors.celestialGold,
        surface: AppColors.cardNavy,
        onSurface: AppColors.textWhite,
        onPrimary: AppColors.primaryNavy,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryNavy,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textWhite),
        titleTextStyle: GoogleFonts.cinzel(
          color: AppColors.textWhite,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardNavy,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardNavy,
        selectedItemColor: AppColors.celestialGold,
        unselectedItemColor: AppColors.textGrey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerColor: Colors.white12,
      textTheme: TextTheme(
        bodyLarge: GoogleFonts.lora(color: AppColors.textWhite),
        bodyMedium: GoogleFonts.lora(color: AppColors.textWhite),
        bodySmall: GoogleFonts.lora(color: AppColors.textGrey),
        titleLarge: GoogleFonts.cinzel(color: AppColors.textWhite),
        titleMedium: GoogleFonts.lora(color: AppColors.textWhite),
      ),
    );
  }
}