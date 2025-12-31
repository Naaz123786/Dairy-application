import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Pure Black and White theme - No other colors
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkGrey = Color(0xFF1A1A1A);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color darkBackground = Color(0xFF121212);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: white,
    primaryColor: black,
    colorScheme: ColorScheme.light(
      primary: black,
      onPrimary: white,
      secondary: black,
      onSecondary: white,
      surface: white,
      onSurface: black,
      background: white,
      onBackground: black,
      error: black,
      onError: white,
    ),
    textTheme: GoogleFonts.outfitTextTheme().apply(
      bodyColor: black,
      displayColor: black,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: white,
      foregroundColor: black,
    ),
    cardColor: white,
    iconTheme: const IconThemeData(color: black),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.cyan,
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.cyan),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.cyan, width: 2),
      ),
      labelStyle: const TextStyle(color: Colors.cyan),
      prefixIconColor: Colors.cyan,
      suffixIconColor: Colors.cyan,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Colors.cyan,
      selectionColor: Color(0x3300BCD4),
      selectionHandleColor: Colors.cyan,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.cyan,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.cyan,
        side: const BorderSide(color: Colors.cyan),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: Colors.cyan),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: black,
      contentTextStyle: TextStyle(color: white),
      behavior: SnackBarBehavior.floating,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    primaryColor: white,
    colorScheme: ColorScheme.dark(
      primary: white,
      onPrimary: black,
      secondary: white,
      onSecondary: black,
      surface: darkGrey,
      onSurface: white,
      background: darkBackground,
      onBackground: white,
      error: Colors.redAccent,
      onError: white,
    ),
    textTheme: GoogleFonts.outfitTextTheme().apply(
      bodyColor: white,
      displayColor: white,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: darkBackground,
      foregroundColor: white,
    ),
    cardColor: darkGrey,
    iconTheme: const IconThemeData(color: white),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.cyan,
      foregroundColor: white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.cyan),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.cyan, width: 2),
      ),
      labelStyle: const TextStyle(color: Colors.cyan),
      prefixIconColor: Colors.cyan,
      suffixIconColor: Colors.cyan,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Colors.cyan,
      selectionColor: Color(0x3300BCD4), // Cyan with opacity
      selectionHandleColor: Colors.cyan,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.cyan,
        foregroundColor: white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.cyan,
        side: const BorderSide(color: Colors.cyan),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: Colors.cyan),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: white,
      contentTextStyle: TextStyle(color: black),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
