import 'package:flutter/material.dart';
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
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightCard,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.primaryNavy),
        titleTextStyle: TextStyle(
          color: AppColors.primaryNavy,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightCard,
        selectedItemColor: AppColors.primaryNavy,
        unselectedItemColor: Colors.grey,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.lightTextPrimary),
        bodyMedium: TextStyle(color: AppColors.lightTextPrimary),
        bodySmall: TextStyle(color: AppColors.lightTextSecondary),
        titleLarge: TextStyle(color: AppColors.lightTextPrimary),
        titleMedium: TextStyle(color: AppColors.lightTextPrimary),
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
        surface: AppColors.cardNavy,
        onSurface: AppColors.textWhite,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryNavy,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textWhite,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardNavy,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardNavy,
        selectedItemColor: AppColors.celestialGold,
        unselectedItemColor: AppColors.textGrey,
      ),
    );
  }
}