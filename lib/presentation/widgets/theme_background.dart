import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/theme_cubit.dart';
import 'animations/particle_system.dart';

class ThemeBackground extends StatefulWidget {
  final Widget child;
  const ThemeBackground({super.key, required this.child});

  @override
  State<ThemeBackground> createState() => _ThemeBackgroundState();
}

class _ThemeBackgroundState extends State<ThemeBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<ParticleModel> _particles = [];
  ParticleType _currentType = ParticleType.circle;
  Color _particleColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateParticles(String themeKey, Size size) {
    ParticleType newType;
    Color newColor;

    switch (themeKey) {
      case 'love':
        newType = ParticleType.heart;
        newColor = const Color(0xFFFF80AB);
        break;
      case 'flower':
        newType = ParticleType.petal;
        newColor = const Color(0xFFFFE0B2);
        break;
      case 'firetail':
        newType = ParticleType.ember;
        newColor = const Color(0xFFFFD54F);
        break;
      case 'heroism':
      case 'anime':
        newType = ParticleType.star;
        newColor = const Color(0xFF80DEEA);
        break;
      case 'goodvsevil':
        newType = ParticleType.circle;
        newColor = Colors.grey.withOpacity(0.3);
        break;
      default:
        newType = ParticleType.circle;
        newColor = Colors.transparent;
    }

    if (newType != _currentType || _particles.isEmpty) {
      _currentType = newType;
      _particleColor = newColor;
      _particles = List.generate(
        newType == ParticleType.circle ? 0 : 25,
        (_) => ParticleModel(size, newType, newColor),
      );
    }

    for (var particle in _particles) {
      particle.update(size, newColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, String>(
      builder: (context, themeKey) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);

            return Stack(
              children: [
                // Animation Layer
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    _updateParticles(themeKey, size);
                    return CustomPaint(
                      size: size,
                      painter: ParticlePainter(
                          _particles, _currentType, _particleColor),
                    );
                  },
                ),
                // App Content Layer
                widget.child,
              ],
            );
          },
        );
      },
    );
  }
}
