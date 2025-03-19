import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*
* A ChangeNotifier that manages the application's currency symbol.
* */
class CurrencyProvider with ChangeNotifier {
  String _currencySymbol = '\$'; // Current currency symbol

  // Getter for the currency symbol
  String get currencySymbol => _currencySymbol;

  // Constructor to load the current currency symbol
  CurrencyProvider() {
    _loadLocale();
  }

  // Setter for the currency symbol
  void setCurrencySymbol(String symbol) {
    _currencySymbol = symbol;
    _saveCurrency(symbol);
    notifyListeners();
  }

  /*
  * Asynchronous method to load the saved currency from persistent storage.
  * If a currency is found, set as the current currency symbol.
  * Otherwise defaults to '$'.
  * */
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final currencySymbol = prefs.getString('currency') ?? '\$';
    _currencySymbol = currencySymbol;
    notifyListeners();
  }

  /*
  * Asynchronous method to save the current currency symbol to persistent storage.
  * */
  Future<void> _saveCurrency(String symbol) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', symbol);
  }
}
