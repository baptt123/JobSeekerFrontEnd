// lib/view_models/user/theme_view_model.dart
import 'package:flutter/material.dart';

class ThemeViewModel extends ChangeNotifier {
  // Mặc định là chế độ sáng
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme(bool isOn) {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // Báo cho toàn bộ App vẽ lại giao diện
  }
}