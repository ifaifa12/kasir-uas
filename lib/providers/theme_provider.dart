import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      final window = WidgetsBinding.instance.platformDispatcher;
      return window.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  ThemeProvider() {
    _loadSettings();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _saveSettings();
    notifyListeners();
  }

  _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? modeStr = prefs.getString('themeMode');
    if (modeStr != null) {
      _themeMode = ThemeMode.values.firstWhere((e) => e.toString() == modeStr, orElse: () => ThemeMode.system);
    }
    notifyListeners();
  }

  _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('themeMode', _themeMode.toString());
  }
}
