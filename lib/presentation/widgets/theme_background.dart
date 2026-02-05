import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/theme_cubit.dart';
import 'package:diary_app/presentation/widgets/animations/particle_system.dart';
import 'package:diary_app/core/theme/app_theme.dart';

class ThemeBackground extends StatefulWidget {
  final Widget child;
  const ThemeBackground({super.key, required this.child});

  @override
  State<ThemeBackground> createState() => _ThemeBackgroundState();
}

class _ThemeBackgroundState extends State<ThemeBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<ParticleModel> _particles = [];
  final List<MeshBlobModel> _blobs = [];
  String? _currentTheme;
  Offset? _touchPosition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_updateAnimation);
    _controller.repeat();
  }

  void _updateAnimation() {
    if (!mounted) return;
    setState(() {
      final size = MediaQuery.of(context).size;
      final themeKey = _currentTheme ?? 'classic_light';
      final variant = AppTheme.getVariant(themeKey);

      for (var blob in _blobs) {
        blob.update(size);
      }
      for (var particle in _particles) {
        particle.update(size, variant.particleColor, _touchPosition);
      }
    });
  }

  void _initElements(String themeKey, Size size) {
    final variant = AppTheme.getVariant(themeKey);
    final categoryId = themeKey.split('_')[0];
    final type = variant.particleType;
    final color = variant.particleColor;

    _particles.clear();
    int particleCount = 40;
    if (categoryId == 'anime') particleCount = 60;
    if (categoryId == 'love' || categoryId == 'flower') particleCount = 20;
    if (categoryId == 'firetail') particleCount = 50;

    for (int i = 0; i < particleCount; i++) {
      _particles.add(ParticleModel(size, type, color));
    }

    _blobs.clear();
    int blobCount = (categoryId == 'love' || categoryId == 'flower') ? 6 : 3;
    for (int i = 0; i < blobCount; i++) {
      _blobs.add(MeshBlobModel(size));
    }
    _currentTheme = themeKey;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, String>(
      builder: (context, themeKey) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            if (_currentTheme != themeKey) {
              _initElements(themeKey, size);
            }

            final variant = AppTheme.getVariant(themeKey);

            return MouseRegion(
              onHover: (event) => _touchPosition = event.localPosition,
              onExit: (_) => _touchPosition = null,
              child: GestureDetector(
                onPanUpdate: (details) =>
                    _touchPosition = details.localPosition,
                onPanEnd: (_) => _touchPosition = null,
                onTapDown: (details) => _touchPosition = details.localPosition,
                onTapUp: (_) => _touchPosition = null,
                child: Stack(
                  children: [
                    CustomPaint(
                      size: size,
                      painter: ParticlePainter(
                        _particles,
                        _blobs,
                        variant.particleType,
                        variant.particleColor,
                      ),
                    ),
                    widget.child,
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
