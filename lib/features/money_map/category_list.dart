import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/format/inr_format.dart';
import '../../core/theme/app_colors.dart';

/// Simple category breakdown list: name, amount and share bar.
class CategoryList extends StatelessWidget {
  /// Category name → amount in paise.
  final Map<String, int> totals;
  const CategoryList({super.key, this.totals = const {}});

  @override
  Widget build(BuildContext context) {
    if (totals.isEmpty) {
      return Center(
        child: Text(
          'No categories yet',
          style: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
      );
    }
    final sum = totals.values.fold<int>(0, (a, b) => a + b);
    final rows = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (final e in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        e.key,
                        style: GoogleFonts.inter(color: AppColors.textPrimary),
                      ),
                    ),
                    Text(
                      inr(e.value / 100),
                      style: GoogleFonts.inter(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: sum == 0 ? 0 : e.value / sum,
                  minHeight: 6,
                  color: AppColors.primary,
                  backgroundColor: AppColors.nested,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
