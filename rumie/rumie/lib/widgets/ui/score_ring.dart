import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_text.dart';

/// Circular progress ring whose arc sweeps in and whose number counts up
/// on first build.
class ScoreRing extends StatelessWidget {
  final int value;
  final Color color;
  final double size;
  final double stroke;

  const ScoreRing({
    super.key,
    required this.value,
    required this.color,
    this.size = 56,
    this.stroke = 5,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value / 100),
      duration: AppMotion.of(context, const Duration(milliseconds: 900)),
      curve: AppMotion.enter,
      builder: (context, t, _) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _RingPainter(progress: t, color: color, track: AppColors.line, stroke: stroke),
          child: Center(
            child: Text(
              '${(t * 100).round()}',
              style: AppText.stat.copyWith(color: color, fontSize: size * 0.32),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color track;
  final double stroke;

  _RingPainter({required this.progress, required this.color, required this.track, required this.stroke});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final inset = rect.deflate(stroke / 2);
    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(inset, 0, math.pi * 2, false, trackPaint);
    canvas.drawArc(inset, -math.pi / 2, math.pi * 2 * progress, false, arcPaint);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color || old.track != track || old.stroke != stroke;
}

/// Horizontal mini bar that grows in.
class MiniBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const MiniBar({super.key, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 68, child: Text(label, style: AppText.caption)),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              height: 5,
              child: Stack(
                children: [
                  ColoredBox(color: AppColors.line, child: const SizedBox.expand()),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
                    duration: AppMotion.of(context, const Duration(milliseconds: 800)),
                    curve: AppMotion.enter,
                    builder: (context, t, _) => FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: t,
                      child: ColoredBox(color: color, child: const SizedBox.expand()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
