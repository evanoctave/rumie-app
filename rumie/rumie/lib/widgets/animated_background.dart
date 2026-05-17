import 'dart:math';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: AppColors.background),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: _OrbPainter(_controller.value),
              size: Size.infinite,
            );
          },
        ),
        widget.child,
      ],
    );
  }
}

class _OrbPainter extends CustomPainter {
  final double t;

  _OrbPainter(this.t);

  static const _orbs = [
    _OrbDef(cx: 0.15, cy: 0.2, rx: 0.35, ry: 0.25, speed: 0.7, phase: 0.0, color: AppColors.blue, size: 220),
    _OrbDef(cx: 0.85, cy: 0.15, rx: 0.30, ry: 0.30, speed: 0.5, phase: 1.2, color: AppColors.teal, size: 180),
    _OrbDef(cx: 0.5, cy: 0.6, rx: 0.40, ry: 0.20, speed: 0.8, phase: 2.5, color: AppColors.blue, size: 200),
    _OrbDef(cx: 0.2, cy: 0.8, rx: 0.25, ry: 0.30, speed: 0.6, phase: 3.8, color: AppColors.green, size: 160),
    _OrbDef(cx: 0.75, cy: 0.75, rx: 0.30, ry: 0.25, speed: 0.9, phase: 5.0, color: AppColors.teal, size: 140),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final orb in _orbs) {
      final angle = 2 * pi * t * orb.speed + orb.phase;
      final x = (orb.cx + orb.rx * cos(angle)) * size.width;
      final y = (orb.cy + orb.ry * sin(angle)) * size.height;

      final paint = Paint()
        ..color = orb.color.withAlpha(18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);
      canvas.drawCircle(Offset(x, y), orb.size, paint);

      final paintInner = Paint()
        ..color = orb.color.withAlpha(10)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);
      canvas.drawCircle(Offset(x, y), orb.size * 1.6, paintInner);
    }
  }

  @override
  bool shouldRepaint(_OrbPainter old) => old.t != t;
}

class _OrbDef {
  final double cx, cy, rx, ry, speed, phase;
  final Color color;
  final double size;

  const _OrbDef({
    required this.cx,
    required this.cy,
    required this.rx,
    required this.ry,
    required this.speed,
    required this.phase,
    required this.color,
    required this.size,
  });
}
