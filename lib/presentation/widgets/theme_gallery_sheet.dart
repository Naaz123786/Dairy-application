import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/theme_cubit.dart';
import 'package:diary_app/core/theme/app_theme.dart';
import 'package:diary_app/core/theme/theme_model.dart';

class ThemeGallerySheet extends StatefulWidget {
  const ThemeGallerySheet({super.key});

  @override
  State<ThemeGallerySheet> createState() => _ThemeGallerySheetState();
}

class _ThemeGallerySheetState extends State<ThemeGallerySheet> {
  AppThemeCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final currentThemeId = context.watch<ThemeCubit>().state;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
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
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _selectedCategory == null
            ? _buildCategoryGrid(isDark, currentThemeId)
            : _buildVariantGrid(isDark, currentThemeId),
      ),
    );
  }

  Widget _buildCategoryGrid(bool isDark, String currentThemeId) {
    return Column(
      key: const ValueKey('categories'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Theme Packs',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        const Text(
          'Choose a style to see 10+ variants',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 24),
        Flexible(
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.4,
            ),
            itemCount: AppTheme.themePacks.length,
            itemBuilder: (context, index) {
              final pack = AppTheme.themePacks[index];
              final isCurrentPack =
                  pack.variants.any((v) => v.id == currentThemeId);

              return InkWell(
                onTap: () => setState(() => _selectedCategory = pack),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white10
                        : Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isCurrentPack
                          ? Colors.cyan
                          : (isDark ? Colors.white10 : Colors.black12),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(pack.icon,
                          size: 32,
                          color: isCurrentPack
                              ? Colors.cyan
                              : (isDark ? Colors.white70 : Colors.black54)),
                      const SizedBox(height: 8),
                      Text(
                        pack.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isCurrentPack
                              ? Colors.cyan
                              : (isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                      Text(
                        '${pack.variants.length} Variants',
                        style:
                            const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVariantGrid(bool isDark, String currentThemeId) {
    return Column(
      key: const ValueKey('variants'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => setState(() => _selectedCategory = null),
                  icon: const Icon(Icons.arrow_back),
                ),
                Text(
                  _selectedCategory!.name,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Flexible(
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
            ),
            itemCount: _selectedCategory!.variants.length,
            itemBuilder: (context, index) {
              final variant = _selectedCategory!.variants[index];
              final isSelected = variant.id == currentThemeId;
              final Color primaryColor = variant.themeData.primaryColor;

              return InkWell(
                onTap: () {
                  context.read<ThemeCubit>().setTheme(variant.id);
                },
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primaryColor
                        : primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(variant.borderRadius),
                    border: Border.all(
                      color: isSelected
                          ? primaryColor
                          : (isDark
                              ? Colors.white.withOpacity(variant.borderAlpha)
                              : Colors.black.withOpacity(variant.borderAlpha)),
                      width: variant.borderWidth > 0 ? variant.borderWidth : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        variant.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white70 : Colors.black87),
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle,
                            color: Colors.white, size: 16),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
