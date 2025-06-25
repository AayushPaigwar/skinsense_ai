import 'package:flutter/material.dart';

// Light theme with teal/blue color scheme
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF26C6DA), // Teal from screenshot
    brightness: Brightness.light,
    primary: const Color(0xFF26C6DA),
    secondary: const Color(0xFF00BCD4),
    tertiary: const Color(0xFF4FC3F7),
    surface: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    foregroundColor: Color(0xFF26C6DA),
    titleTextStyle: TextStyle(
      color: Color(0xFF26C6DA),
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF26C6DA),
      foregroundColor: Colors.white,
      elevation: 2,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    shadowColor: Colors.grey.withOpacity(0.1),
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);

// Dark theme
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF26C6DA),
    brightness: Brightness.dark,
    primary: const Color(0xFF26C6DA),
    secondary: const Color(0xFF00BCD4),
    tertiary: const Color(0xFF4FC3F7),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    foregroundColor: Color(0xFF26C6DA),
  ),
);
