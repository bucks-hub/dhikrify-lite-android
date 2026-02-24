import 'package:flutter/material.dart';

/// Strict black and white theme for Dhikrify app.
///
/// This theme enforces a minimalist design with only black (#000000)
/// and white (#FFFFFF) colors throughout the app.
class AppTheme {
  // Color constants
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  /// Main theme for the app
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Amiri',

      // Color scheme
      colorScheme: const ColorScheme.light(
        primary: black,
        onPrimary: white,
        secondary: black,
        onSecondary: white,
        surface: white,
        onSurface: black,
        error: black,
        onError: white,
      ),

      // Scaffold background
      scaffoldBackgroundColor: white,

      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: white,
        foregroundColor: black,
        elevation: 0,
        iconTheme: IconThemeData(color: black),
        titleTextStyle: TextStyle(
          color: black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Amiri',
        ),
      ),

      // Text theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: black, fontFamily: 'Amiri'),
        displayMedium: TextStyle(color: black, fontFamily: 'Amiri'),
        displaySmall: TextStyle(color: black, fontFamily: 'Amiri'),
        headlineLarge: TextStyle(color: black, fontFamily: 'Amiri'),
        headlineMedium: TextStyle(color: black, fontFamily: 'Amiri'),
        headlineSmall: TextStyle(color: black, fontFamily: 'Amiri'),
        titleLarge: TextStyle(color: black, fontFamily: 'Amiri'),
        titleMedium: TextStyle(color: black, fontFamily: 'Amiri'),
        titleSmall: TextStyle(color: black, fontFamily: 'Amiri'),
        bodyLarge: TextStyle(color: black, fontFamily: 'Amiri'),
        bodyMedium: TextStyle(color: black, fontFamily: 'Amiri'),
        bodySmall: TextStyle(color: black, fontFamily: 'Amiri'),
        labelLarge: TextStyle(color: black, fontFamily: 'Amiri'),
        labelMedium: TextStyle(color: black, fontFamily: 'Amiri'),
        labelSmall: TextStyle(color: black, fontFamily: 'Amiri'),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: black, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: black, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: black, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: black, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: black, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        labelStyle: const TextStyle(color: black, fontFamily: 'Amiri'),
        hintStyle: TextStyle(color: black.withValues(alpha: 0.5), fontFamily: 'Amiri'),
        filled: true,
        fillColor: white,
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: black,
          foregroundColor: white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(fontFamily: 'Amiri'),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: black,
          side: const BorderSide(color: black, width: 1),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(fontFamily: 'Amiri'),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: black,
          textStyle: const TextStyle(fontFamily: 'Amiri'),
        ),
      ),

      // FloatingActionButton theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: black,
        foregroundColor: white,
        elevation: 0,
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return black;
          }
          return white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return black.withValues(alpha: 0.5);
          }
          return black.withValues(alpha: 0.3);
        }),
        trackOutlineColor: WidgetStateProperty.all(black),
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: black, width: 1),
        ),
        titleTextStyle: const TextStyle(
          color: black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Amiri',
        ),
        contentTextStyle: const TextStyle(
          color: black,
          fontSize: 16,
          fontFamily: 'Amiri',
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: black, width: 1),
        ),
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: black,
        thickness: 1,
      ),

      // Icon theme
      iconTheme: const IconThemeData(color: black),
    );
  }
}
