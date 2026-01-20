import 'package:flutter/material.dart';
import 'theme_gallery_sheet.dart';

class ThemeSwitcherButton extends StatelessWidget {
  const ThemeSwitcherButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const ThemeGallerySheet(),
        );
      },
      icon: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [Colors.purple, Colors.blue, Colors.pink],
        ).createShader(bounds),
        child:
            const Icon(Icons.palette_outlined, size: 28, color: Colors.white),
      ),
      tooltip: 'Change Theme Vibe',
    );
  }
}
