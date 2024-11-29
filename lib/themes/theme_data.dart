import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    primarySwatch: Colors.purple,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: Colors.blue,
      secondary: Colors.blueAccent,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      titleTextStyle: TextStyle(color: Colors.black), // Text color for light mode
    ),
    // Add more properties as needed
  );

  static final darkTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: Colors.blue,
      secondary: Colors.blueAccent,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.black, // Dark background for AppBar
      titleTextStyle: TextStyle(color: Colors.white), // Text color for dark mode
    ),
    // Add more properties as needed
  );

  // New default themes
  static final defaultTheme1 = ThemeData(
    primaryColor: Colors.red,
    brightness: Brightness.light,
  );

  static final defaultTheme2 = ThemeData(
    primaryColor: Colors.green,
    brightness: Brightness.light,
  );

  static final defaultTheme3 = ThemeData(
    primaryColor: Colors.orange,
    brightness: Brightness.light,
  );

  // New gradient theme
  static final gradientTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.light,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
  );

  // Default theme for reset
  static final resetTheme = lightTheme; // or any other theme you want to use for reset
}
