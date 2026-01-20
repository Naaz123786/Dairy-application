import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Pure Black and White theme - No other colors
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkGrey = Color(0xFF1A1A1A);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color darkBackground = Color(0xFF121212);

  static final ThemeData lightTheme = _buildTheme(
    brightness: Brightness.light,
    primary: black,
    secondary: black,
    background: white,
    accent: Colors.cyan,
  );

  static final ThemeData darkTheme = _buildTheme(
    brightness: Brightness.dark,
    primary: white,
    secondary: white,
    background: darkBackground,
    accent: Colors.cyan,
  );

  // Love Theme: Pink and Red
  static final ThemeData loveTheme = _buildTheme(
    brightness: Brightness.light,
    primary: const Color(0xFFD81B60),
    secondary: const Color(0xFFF06292),
    background: const Color(0xFFFFF1F8),
    accent: const Color(0xFFFF4081),
  );

  // Anime Theme: Vibrant Cel-shaded
  static final ThemeData animeTheme = _buildTheme(
    brightness: Brightness.dark,
    primary: const Color(0xFF00E5FF),
    secondary: const Color(0xFFFFD600),
    background: const Color(0xFF1A1A2E),
    accent: const Color(0xFF7B1FA2),
  );

  // Flower Theme: Pastel Greens and Florals
  static final ThemeData flowerTheme = _buildTheme(
    brightness: Brightness.light,
    primary: const Color(0xFF2E7D32),
    secondary: const Color(0xFF81C784),
    background: const Color(0xFFF1F8E9),
    accent: const Color(0xFFF06292),
  );

  // Firetail Theme: Deep Orange and Coal
  static final ThemeData firetailTheme = _buildTheme(
    brightness: Brightness.dark,
    primary: const Color(0xFFFF6D00),
    secondary: const Color(0xFFFFAB40),
    background: const Color(0xFF0D0D0D),
    accent: const Color(0xFFD50000),
  );

  // Heroism Theme: Royal Gold and Navy
  static final ThemeData heroismTheme = _buildTheme(
    brightness: Brightness.dark,
    primary: const Color(0xFFFFD700),
    secondary: const Color(0xFFC0C0C0),
    background: const Color(0xFF001F3F),
    accent: const Color(0xFF0074D9),
  );

  // Good vs Evil Theme: High Contrast Split
  static final ThemeData goodVsEvilTheme = _buildTheme(
    brightness: Brightness.dark,
    primary: white,
    secondary: black,
    background: const Color(0xFF0F0F0F),
    accent: Colors.redAccent,
  );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color primary,
    required Color secondary,
    required Color background,
    required Color accent,
  }) {
    final bool isDark = brightness == Brightness.dark;
    final Color textColor = isDark ? white : black;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: isDark ? black : white,
        secondary: secondary,
        onSecondary: isDark ? black : white,
        surface: isDark ? darkGrey : white,
        onSurface: textColor,
        background: background,
        onBackground: textColor,
        error: Colors.redAccent,
        onError: white,
      ),
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: textColor,
        displayColor: textColor,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: background,
        foregroundColor: textColor,
      ),
      cardColor: isDark ? darkGrey : white,
      iconTheme: IconThemeData(color: textColor),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accent, width: 2),
        ),
        labelStyle: TextStyle(color: accent),
        prefixIconColor: accent,
        suffixIconColor: accent,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: accent,
        selectionColor: accent.withOpacity(0.2),
        selectionHandleColor: accent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: BorderSide(color: accent),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: accent),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? white : black,
        contentTextStyle: TextStyle(color: isDark ? black : white),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData getTheme(String themeKey) {
    switch (themeKey) {
      case 'dark':
        return darkTheme;
      case 'love':
        return loveTheme;
      case 'anime':
        return animeTheme;
      case 'flower':
        return flowerTheme;
      case 'firetail':
        return firetailTheme;
      case 'heroism':
        return heroismTheme;
      case 'goodvsevil':
        return goodVsEvilTheme;
      case 'light':
      default:
        return lightTheme;
    }
  }
}
