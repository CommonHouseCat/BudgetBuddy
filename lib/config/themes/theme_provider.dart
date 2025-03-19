import 'package:flutter/material.dart';
import 'light_mode.dart';
import 'dark_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*
* A ChangeNotifier that manages the application's theme (light or dark).
* */
class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData; // Current app theme
  bool _isDarkMode;

  // Constructor for ThemeProvider.
  ThemeProvider(this._isDarkMode)
  // Initialize the theme data based on the isDarkMode value.
      : _themeData = _isDarkMode ? darkMode : lightMode;

  // Getter for the current theme data.
  ThemeData get themeData => _themeData;

  // Getter for the current theme mode (dark or light).
  bool get isDarkMode => _isDarkMode;

  // Setter to change the current theme.
  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  /*
  * Toggle method better dark and light modes.
  * Updates the current theme and theme mode.
  * Saves the new theme setting to SharedPreferences.
  * */
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _themeData = _isDarkMode ? darkMode : lightMode;
    _saveThemeSetting(_isDarkMode);
    notifyListeners();
  }

  /*
  * Asynchronous method to save the theme setting to SharedPreferences.
  * */
  Future<void> _saveThemeSetting(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
  }
}
