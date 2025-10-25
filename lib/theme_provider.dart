import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void setLightTheme() {
    _themeMode = ThemeMode.light;
    notifyListeners();
  }
}