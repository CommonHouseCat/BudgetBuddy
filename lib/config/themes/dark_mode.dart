import 'package:flutter/material.dart';

/*
* A ThemeData instance that defines the dark mode theme for the application.
*/
ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.dark(
    surface: Colors.grey.shade900, // background
    primary: Colors.grey.shade600,
    secondary: Colors.grey.shade700,
    tertiary: Colors.grey.shade800,
    inversePrimary: Colors.grey.shade300,
  ),
);
