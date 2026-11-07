import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_text_styles.dart';

/// Coloured pill badge used for roast/verdict indicators.
/// [variant] controls appearance: [RoastVariant.positive] (green) or [RoastVariant.negative] (red).
enum RoastVariant { positive, negative }

class RoastPill extends StatelessWidget {
  final String label;
  final RoastVariant variant;

  const RoastPill({
    super.key,
    required this.label,
    this.variant = RoastVariant.negative,
  });

  @override
  Widget build(BuildContext context) {
    final bg = variant == RoastVariant.positive
        ? AppColors.mint.withAlpha(30)
        : AppColors.red.withAlpha(30);
    final fg = variant == RoastVariant.positive
        ? AppColors.mint
        : AppColors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(label, style: AppTextStyles.labelSmall.copyWith(color: fg)),
    );
  }
}
