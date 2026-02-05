import 'dart:math' as math;
import 'package:flutter/material.dart';

enum ParticleType { heart, petal, ember, star, circle }

class MeshBlobModel {
  late double x;
  late double y;
  late double size;
  late double speed;
  late double angle;
  late double opacity;

  MeshBlobModel(Size size) {
    reset(size);
  }

  void reset(Size canvasSize) {
    final random = math.Random();
    x = random.nextDouble() * canvasSize.width;
    y = random.nextDouble() * canvasSize.height;
    size = random.nextDouble() * 300 + 200;
    speed = random.nextDouble() * 0.5 + 0.2;
    angle = random.nextDouble() * math.pi * 2;
    opacity = random.nextDouble() * 0.15 + 0.05;
  }

  void update(Size canvasSize) {
    x += math.cos(angle) * speed;
    y += math.sin(angle) * speed;

    if (x < -size ||
        x > canvasSize.width + size ||
        y < -size ||
        y > canvasSize.height + size) {
      angle += math.pi; // Bounce back roughly
    }
  }
}

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
  late double vx;
  late double vy;

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
    vx = 0;
    vy = 0;
  }

  void update(Size canvasSize, Color baseColor, Offset? touchPos) {
    rotation += rotationSpeed;

    // Default movement velocities
    double dx = 0;
    double dy = 0;

    switch (type) {
      case ParticleType.ember:
        dy = -speed * 1.5; // Faster rising
        dx = math.sin(y / 20) * 1.0; // More turbulent
        break;
      case ParticleType.petal:
        dy = speed * 0.8;
        dx = math.sin(y / 40 + rotation) * 2.0; // Oscillating sway
        break;
      case ParticleType.heart:
        dy = -speed * 0.5; // Floating upwards
        dx = math.cos(y / 60) * 1.0;
        break;
      case ParticleType.star:
        // Twinkle + Slow Drift
        opacity =
            (math.sin(DateTime.now().millisecondsSinceEpoch / 400 + x) + 1) /
                2 *
                0.7;
        color = baseColor.withOpacity(opacity);
        dy = speed * 0.2;
        break;
      case ParticleType.circle:
        // Slow ambient drift
        dx = math.sin(rotation) * 0.3;
        dy = math.cos(rotation) * 0.3;
        break;
    }

    // Touch interaction (Repulsion)
    if (touchPos != null) {
      double tx = touchPos.dx - x;
      double ty = touchPos.dy - y;
      double dist = math.sqrt(tx * tx + ty * ty);
      if (dist < 120) {
        double force = (120 - dist) / 120;
        vx -= (tx / dist) * force * 4;
        vy -= (ty / dist) * force * 4;
      }
    }

    // Apply velocities with friction
    x += dx + vx;
    y += dy + vy;
    vx *= 0.92;
    vy *= 0.92;

    // Wrap-around or Reset
    if (y < -120 ||
        y > canvasSize.height + 120 ||
        x < -120 ||
        x > canvasSize.width + 120) {
      reset(canvasSize, baseColor);
    }
  }
}

class ParticlePainter extends CustomPainter {
  final List<ParticleModel> particles;
  final List<MeshBlobModel> blobs;
  final ParticleType type;
  final Color baseColor;

  ParticlePainter(this.particles, this.blobs, this.type, this.baseColor);

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Mesh Blobs (Ultra-soft ambient layer)
    for (var blob in blobs) {
      final blobPaint = Paint()
        ..color = baseColor.withOpacity(blob.opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blob.size / 3);
      canvas.drawCircle(Offset(blob.x, blob.y), blob.size / 2, blobPaint);
    }

    // 2. Draw Particles (Focused effect layer)
    final paint = Paint()..style = PaintingStyle.fill;
    for (var particle in particles) {
      paint.color = particle.color;

      canvas.save();
      canvas.translate(particle.x, particle.y);
      canvas.rotate(particle.rotation);

      if (type == ParticleType.star && particle.speed > 2.5) {
        // Render as "Speed Line" for Anime vibe
        _drawSpeedLine(canvas, particle.size, paint);
      } else {
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
      }
      canvas.restore();
    }
  }

  void _drawSpeedLine(Canvas canvas, double size, Paint paint) {
    // Long thin rectangle for kinetic effect
    final linePaint = Paint()
      ..color = paint.color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(-size * 2, 0), Offset(size * 2, 0), linePaint);
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
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
