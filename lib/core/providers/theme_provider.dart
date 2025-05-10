import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode? _themeMode;

  ThemeMode get themeMode => _themeMode ?? ThemeMode.light;  // ✅ default to light

  bool get isDarkMode => themeMode == ThemeMode.dark;

  void toggleTheme() {
    if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.dark;
    }
    notifyListeners();
  }
}
