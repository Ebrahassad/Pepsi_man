import 'package:flutter/material.dart';

/// Central visual theme for Pepsi Runner. Original color palette —
/// not derived from any existing branded game.
class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFF1E88E5);
  static const Color secondary = Color(0xFFFF6D00);
  static const Color accent = Color(0xFFFFC107);
  static const Color background = Color(0xFF0D1B2A);
  static const Color surface = Color(0xFF1B263B);
  static const Color success = Color(0xFF43A047);
  static const Color danger = Color(0xFFE53935);
  static const Color textLight = Color(0xFFF5F5F5);
  static const Color textMuted = Color(0xFFB0BEC5);

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: danger,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: textLight,
          fontWeight: FontWeight.w900,
          fontSize: 40,
        ),
        headlineMedium: TextStyle(
          color: textLight,
          fontWeight: FontWeight.w800,
          fontSize: 26,
        ),
        titleMedium: TextStyle(
          color: textLight,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        bodyMedium: TextStyle(
          color: textMuted,
          fontSize: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondary,
          foregroundColor: textLight,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textLight,
      ),
    );
  }
}
