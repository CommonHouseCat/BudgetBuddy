import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*
* A ChangeNotifier that manages the application's locale.
* */
class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('en'); // Current app locale

  Locale get locale => _locale; // Getter for the current locale

  LocaleProvider() { // Constructor for LocaleProvider
    _loadLocale(); // Load the current locale from SharedPreferences
  }

  /*
  * A method for setting a new locale (only 'en' and 'vi' are supported).
  * If the new locale is supported, updates the current locale and saves to SharedPreferences.
  * Otherwise does nothing.
  * */
  void setLocale(Locale newLocale) {
    if (!['en', 'vi'].contains(newLocale.languageCode)) return;
    _locale = newLocale;
    _saveLocale(newLocale.languageCode);
    notifyListeners();
  }

  /*
  * Asynchronous method to load the current locale from SharedPreferences.
  * If locale is found, updates the current locale.
  * Otherwise sets the default locale (English).
  * Notifies listeners of the change.
  * */
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language') ?? 'en';
    _locale = Locale(languageCode);
    notifyListeners();
  }

  /*
  * Asynchronous method to save the current locale to SharedPreferences.
  * Takes a language code (either 'en' or 'vi') and saves it to SharedPreferences.
  * */
  Future<void> _saveLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);
  }
}
