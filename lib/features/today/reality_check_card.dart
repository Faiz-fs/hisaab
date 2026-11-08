import 'package:flutter/material.dart';

import '../../core/format/time_format.dart';
import '../../domain/models/enums.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_text_styles.dart';

/// The witty contextual banner on the Today screen.
/// Text and label change with how much of the daily budget is gone.
class RealityCheckCard extends StatelessWidget {
  final double burnPct; // spent / budget (can exceed 1.0)
  final DateTime now;
  final RoastLevel roastLevel;
  final bool isWeekly;

  const RealityCheckCard({
    super.key,
    required this.burnPct,
    required this.now,
    this.roastLevel = RoastLevel.honest,
    this.isWeekly = false,
  });

  @override
  Widget build(BuildContext context) {
    final calm = burnPct < 0.5;
    final label = calm ? 'ALL GOOD' : 'REALITY CHECK';
    final labelBg = calm
        ? AppColors.mint.withAlpha(40)
        : const Color(0xFF7A0C1A);
    final labelFg = calm ? AppColors.mint : const Color(0xFFFFB3B8);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.nested,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: labelBg,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      calm ? Icons.check_circle_outline : Icons.bolt,
                      size: 14,
                      color: labelFg,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      label,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: labelFg,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(formatClock(now), style: AppTextStyles.labelMedium),
            ],
          ),
          const SizedBox(height: 12),
          Text.rich(TextSpan(children: _message()), style: _base),
        ],
      ),
    );
  }

  TextStyle get _base =>
      AppTextStyles.bodyLarge.copyWith(fontSize: 17, height: 1.35);

  TextStyle get _hi => _base.copyWith(
    color: burnPct > 1 ? AppColors.red : AppColors.primary,
    fontWeight: FontWeight.w700,
  );

  List<InlineSpan> _message() {
    final period = isWeekly ? "this week" : "today";
    final nextPeriod = isWeekly ? "Next week" : "Tomorrow";
    if (roastLevel == RoastLevel.gentle) {
      return [
        TextSpan(
          text: burnPct > 1
              ? 'You went over budget $period. You can reset next time.'
              : 'You are making progress. Keep an eye on your spending $period.',
        ),
      ];
    }
    if (roastLevel == RoastLevel.honest) {
      return [
        TextSpan(
          text: burnPct > 1
              ? 'Your spending exceeded your budget $period. Review your purchases.'
              : burnPct >= 0.8
              ? 'You have used most of your budget $period.'
              : 'Your spending is currently within your budget $period.',
        ),
      ];
    }
    final pct = (burnPct * 100).round();
    final time = formatClock(now);

    if (burnPct > 1.0) {
      return [
        const TextSpan(text: 'You\'re working to fund your own '),
        TextSpan(text: 'bad decisions', style: _hi),
        TextSpan(text: '. $nextPeriod is a clean slate. Use it.'),
      ];
    }
    if (burnPct >= 0.8) {
      return [
        TextSpan(text: 'It\'s $time and '),
        TextSpan(text: '$pct%', style: _hi),
        TextSpan(
          text:
              ' of your allowance $period is gone. One chai away from the red zone.',
        ),
      ];
    }
    if (burnPct >= 0.5) {
      return [
        TextSpan(text: 'It\'s $time and you\'ve already blown through '),
        TextSpan(text: '$pct%', style: _hi),
        TextSpan(
          text:
              ' of your allowance $period. Bold strategy, let\'s see if it pays off.',
        ),
      ];
    }
    return [
      const TextSpan(text: 'Only '),
      TextSpan(text: '$pct%', style: _hi),
      TextSpan(
        text:
            ' of your allowance $period used. Suspiciously disciplined. Keep going.',
      ),
    ];
  }
}
