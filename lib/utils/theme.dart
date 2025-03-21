import 'package:flutter/material.dart';

/// **AppTheme Class**
/// Defines a centralized theme for the entire application.
class AppTheme {
  /// **Main Theme Data**
  static final ThemeData themeData = ThemeData(
    primaryColor: Colors.teal,
    scaffoldBackgroundColor: Colors.grey[200],

    // Text Theme
    textTheme: TextTheme(
      bodyLarge: TextStyle(fontFamily: 'Roboto', color: Colors.black),
      bodyMedium: TextStyle(fontFamily: 'Roboto', color: Colors.black87),
    ),

    // Color Scheme
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: Colors.teal, // Primary color (teal)
      secondary: Colors.amber, // Secondary color (amber)
      background: Colors.grey[200], // Light gray background
      surface: Colors.white, // White cards
      onBackground: Colors.black87, // Dark gray text
      onSurface: Colors.black87, // Dark gray text
      onPrimary: Colors.white,
      onSecondary: Colors.white,
    ),

    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.teal,
      foregroundColor: Colors.white,
      elevation: 4,
    ),

    // Button Styles
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),

    // Input Field Styles
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.teal, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      labelStyle: TextStyle(color: Colors.black87),
      prefixIconColor: Colors.teal,
    ),
  );
}
