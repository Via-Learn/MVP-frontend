import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF5865F2);        // Discord blurple
  static const Color background = Color(0xFF2C2F33);     // Dark gray background
  static const Color surface = Color(0xFF23272A);        // Slightly darker containers
  static const Color textPrimary = Colors.white;         // Main white text
  static const Color textSecondary = Colors.grey;        // Light gray text
  static const Color buttonFill = Color(0xFF5865F2);     // Same as primary
  static const Color inputFill = Color(0xFF40444B);       // Input box gray
  static const Color secondary = Colors.blueAccent;
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        background: AppColors.background,
        surface: AppColors.surface,
        onPrimary: Colors.white,
        onBackground: Colors.white,
        onSurface: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonFill,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFill,
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        bodyMedium: TextStyle(fontSize: 16, color: AppColors.textPrimary),
        bodySmall: TextStyle(fontSize: 14, color: AppColors.textSecondary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
    );
  }
}
