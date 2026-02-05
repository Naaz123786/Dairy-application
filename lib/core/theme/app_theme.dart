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
      ],
    ),
    AppThemeCategory(
      id: 'anime',
      name: 'Anime Vibe',
      icon: Icons.bolt,
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
            'anime_sunset',
            'Vibrant Sunset',
            Brightness.dark,
            const Color(0xFFFFD600),
            const Color(0xFF1A1A2E),
            const Color(0xFFFF4081),
            ParticleType.star),
        _createVariant(
            'anime',
            'anime_pastel',
            'Kawaii Pastel',
            Brightness.light,
            const Color(0xFF7B1FA2),
            const Color(0xFFF3E5F5),
            const Color(0xFFF06292),
            ParticleType.star),
        _createVariant(
            'anime',
            'anime_forest',
            'Spirit Forest',
            Brightness.dark,
            const Color(0xFF00C853),
            const Color(0xFF0A1F11),
            const Color(0xFF81C784),
            ParticleType.star),
        _createVariant(
            'anime',
            'anime_ocean',
            'Blue Exorcist',
            Brightness.dark,
            const Color(0xFF00B0FF),
            const Color(0xFF010D1A),
            const Color(0xFF40C4FF),
            ParticleType.star),
        _createVariant(
            'anime',
            'anime_sakura',
            'Cherry Blossom',
            Brightness.light,
            const Color(0xFFEC407A),
            const Color(0xFFFFF5F8),
            const Color(0xFFF48FB1),
            ParticleType.star),
        _createVariant(
            'anime',
            'anime_mecha',
            'Mecha Silver',
            Brightness.dark,
            const Color(0xFFCFD8DC),
            const Color(0xFF263238),
            const Color(0xFFE91E63),
            ParticleType.star),
        _createVariant(
            'anime',
            'anime_thunder',
            'Yellow Flash',
            Brightness.dark,
            const Color(0xFFFFEA00),
            const Color(0xFF121200),
            const Color(0xFFFFAB00),
            ParticleType.star),
        _createVariant(
            'anime',
            'anime_night',
            'Tokyo Night',
            Brightness.dark,
            const Color(0xFF3D5AFE),
            const Color(0xFF0D0221),
            const Color(0xFFFF0055),
            ParticleType.star),
        _createVariant(
            'anime',
            'anime_dream',
            'Ethereal Dream',
            Brightness.dark,
            const Color(0xFFB388FF),
            const Color(0xFF1A0033),
            const Color(0xFFD1C4E9),
            ParticleType.star),
      ],
    ),
    AppThemeCategory(
      id: 'love',
      name: 'Love & Romance',
      icon: Icons.favorite,
      variants: [
        _createVariant(
            'love',
            'love_pink',
            'Pink Rose',
            Brightness.light,
            const Color(0xFFD81B60),
            const Color(0xFFFFF1F8),
            const Color(0xFFFF4081),
            ParticleType.heart),
        _createVariant(
            'love',
            'love_velvet',
            'Red Velvet',
            Brightness.dark,
            const Color(0xFFFF1744),
            const Color(0xFF1C0505),
            const Color(0xFFD50000),
            ParticleType.heart),
        _createVariant(
            'love',
            'love_gold',
            'Golden Heart',
            Brightness.dark,
            const Color(0xFFFFD700),
            const Color(0xFF2A0D1F),
            const Color(0xFFFF6D00),
            ParticleType.heart),
        _createVariant(
            'love',
            'love_lavender',
            'Sweet Lavender',
            Brightness.light,
            const Color(0xFF673AB7),
            const Color(0xFFF3E5F5),
            const Color(0xFF9575CD),
            ParticleType.heart),
        _createVariant(
            'love',
            'love_passion',
            'Deep Passion',
            Brightness.dark,
            const Color(0xFFB71C1C),
            const Color(0xFF0D0000),
            const Color(0xFFFF5252),
            ParticleType.heart),
        _createVariant(
            'love',
            'love_candy',
            'Candy Crush',
            Brightness.light,
            const Color(0xFFF06292),
            const Color(0xFFFCE4EC),
            const Color(0xFFFF80AB),
            ParticleType.heart),
        _createVariant(
            'love',
            'love_bloom',
            'Love Bloom',
            Brightness.light,
            const Color(0xFFBA68C8),
            const Color(0xFFF3E5F5),
            const Color(0xFFCE93D8),
            ParticleType.heart),
        _createVariant(
            'love',
            'love_classic',
            'Classic Heart',
            Brightness.light,
            Colors.red,
            Colors.white,
            Colors.pinkAccent,
            ParticleType.heart),
        _createVariant(
            'love',
            'love_ruby',
            'Ruby Spark',
            Brightness.dark,
            const Color(0xFFC62828),
            const Color(0xFF1B0000),
            const Color(0xFFE53935),
            ParticleType.heart),
        _createVariant(
            'love',
            'love_dawn',
            'First Sight',
            Brightness.light,
            const Color(0xFFFFAB40),
            const Color(0xFFFFF3E0),
            const Color(0xFFFFD180),
            ParticleType.heart),
      ],
    ),
    AppThemeCategory(
      id: 'flower',
      name: 'Floral Garden',
      icon: Icons.local_florist,
      variants: [
        _createVariant(
            'flower',
            'flower_garden',
            'Morning Garden',
            Brightness.light,
            const Color(0xFF2E7D32),
            const Color(0xFFF1F8E9),
            const Color(0xFF81C784),
            ParticleType.petal),
        _createVariant(
            'flower',
            'flower_sakura',
            'Sakura Drift',
            Brightness.light,
            const Color(0xFFF06292),
            const Color(0xFFFFF5F8),
            const Color(0xFFFFD1DC),
            ParticleType.petal),
        _createVariant(
            'flower',
            'flower_night',
            'Night Bloom',
            Brightness.dark,
            const Color(0xFF9C27B0),
            const Color(0xFF120316),
            const Color(0xFFE1BEE7),
            ParticleType.petal),
        _createVariant(
            'flower',
            'flower_autumn',
            'Autumn Breeze',
            Brightness.light,
            const Color(0xFFD84315),
            const Color(0xFFFFF3E0),
            const Color(0xFFFFB74D),
            ParticleType.petal),
        _createVariant(
            'flower',
            'flower_meadow',
            'Wild Meadow',
            Brightness.light,
            const Color(0xFF43A047),
            const Color(0xFFE8F5E9),
            const Color(0xFF2E7D32),
            ParticleType.petal),
        _createVariant(
            'flower',
            'flower_orchid',
            'Royal Orchid',
            Brightness.dark,
            const Color(0xFF7B1FA2),
            const Color(0xFF1A001F),
            const Color(0xFFBA68C8),
            ParticleType.petal),
        _createVariant(
            'flower',
            'flower_sunflower',
            'Sun Field',
            Brightness.light,
            const Color(0xFFFBC02D),
            const Color(0xFFFFFDE7),
            const Color(0xFFFBC02D),
            ParticleType.petal),
        _createVariant(
            'flower',
            'flower_mint',
            'Fresh Mint',
            Brightness.light,
            const Color(0xFF00897B),
            const Color(0xFFE0F2F1),
            const Color(0xFF80CBC4),
            ParticleType.petal),
        _createVariant(
            'flower',
            'flower_rose',
            'Desert Rose',
            Brightness.light,
            const Color(0xFFE57373),
            const Color(0xFFFFEBEE),
            const Color(0xFFFFCDD2),
            ParticleType.petal),
        _createVariant(
            'flower',
            'flower_mystic',
            'Mystic Fern',
            Brightness.dark,
            const Color(0xFF1B5E20),
            const Color(0xFF000F00),
            const Color(0xFF4CAF50),
            ParticleType.petal),
      ],
    ),
    AppThemeCategory(
      id: 'firetail',
      name: 'Firetail',
      icon: Icons.whatshot,
      variants: [
        _createVariant(
            'firetail',
            'fire_classic',
            'Classic Blaze',
            Brightness.dark,
            const Color(0xFFFF6D00),
            const Color(0xFF0D0D0D),
            const Color(0xFFD50000),
            ParticleType.ember),
        _createVariant(
            'firetail',
            'fire_blue',
            'Blue Flame',
            Brightness.dark,
            const Color(0xFF00B0FF),
            const Color(0xFF01101A),
            const Color(0xFF00E5FF),
            ParticleType.ember),
        _createVariant(
            'firetail',
            'fire_ash',
            'Grey Ashes',
            Brightness.dark,
            const Color(0xFFB0BEC5),
            const Color(0xFF1A1A1A),
            const Color(0xFF546E7A),
            ParticleType.ember),
        _createVariant(
            'firetail',
            'fire_gold',
            'Solar Flare',
            Brightness.dark,
            const Color(0xFFFFD600),
            const Color(0xFF1C1300),
            const Color(0xFFFF6D00),
            ParticleType.ember),
        _createVariant(
            'firetail',
            'fire_magma',
            'Magma Flow',
            Brightness.dark,
            const Color(0xFFF44336),
            const Color(0xFF100000),
            const Color(0xFFFF9800),
            ParticleType.ember),
        _createVariant(
            'firetail',
            'fire_purple',
            'Ghost Fire',
            Brightness.dark,
            const Color(0xFFD1C4E9),
            const Color(0xFF1A1A2E),
            const Color(0xFF7E57C2),
            ParticleType.ember),
        _createVariant(
            'firetail',
            'fire_emerald',
            'Green Fire',
            Brightness.dark,
            const Color(0xFF69F0AE),
            const Color(0xFF001205),
            const Color(0xFF00E676),
            ParticleType.ember),
        _createVariant(
            'firetail',
            'fire_white',
            'White Heat',
            Brightness.dark,
            Colors.white70,
            const Color(0xFF121212),
            Colors.cyanAccent,
            ParticleType.ember),
        _createVariant(
            'firetail',
            'fire_crimson',
            'Crimson Embers',
            Brightness.dark,
            const Color(0xFFD32F2F),
            const Color(0xFF1A0000),
            const Color(0xFFFF5252),
            ParticleType.ember),
        _createVariant(
            'firetail',
            'fire_hollow',
            'Void Flame',
            Brightness.dark,
            const Color(0xFFCFD8DC),
            const Color(0xFF000000),
            const Color(0xFF37474F),
            ParticleType.ember),
      ],
    ),
    AppThemeCategory(
      id: 'heroism',
      name: 'Heroism',
      icon: Icons.shield,
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
