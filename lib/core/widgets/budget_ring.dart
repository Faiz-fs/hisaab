import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Circular ring showing how much of the daily budget is used.
///
/// Colour semantics (by spent / budget):
///   below 80%   -> lime
///   80% to 100% -> amber
///   above 100%  -> red (ring is full)
///
/// The arc sweeps in on first build and animates whenever [spent] changes.
class BudgetRing extends StatelessWidget {
  final double spent;
  final double budget;
  final double size;
  final double strokeWidth;
  final Widget? center;

  const BudgetRing({
    super.key,
    required this.spent,
    required this.budget,
    this.size = 240,
    this.strokeWidth = 16,
    this.center,
  });

  /// Solid colour for a given burn ratio (used for pills, labels, dots).
  static Color colorFor(double pct) {
    if (pct < 0.8) return AppColors.primary;
    if (pct <= 1.0) return AppColors.amber;
    return AppColors.red;
  }

  /// Two-stop gradient used along the arc.
  static List<Color> gradientFor(double pct) {
    if (pct < 0.8) return const [Color(0xFF9CCB00), Color(0xFFD9F55A)];
    if (pct <= 1.0) return const [Color(0xFFFF8A00), Color(0xFFFFC24D)];
    return const [Color(0xFFE02A40), Color(0xFFFF6B7A)];
  }

  @override
  Widget build(BuildContext context) {
    final pct = budget > 0 ? spent / budget : 0.0;
    final target = pct.clamp(0.0, 1.0).toDouble();
    final colors = gradientFor(pct);

    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: target),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return CustomPaint(
            painter: _RingPainter(
              progress: value,
              colors: colors,
              strokeWidth: strokeWidth,
            ),
            child: child,
          );
        },
        child: Center(child: center),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.colors,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final arcRect = Rect.fromCircle(center: center, radius: radius);

    // Background track.
    final track = Paint()
      ..color = AppColors.nested
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, track);

    if (progress <= 0) return;

    final sweep = 2 * math.pi * progress;
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (sweep < 0.05) {
      arc.color = colors.last;
    } else {
      arc.shader = SweepGradient(
        startAngle: 0,
        endAngle: sweep,
        colors: colors,
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(arcRect);
    }

    canvas.drawArc(arcRect, -math.pi / 2, sweep, false, arc);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.strokeWidth != strokeWidth ||
      old.colors != colors;
}
