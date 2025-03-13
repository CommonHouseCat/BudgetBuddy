import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyProvider with ChangeNotifier {
  String _currencySymbol = '\$'; // Default currency symbol

  String get currencySymbol => _currencySymbol;

  CurrencyProvider() {
    _loadLocale();
  }

  void setCurrencySymbol(String symbol) {
    _currencySymbol = symbol;
    _saveCurrency(symbol);
    notifyListeners();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final currencySymbol = prefs.getString('currency') ?? '\$';
    _currencySymbol = currencySymbol;
    notifyListeners();
  }

  Future<void> _saveCurrency(String symbol) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', symbol);
  }
}
