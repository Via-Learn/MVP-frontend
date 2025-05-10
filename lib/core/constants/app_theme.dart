import 'package:flutter/material.dart';

class AppColors {
  // Common Colors
  static const Color primary = Color(0xFF5865F2);        // Discord blurple
  static const Color secondary = Colors.blueAccent;

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF2C2F33);
  static const Color darkSurface = Color(0xFF23272A);
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Colors.grey;
  static const Color darkInputFill = Color(0xFF40444B);

  // Light Mode Colors
  static const Color lightBackground = Color(0xFFF5F5F7);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF2C2F33);
  static const Color lightTextSecondary = Colors.grey;
  static const Color lightInputFill = Color(0xFFE0E0E0);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.darkBackground,
      primaryColor: AppColors.primary,
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        background: AppColors.darkBackground,
        surface: AppColors.darkSurface,
        onPrimary: Colors.white,
        onBackground: Colors.white,
        onSurface: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkInputFill,
        hintStyle: const TextStyle(color: AppColors.darkTextSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.darkTextPrimary),
        bodyMedium: TextStyle(fontSize: 16, color: AppColors.darkTextPrimary),
        bodySmall: TextStyle(fontSize: 14, color: AppColors.darkTextSecondary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.lightBackground,
      primaryColor: AppColors.primary,
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        background: AppColors.lightBackground,
        surface: AppColors.lightSurface,
        onPrimary: Colors.white,
        onBackground: AppColors.lightTextPrimary,
        onSurface: AppColors.lightTextPrimary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightInputFill,
        hintStyle: const TextStyle(color: AppColors.lightTextSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary),
        bodyMedium: TextStyle(fontSize: 16, color: AppColors.lightTextPrimary),
        bodySmall: TextStyle(fontSize: 14, color: AppColors.lightTextSecondary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightTextPrimary,
      ),
    );
  }
}
