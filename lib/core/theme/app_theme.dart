import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Pure Black and White theme - No other colors
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkGrey = Color(0xFF1A1A1A);
  static const Color lightGrey = Color(0xFFF5F5F5);

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
      backgroundColor: black,
      foregroundColor: white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: black),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: black, width: 2),
      ),
      labelStyle: const TextStyle(color: black),
      prefixIconColor: black,
      suffixIconColor: black,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: black,
      selectionColor: Color(0x33000000),
      selectionHandleColor: black,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: black,
        foregroundColor: white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: black,
        side: const BorderSide(color: black),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: black),
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
    scaffoldBackgroundColor: black,
    primaryColor: white,
    colorScheme: ColorScheme.dark(
      primary: white,
      onPrimary: black,
      secondary: white,
      onSecondary: black,
      surface: darkGrey,
      onSurface: white,
      background: black,
      onBackground: white,
      error: white,
      onError: black,
    ),
    textTheme: GoogleFonts.outfitTextTheme().apply(
      bodyColor: white,
      displayColor: white,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: black,
      foregroundColor: white,
    ),
    cardColor: darkGrey,
    iconTheme: const IconThemeData(color: white),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: white,
      foregroundColor: black,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: white),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: white, width: 2),
      ),
      labelStyle: const TextStyle(color: white),
      prefixIconColor: white,
      suffixIconColor: white,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: white,
      selectionColor: Color(0x33FFFFFF),
      selectionHandleColor: white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: white,
        foregroundColor: black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: white,
        side: const BorderSide(color: white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: white),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: white,
      contentTextStyle: TextStyle(color: black),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
