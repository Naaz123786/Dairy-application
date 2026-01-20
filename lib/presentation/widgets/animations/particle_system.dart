import 'dart:math' as math;
import 'package:flutter/material.dart';

enum ParticleType { heart, petal, ember, star, circle }

class ParticleModel {
  late double x;
  late double y;
  late double size;
  late double speed;
  late double opacity;
  late double angle;
  late Color color;
  late ParticleType type;
  late double rotation;
  late double rotationSpeed;

  ParticleModel(Size canvasSize, ParticleType type, Color baseColor) {
    this.type = type;
    reset(canvasSize, baseColor, isInitial: true);
  }

  void reset(Size canvasSize, Color baseColor, {bool isInitial = false}) {
    final random = math.Random();
    x = random.nextDouble() * canvasSize.width;
    y = isInitial
        ? random.nextDouble() * canvasSize.height
        : (type == ParticleType.ember ? canvasSize.height + 20 : -20);
    size = random.nextDouble() * 15 + 5;
    speed = random.nextDouble() * 2 + 1;
    opacity = random.nextDouble() * 0.5 + 0.2;
    angle = random.nextDouble() * math.pi * 2;
    color = baseColor.withOpacity(opacity);
    rotation = random.nextDouble() * math.pi * 2;
    rotationSpeed = (random.nextDouble() - 0.5) * 0.1;
  }

  void update(Size canvasSize, Color baseColor) {
    rotation += rotationSpeed;

    switch (type) {
      case ParticleType.ember:
        y -= speed;
        x += math.sin(y / 30) * 0.5;
        break;
      case ParticleType.petal:
      case ParticleType.heart:
        y += speed;
        x += math.sin(y / 50) * 1.5;
        break;
      case ParticleType.star:
        opacity =
            (math.sin(DateTime.now().millisecondsSinceEpoch / 500 + x) + 1) /
                2 *
                0.8;
        color = baseColor.withOpacity(opacity);
        break;
      case ParticleType.circle:
        y += speed * 0.5;
        break;
    }

    if (y < -50 ||
        y > canvasSize.height + 50 ||
        x < -50 ||
        x > canvasSize.width + 50) {
      reset(canvasSize, baseColor);
    }
  }
}

class ParticlePainter extends CustomPainter {
  final List<ParticleModel> particles;
  final ParticleType type;
  final Color baseColor;

  ParticlePainter(this.particles, this.type, this.baseColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var particle in particles) {
      paint.color = particle.color;
      canvas.save();
      canvas.translate(particle.x, particle.y);
      canvas.rotate(particle.rotation);

      switch (type) {
        case ParticleType.heart:
          _drawHeart(canvas, particle.size, paint);
          break;
        case ParticleType.petal:
          _drawPetal(canvas, particle.size, paint);
          break;
        case ParticleType.ember:
          _drawEmber(canvas, particle.size, paint);
          break;
        case ParticleType.star:
          _drawStar(canvas, particle.size, paint);
          break;
        case ParticleType.circle:
          canvas.drawCircle(Offset.zero, particle.size / 2, paint);
          break;
      }
      canvas.restore();
    }
  }

  void _drawHeart(Canvas canvas, double size, Paint paint) {
    final path = Path();
    path.moveTo(0, size / 4);
    path.cubicTo(0, 0, -size / 2, 0, -size / 2, size / 2);
    path.cubicTo(-size / 2, size * 0.8, 0, size, 0, size);
    path.cubicTo(0, size, size / 2, size * 0.8, size / 2, size / 2);
    path.cubicTo(size / 2, 0, 0, 0, 0, size / 4);
    canvas.drawPath(path, paint);
  }

  void _drawPetal(Canvas canvas, double size, Paint paint) {
    final path = Path();
    path.moveTo(0, -size / 2);
    path.quadraticBezierTo(size / 2, 0, 0, size / 2);
    path.quadraticBezierTo(-size / 2, 0, 0, -size / 2);
    canvas.drawPath(path, paint);
  }

  void _drawEmber(Canvas canvas, double size, Paint paint) {
    canvas.drawCircle(Offset.zero, size / 2, paint);
    // Add a small glow
    final glowPaint = Paint()
      ..color = paint.color.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset.zero, size, glowPaint);
  }

  void _drawStar(Canvas canvas, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      double angle = (i * 72 - 90) * math.pi / 180;
      double nextAngle = ((i + 1) * 72 - 90) * math.pi / 180;
      double midAngle = (angle + nextAngle) / 2;

      if (i == 0) path.moveTo(math.cos(angle) * size, math.sin(angle) * size);
      path.lineTo(
          math.cos(midAngle) * size / 2.5, math.sin(midAngle) * size / 2.5);
      path.lineTo(math.cos(nextAngle) * size, math.sin(nextAngle) * size);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
