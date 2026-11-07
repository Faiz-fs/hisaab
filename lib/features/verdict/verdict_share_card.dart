import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/format/inr_format.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/verdict_provider.dart';

/// Compact, self-contained verdict summary card.
class VerdictShareCard extends StatelessWidget {
  final VerdictView view;
  const VerdictShareCard({super.key, required this.view});

  /// Plain-text version used by the Copy button.
  static String asText(VerdictView v) {
    final d = v.verdict;
    return 'Hisaab verdict ${DateFormat('d MMM').format(d.date)}: ${d.rating}/10\n'
        'Spent ${inr(d.totalSpentRupees)} of ${inr(v.dailyBudgetPaise / 100)}\n'
        '"${v.roast}"';
  }

  Color _ratingColor(int r) => r >= 7
      ? AppColors.mint
      : r >= 4
      ? AppColors.amber
      : AppColors.red;

  @override
  Widget build(BuildContext context) {
    final d = view.verdict;
    final color = _ratingColor(d.rating);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Text(
            DateFormat('EEEE, d MMM').format(d.date).toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 11,
              letterSpacing: 1.2,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '${d.rating}/10',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 56,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${inr(d.totalSpentRupees)} of ${inr(view.dailyBudgetPaise / 100)}',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '“${view.roast}”',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontStyle: FontStyle.italic,
              height: 1.4,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
