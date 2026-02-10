import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../bloc/theme_cubit.dart';
import 'package:diary_app/core/theme/app_theme.dart';
import 'package:diary_app/core/theme/theme_model.dart';
import '../pages/theme_preview_screen.dart';

class ThemeGallerySheet extends StatefulWidget {
  final AppThemeCategory? initialCategory;

  const ThemeGallerySheet({super.key, this.initialCategory});

  @override
  State<ThemeGallerySheet> createState() => _ThemeGallerySheetState();
}

class _ThemeGallerySheetState extends State<ThemeGallerySheet> {
  AppThemeCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  Widget build(BuildContext context) {
    final currentThemeId = context.watch<ThemeCubit>().state;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
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
              'Theme Library',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        const Text(
          'Select a vibe to preview experience',
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
              childAspectRatio: 0.85, // Taller cards for Lottie
            ),
            itemCount: AppTheme.themePacks.length,
            itemBuilder: (context, index) {
              final pack = AppTheme.themePacks[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ThemePreviewScreen(category: pack),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: pack.backgroundColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: pack.backgroundColor.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      // Animation Background
                      Positioned.fill(
                        child: Lottie.asset(
                          pack.animationPath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(pack.icon,
                                  size: 40, color: Colors.white24),
                            );
                          },
                        ),
                      ),
                      // Overlay
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.3),
                        ),
                      ),
                      // Content
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(pack.icon, size: 40, color: Colors.white),
                            const SizedBox(height: 10),
                            Text(
                              pack.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${pack.variants.length} Styles',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
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
                  onPressed: () {
                    if (widget.initialCategory != null) {
                      Navigator.pop(context);
                    } else {
                      setState(() => _selectedCategory = null);
                    }
                  },
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
                      if (isSelected) const SizedBox(height: 4),
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
