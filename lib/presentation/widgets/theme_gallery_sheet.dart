import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/theme_cubit.dart';

class ThemeGallerySheet extends StatelessWidget {
  const ThemeGallerySheet({super.key});

  @override
  Widget build(BuildContext context) {
    final themes = [
      {
        'key': 'light',
        'name': 'Classic Light',
        'icon': Icons.light_mode,
        'color': Colors.white
      },
      {
        'key': 'dark',
        'name': 'Classic Dark',
        'icon': Icons.dark_mode,
        'color': Colors.black87
      },
      {
        'key': 'love',
        'name': 'Love & Romance',
        'icon': Icons.favorite,
        'color': const Color(0xFFD81B60)
      },
      {
        'key': 'anime',
        'name': 'Anime Vibe',
        'icon': Icons.bolt,
        'color': const Color(0xFF00E5FF)
      },
      {
        'key': 'flower',
        'name': 'Floral Garden',
        'icon': Icons.local_florist,
        'color': const Color(0xFF2E7D32)
      },
      {
        'key': 'firetail',
        'name': 'Firetail',
        'icon': Icons.whatshot,
        'color': const Color(0xFFFF6D00)
      },
      {
        'key': 'heroism',
        'name': 'Heroic Spirit',
        'icon': Icons.shield,
        'color': const Color(0xFFFFD700)
      },
      {
        'key': 'goodvsevil',
        'name': 'Good vs Evil',
        'icon': Icons.exposure,
        'color': Colors.redAccent
      },
    ];

    final currentTheme = context.watch<ThemeCubit>().state;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Choose Your Vibe',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
            ),
            itemCount: themes.length,
            itemBuilder: (context, index) {
              final theme = themes[index];
              final isSelected = currentTheme == theme['key'];
              final color = theme['color'] as Color;

              return InkWell(
                onTap: () {
                  context.read<ThemeCubit>().setTheme(theme['key'] as String);
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: isSelected ? color : color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? color
                          : (isDark ? Colors.white24 : Colors.black12),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        theme['icon'] as IconData,
                        color: isSelected ? Colors.white : color,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        theme['name'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white70 : Colors.black87),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
