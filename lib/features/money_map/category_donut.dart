import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Donut chart of category totals (pure Flutter, no chart package needed).
class CategoryDonut extends StatelessWidget {
  /// Category name → amount in paise.
  final Map<String, int> totals;
  const CategoryDonut({super.key, this.totals = const {}});

  static const _palette = [
    AppColors.primary,
    AppColors.mint,
    AppColors.amber,
    AppColors.red,
    Color(0xFF7C8CFF),
    Color(0xFFFF8A9B),
    Color(0xFF5ED0FF),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: CustomPaint(
        painter: _DonutPainter(
          totals.values.toList()..sort((a, b) => b.compareTo(a)),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<int> values;
  _DonutPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<int>(0, (a, b) => a + b);
    final side = math.min(size.width, size.height);
    final rect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: side - 20,
      height: side - 20,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 26
      ..color = AppColors.nested;
    if (total == 0) {
      canvas.drawArc(rect, 0, math.pi * 2, false, paint);
      return;
    }
    var start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = values[i] / total * math.pi * 2;
      paint.color = CategoryDonut._palette[i % CategoryDonut._palette.length];
      canvas.drawArc(rect, start, math.max(sweep - 0.03, 0.01), false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => old.values != values;
}
