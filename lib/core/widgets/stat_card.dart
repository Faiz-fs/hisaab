import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'hisaab_card.dart';

/// Small metric card used in the summary row (This Week / This Month / Streak).
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? secondary;
  final String? footer;
  final Color footerColor;
  final IconData? footerIcon;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.secondary,
    this.footer,
    this.footerColor = AppColors.mint,
    this.footerIcon,
  });

  @override
  Widget build(BuildContext context) {
    return HisaabCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppTextStyles.titleMedium.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (secondary != null) ...[
            const SizedBox(height: 2),
            Text(
              secondary!,
              style: AppTextStyles.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (footer != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (footerIcon != null) ...[
                  Icon(footerIcon, size: 14, color: footerColor),
                  const SizedBox(width: 4),
                ],
                Flexible(
                  child: Text(
                    footer!,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: footerColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
