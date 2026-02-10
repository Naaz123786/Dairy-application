import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme_model.dart';
import 'package:diary_app/presentation/widgets/animations/particle_system.dart';

class AppTheme {
  // Common Colors
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkGrey = Color(0xFF1A1A1A);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color darkBackground = Color(0xFF121212);

  static final List<AppThemeCategory> themePacks = [
    AppThemeCategory(
      id: 'classic',
      name: 'Classic Pack',
      icon: Icons.dashboard_customize,
      animationPath: 'assets/animations/light.json',
      backgroundColor: const Color(0xFFE0E0E0),
      variants: [
        _createVariant('classic', 'classic_light', 'Classic Light',
            Brightness.light, black, white, Colors.cyan, ParticleType.circle),
        _createVariant(
            'classic',
            'classic_dark',
            'Classic Dark',
            Brightness.dark,
            white,
            darkBackground,
            Colors.cyan,
            ParticleType.circle),
        _createVariant(
            'classic',
            'classic_silver',
            'Silver Minimal',
            Brightness.light,
            const Color(0xFF607D8B),
            Colors.white,
            Colors.grey,
            ParticleType.circle),
        _createVariant(
            'classic',
            'classic_midnight',
            'Midnight Blue',
            Brightness.dark,
            Colors.blueAccent,
            const Color(0xFF010A1A),
            Colors.blue,
            ParticleType.circle),
        _createVariant(
            'classic',
            'classic_sepia',
            'Vintage Sepia',
            Brightness.light,
            const Color(0xFF5D4037),
            const Color(0xFFEFEBE9),
            const Color(0xFF8D6E63),
            ParticleType.circle),
        _createVariant(
            'classic',
            'classic_charcoal',
            'Deep Charcoal',
            Brightness.dark,
            const Color(0xFFB0BEC5),
            const Color(0xFF212121),
            const Color(0xFF455A64),
            ParticleType.circle),
        _createVariant(
            'classic',
            'classic_slate',
            'Slate Grey',
            Brightness.dark,
            const Color(0xFF90A4AE),
            const Color(0xFF263238),
            const Color(0xFF607D8B),
            ParticleType.circle),
        _createVariant(
            'classic',
            'classic_cream',
            'Creamy White',
            Brightness.light,
            const Color(0xFF795548),
            const Color(0xFFFFF8E1),
            const Color(0xFFD7CCC8),
            ParticleType.circle),
        _createVariant(
            'classic',
            'classic_onyx',
            'Onyx Black',
            Brightness.dark,
            Colors.white70,
            const Color(0xFF000000),
            Colors.grey,
            ParticleType.circle),
        _createVariant(
            'classic',
            'classic_paper',
            'Old Paper',
            Brightness.light,
            const Color(0xFF3E2723),
            const Color(0xFFF5F5DC),
            const Color(0xFF8B4513),
            ParticleType.circle),
        _createVariant(
            'classic',
            'classic_forest',
            'Forest Dark',
            Brightness.dark,
            const Color(0xFF81C784),
            const Color(0xFF1B5E20),
            const Color(0xFF388E3C),
            ParticleType.petal),
        _createVariant(
            'classic',
            'classic_ocean',
            'Ocean Depths',
            Brightness.dark,
            const Color(0xFF4FC3F7),
            const Color(0xFF01579B),
            const Color(0xFF0288D1),
            ParticleType.circle),
      ],
    ),
    AppThemeCategory(
      id: 'anime',
      name: 'Anime Vibe',
      icon: Icons.bolt,
      animationPath: 'assets/animations/anime.json',
      backgroundColor: const Color(0xFF004D40),
      variants: [
        _createVariant(
            'anime',
            'anime_neon',
            'Cyber Neon',
            Brightness.dark,
            const Color(0xFF00E5FF),
            const Color(0xFF0F051D),
            const Color(0xFF7B1FA2),
            ParticleType.star),
        _createVariant(
            'anime',
            'anime_mecha',
            'Mecha Steel',
            Brightness.dark,
            const Color(0xFFFF3D00),
            const Color(0xFF263238),
            const Color(0xFFB0BEC5),
            ParticleType.star),
        _createVariant(
            'anime',
            'anime_sakura',
            'Sakura Pink',
            Brightness.light,
            const Color(0xFFF06292),
            const Color(0xFFFCE4EC),
            const Color(0xFFFF80AB),
            ParticleType.petal),
        _createVariant(
            'anime',
            'anime_void',
            'Abyssal Void',
            Brightness.dark,
            const Color(0xFF7E57C2),
            const Color(0xFF000000),
            const Color(0xFF311B92),
            ParticleType.star),
        _createVariant(
            'anime',
            'anime_solar',
            'Solar Flare',
            Brightness.light,
            const Color(0xFFFF6D00),
            const Color(0xFFFFF3E0),
            const Color(0xFFFFAB40),
            ParticleType.circle),
        _createVariant(
            'anime',
            'anime_ocean',
            'Aqua Blue',
            Brightness.light,
            const Color(0xFF00B0FF),
            const Color(0xFFE1F5FE),
            const Color(0xFF40C4FF),
            ParticleType.circle),
        _createVariant(
            'anime',
            'anime_forest',
            'Spirit Forest',
            Brightness.dark,
            const Color(0xFF69F0AE),
            const Color(0xFF004D40),
            const Color(0xFF00E676),
            ParticleType.petal),
        _createVariant(
            'anime',
            'anime_blood',
            'Crimson Moon',
            Brightness.dark,
            const Color(0xFFFF5252),
            const Color(0xFF210000),
            const Color(0xFFFF1744),
            ParticleType.ember),
        _createVariant(
            'anime',
            'anime_gold',
            'Golden Age',
            Brightness.dark,
            const Color(0xFFFFD700),
            const Color(0xFF3E2723),
            const Color(0xFFFFAB00),
            ParticleType.star),
        _createVariant(
            'anime',
            'anime_silver',
            'Silver Soul',
            Brightness.light,
            const Color(0xFF78909C),
            const Color(0xFFECEFF1),
            const Color(0xFFB0BEC5),
            ParticleType.circle),
      ],
    ),
    AppThemeCategory(
      id: 'love',
      name: 'Love & Romance',
      icon: Icons.favorite,
      animationPath: 'assets/animations/hearts.json',
      backgroundColor: const Color(0xFF880E4F),
      variants: [
        _createVariant(
            'love',
            'love_rose',
            'Rose Petal',
            Brightness.light,
            const Color(0xFFE91E63),
            const Color(0xFFFFEBEE),
            const Color(0xFFF48FB1),
            ParticleType.heart),
        _createVariant(
            'love',
            'love_midnight',
            'Midnight Romance',
            Brightness.dark,
            const Color(0xFFAD1457),
            const Color(0xFF3E0024),
            const Color(0xFF880E4F),
            ParticleType.heart),
        _createVariant(
            'love',
            'love_sunset',
            'Sunset Love',
            Brightness.light,
            const Color(0xFFFF4081),
            const Color(0xFFFFF0F5),
            const Color(0xFFFF80AB),
            ParticleType.heart),
        _createVariant(
            'love',
            'love_lavender',
            'Lavender Dream',
            Brightness.light,
            const Color(0xFFAB47BC),
            const Color(0xFFF3E5F5),
            const Color(0xFFCE93D8),
            ParticleType.heart),
        _createVariant(
            'love',
            'love_peach',
            'Sweet Peach',
            Brightness.light,
            const Color(0xFFFF6E40),
            const Color(0xFFFBE9E7),
            const Color(0xFFFF9E80),
            ParticleType.heart),
        _createVariant(
            'love',
            'love_sky',
            'Cloud Nine',
            Brightness.light,
            const Color(0xFF29B6F6),
            const Color(0xFFE1F5FE),
            const Color(0xFF81D4FA),
            ParticleType.heart),
        _createVariant(
            'love',
            'love_ruby',
            'Ruby Passion',
            Brightness.dark,
            const Color(0xFFD50000),
            const Color(0xFF1A0000),
            const Color(0xFFFF5252),
            ParticleType.heart),
        _createVariant(
            'love',
            'love_gold',
            'Golden Heart',
            Brightness.light,
            const Color(0xFFA00000),
            const Color(0xFFFFF8E1),
            const Color(0xFFFFD54F),
            ParticleType.heart),
        _createVariant(
            'love',
            'love_night',
            'Starry Night',
            Brightness.dark,
            const Color(0xFF6A1B9A),
            const Color(0xFF120021),
            const Color(0xFFBA68C8),
            ParticleType.heart),
        _createVariant(
            'love',
            'love_classic',
            'Classic Valentine',
            Brightness.light,
            const Color(0xFFC62828),
            const Color(0xFFFFEBEE),
            const Color(0xFFEF5350),
            ParticleType.heart),
      ],
    ),
    AppThemeCategory(
      id: 'flower',
      name: 'Floral Garden',
      icon: Icons.local_florist,
      animationPath: 'assets/animations/flowers.json',
      backgroundColor: const Color(0xFF1B5E20),
      variants: [
        _createVariant(
            'flower',
            'flower_sakura',
            'Cherry Blossom',
            Brightness.light,
            const Color(0xFFF06292),
            const Color(0xFFFFEBEE),
            const Color(0xFFF8BBD0),
            ParticleType.petal),
        _createVariant(
            'flower',
            'flower_sunflower',
            'Sunny Field',
            Brightness.light,
            const Color(0xFFFBC02D),
            const Color(0xFFFFFDE7),
            const Color(0xFFFFF59D),
            ParticleType.petal),
        _createVariant(
            'flower',
            'flower_lavender',
            'Lavender Field',
            Brightness.light,
            const Color(0xFF7E57C2),
            const Color(0xFFEDE7F6),
            const Color(0xFFB39DDB),
            ParticleType.petal),
        _createVariant(
            'flower',
            'flower_mint',
            'Mint Garden',
            Brightness.light,
            const Color(0xFF26A69A),
            const Color(0xFFE0F2F1),
            const Color(0xFF80CBC4),
            ParticleType.petal),
        _createVariant(
            'flower',
            'flower_rose',
            'Red Rose',
            Brightness.dark,
            const Color(0xFFD32F2F),
            const Color(0xFF1A0000),
            const Color(0xFFEF5350),
            ParticleType.petal),
        _createVariant(
            'flower',
            'flower_orchid',
            'Blue Orchid',
            Brightness.dark,
            const Color(0xFF42A5F5),
            const Color(0xFF0D47A1),
            const Color(0xFF90CAF9),
            ParticleType.petal),
        _createVariant(
            'flower',
            'flower_tulip',
            'Purple Tulip',
            Brightness.dark,
            const Color(0xFFAB47BC),
            const Color(0xFF210030),
            const Color(0xFFCE93D8),
            ParticleType.petal),
        _createVariant(
            'flower',
            'flower_forest',
            'Deep Forest',
            Brightness.dark,
            const Color(0xFF66BB6A),
            const Color(0xFF1B5E20),
            const Color(0xFFA5D6A7),
            ParticleType.petal),
        _createVariant(
            'flower',
            'flower_daisy',
            'White Daisy',
            Brightness.light,
            const Color(0xFFFDD835),
            const Color(0xFFFAFAFA),
            const Color(0xFFFFF59D),
            ParticleType.petal),
        _createVariant(
            'flower',
            'flower_lotus',
            'Pink Lotus',
            Brightness.light,
            const Color(0xFFEC407A),
            const Color(0xFFFCE4EC),
            const Color(0xFFF48FB1),
            ParticleType.petal),
      ],
    ),
    AppThemeCategory(
      id: 'firetail',
      name: 'Firetail',
      icon: Icons.whatshot,
      animationPath: 'assets/animations/fire.json',
      backgroundColor: const Color(0xFF3E2723),
      variants: [
        _createVariant(
            'firetail',
            'fire_inferno',
            'Inferno',
            Brightness.dark,
            const Color(0xFFFF5722),
            const Color(0xFF210000),
            const Color(0xFFFFAB91),
            ParticleType.ember),
        _createVariant(
            'firetail',
            'fire_ember',
            'Glowing Ember',
            Brightness.dark,
            const Color(0xFFFF9800),
            const Color(0xFF3E2723),
            const Color(0xFFFFCC80),
            ParticleType.ember),
        _createVariant(
            'firetail',
            'fire_blue',
            'Blue Flame',
            Brightness.dark,
            const Color(0xFF2979FF),
            const Color(0xFF000000),
            const Color(0xFF82B1FF),
            ParticleType.ember),
        _createVariant(
            'firetail',
            'fire_purple',
            'Mystic Fire',
            Brightness.dark,
            const Color(0xFFD500F9),
            const Color(0xFF210021),
            const Color(0xFFEA80FC),
            ParticleType.ember),
        _createVariant(
            'firetail',
            'fire_dragon',
            'Green Dragon',
            Brightness.dark,
            const Color(0xFF00E676),
            const Color(0xFF002100),
            const Color(0xFF69F0AE),
            ParticleType.ember),
        _createVariant(
            'firetail',
            'fire_sun',
            'Sun Burst',
            Brightness.light,
            const Color(0xFFFF6D00),
            const Color(0xFFFFF3E0),
            const Color(0xFFFFAB40),
            ParticleType.ember),
        _createVariant(
            'firetail',
            'fire_lavender',
            'Pale Fire',
            Brightness.light,
            const Color(0xFFBA68C8),
            const Color(0xFFF3E5F5),
            const Color(0xFFE1BEE7),
            ParticleType.ember),
        _createVariant(
            'firetail',
            'fire_ice',
            'Icefire',
            Brightness.light,
            const Color(0xFF00B0FF),
            const Color(0xFFE1F5FE),
            const Color(0xFF80D8FF),
            ParticleType.ember),
        _createVariant(
            'firetail',
            'fire_golden',
            'Golden Flame',
            Brightness.dark,
            const Color(0xFFFFC400),
            const Color(0xFF3E2723),
            const Color(0xFFFFE082),
            ParticleType.ember),
        _createVariant(
            'firetail',
            'fire_shadow',
            'Shadow Flame',
            Brightness.dark,
            const Color(0xFFEF5350),
            const Color(0xFF000000),
            const Color(0xFFE57373),
            ParticleType.ember),
      ],
    ),
    AppThemeCategory(
      id: 'heroism',
      name: 'Heroism',
      icon: Icons.shield,
      animationPath: 'assets/animations/light.json',
      backgroundColor: const Color(0xFF455A64),
      variants: [
        _createVariant(
            'heroism',
            'hero_royal',
            'Royal Spirit',
            Brightness.dark,
            const Color(0xFFFFD700),
            const Color(0xFF001F3F),
            const Color(0xFF0074D9),
            ParticleType.star),
        _createVariant(
            'heroism',
            'hero_knight',
            'Iron Knight',
            Brightness.dark,
            const Color(0xFFC0C0C0),
            const Color(0xFF1A1A1A),
            const Color(0xFF37474F),
            ParticleType.star),
        _createVariant(
            'heroism',
            'hero_crimson',
            'Crimson Guardian',
            Brightness.dark,
            const Color(0xFFFF5252),
            const Color(0xFF1A0000),
            const Color(0xFFB71C1C),
            ParticleType.star),
        _createVariant(
            'heroism',
            'hero_emerald',
            'Emerald Justice',
            Brightness.dark,
            const Color(0xFF00E676),
            const Color(0xFF001A0F),
            const Color(0xFF004D40),
            ParticleType.star),
        _createVariant(
            'heroism',
            'hero_divine',
            'Divine Light',
            Brightness.light,
            const Color(0xFFFFD600),
            Colors.white,
            const Color(0xFFFFC107),
            ParticleType.star),
        _createVariant(
            'heroism',
            'hero_shadow',
            'Shadow Walker',
            Brightness.dark,
            const Color(0xFFB0BEC5),
            const Color(0xFF0F0F0F),
            const Color(0xFF263238),
            ParticleType.star),
        _createVariant(
            'heroism',
            'hero_galactic',
            'Galaxy Defender',
            Brightness.dark,
            const Color(0xFF7C4DFF),
            const Color(0xFF000022),
            const Color(0xFF40C4FF),
            ParticleType.star),
        _createVariant(
            'heroism',
            'hero_titan',
            'Golden Titan',
            Brightness.dark,
            const Color(0xFFFFA000),
            const Color(0xFF1C1300),
            const Color(0xFFFFD54F),
            ParticleType.star),
        _createVariant(
            'heroism',
            'hero_storm',
            'Storm Bringer',
            Brightness.dark,
            const Color(0xFF448AFF),
            const Color(0xFF0D121A),
            const Color(0xFF03A9F4),
            ParticleType.star),
        _createVariant(
            'heroism',
            'hero_onyx',
            'Black Panther',
            Brightness.dark,
            const Color(0xFFE0E0E0),
            const Color(0xFF000000),
            const Color(0xFF424242),
            ParticleType.star),
      ],
    ),
  ];

  static AppThemeVariant _createVariant(
      String categoryId,
      String id,
      String name,
      Brightness brightness,
      Color primary,
      Color background,
      Color accent,
      ParticleType particles) {
    // Structural Tokens based on Category DNA
    double radius = 12.0;
    double width = 1.0;
    double alpha = 0.1;

    switch (categoryId) {
      case 'anime':
        radius = 2.0;
        width = 3.0;
        alpha = 1.0;
        break;
      case 'love':
        radius = 30.0;
        width = 0.0;
        alpha = 0.0;
        break;
      case 'flower':
        radius = 22.0;
        width = 1.5;
        alpha = 0.3;
        break;
      case 'firetail':
        radius = 6.0;
        width = 1.0;
        alpha = 0.4;
        break;
      case 'heroism':
        radius = 8.0;
        width = 2.0;
        alpha = 0.8;
        break;
      default:
        radius = 12.0;
        width = 1.0;
        alpha = 0.1;
    }

    return AppThemeVariant(
      id: id,
      name: name,
      particleType: particles,
      particleColor: primary.withOpacity(0.6),
      borderRadius: radius,
      borderWidth: width,
      borderAlpha: alpha,
      themeData: _buildTheme(
        brightness: brightness,
        primary: primary,
        secondary: primary.withOpacity(0.8),
        background: background,
        accent: accent,
        borderRadius: radius,
        borderWidth: width,
        borderAlpha: alpha,
        categoryId: categoryId,
      ),
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color primary,
    required Color secondary,
    required Color background,
    required Color accent,
    required double borderRadius,
    required double borderWidth,
    required double borderAlpha,
    required String categoryId,
  }) {
    final bool isDark = brightness == Brightness.dark;
    final Color textColor = isDark ? white : black;

    // Specialized Typography
    FontWeight titleWeight = FontWeight.bold;
    if (categoryId == 'anime') titleWeight = FontWeight.w900;
    if (categoryId == 'heroism') titleWeight = FontWeight.w800;
    if (categoryId == 'love') titleWeight = FontWeight.w500;

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
        titleTextStyle: GoogleFonts.outfit(
          color: textColor,
          fontSize: 20,
          fontWeight: titleWeight,
          letterSpacing: categoryId == 'heroism' ? 1.5 : 0,
        ),
      ),
      cardTheme: CardThemeData(
        color: isDark ? darkGrey : white,
        elevation: categoryId == 'love' ? 4 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: borderWidth > 0
              ? BorderSide(
                  color: accent.withOpacity(borderAlpha),
                  width: borderWidth,
                )
              : BorderSide.none,
        ),
      ),
      iconTheme: IconThemeData(color: textColor),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: categoryId == 'anime'
              ? const BorderSide(color: Colors.black, width: 2)
              : BorderSide.none,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? white.withOpacity(0.05) : black.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: accent.withOpacity(borderAlpha),
            width: borderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: accent.withOpacity(borderAlpha),
            width: borderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: accent,
            width: borderWidth > 0 ? borderWidth + 1 : 2,
          ),
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
          foregroundColor: (categoryId == 'anime' || categoryId == 'heroism')
              ? white
              : (isDark ? black : white),
          elevation: categoryId == 'anime' ? 4 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: categoryId == 'anime'
                ? const BorderSide(color: Colors.black, width: 2)
                : BorderSide.none,
          ),
          textStyle: GoogleFonts.outfit(
            fontWeight: titleWeight,
            letterSpacing: categoryId == 'heroism' ? 1.0 : 0,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: BorderSide(
            color: accent,
            width: categoryId == 'anime' ? 2 : 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: TextStyle(fontWeight: titleWeight),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? white : black,
        contentTextStyle: TextStyle(color: isDark ? black : white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  static AppThemeVariant getVariant(String themeId) {
    for (var pack in themePacks) {
      for (var variant in pack.variants) {
        if (variant.id == themeId) return variant;
      }
    }
    return themePacks[0].variants[0]; // Default to Classic Light
  }

  static ThemeData getTheme(String themeId) {
    return getVariant(themeId).themeData;
  }
}
