import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/format/inr_format.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/verdict_provider.dart';
import 'verdict_share_card.dart';

/// Verdict screen — shows daily rating, roast copy, culprit breakdown.
class VerdictScreen extends ConsumerWidget {
  const VerdictScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(todayVerdictViewProvider);
    final history = ref.watch(recentVerdictsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/today'),
        ),
        title: Text(
          'Night Verdict',
          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
        ),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not build verdict: $e')),
        data: (view) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          children: [
            VerdictShareCard(view: view),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: VerdictShareCard.asText(view)),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Verdict copied')),
                    );
                  }
                },
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Copy to share'),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'TOP CULPRITS',
              style: GoogleFonts.inter(
                fontSize: 11,
                letterSpacing: 1.2,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            if (view.verdict.topCulprits.isEmpty)
              Text(
                'Nothing spent today. Suspiciously disciplined.',
                style: GoogleFonts.inter(color: AppColors.textSecondary),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in view.verdict.topCulprits)
                    Chip(
                      label: Text(c),
                      backgroundColor: AppColors.nested,
                      side: const BorderSide(color: AppColors.border),
                    ),
                ],
              ),
            const SizedBox(height: 24),
            Text(
              'LAST 7 DAYS',
              style: GoogleFonts.inter(
                fontSize: 11,
                letterSpacing: 1.2,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            history.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (list) => Column(
                children: [
                  for (final v in list)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              DateFormat('EEE, d MMM').format(v.date),
                              style: GoogleFonts.inter(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            inr(v.totalSpentRupees),
                            style: GoogleFonts.inter(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            '${v.rating}/10',
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w700,
                              color: v.overBudget
                                  ? AppColors.red
                                  : AppColors.mint,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
