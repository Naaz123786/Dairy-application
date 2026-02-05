import 'package:flutter/material.dart';
import 'package:diary_app/presentation/widgets/animations/particle_system.dart';

class AppThemeVariant {
  final String id;
  final String name;
  final ThemeData themeData;
  final ParticleType particleType;
  final Color particleColor;
  final double borderRadius;
  final double borderWidth;
  final double borderAlpha;

  AppThemeVariant({
    required this.id,
    required this.name,
    required this.themeData,
    this.particleType = ParticleType.circle,
    this.particleColor = Colors.white,
    this.borderRadius = 12.0,
    this.borderWidth = 1.0,
    this.borderAlpha = 0.1,
  });
}

class AppThemeCategory {
  final String id;
  final String name;
  final IconData icon;
  final List<AppThemeVariant> variants;

  AppThemeCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.variants,
  });
}
