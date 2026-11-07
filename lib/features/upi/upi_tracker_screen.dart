import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/format/inr_format.dart';
import '../../core/theme/app_colors.dart';
import '../../data/db/app_database.dart';
import '../../providers/db_provider.dart';
import 'categorize_sheet.dart';

/// Debits of the last 60 days (newest first).
final upiTxnsProvider = FutureProvider.autoDispose<List<Txn>>((ref) {
  final now = DateTime.now();
  return ref
      .watch(dbProvider)
      .txnsDao
      .getDebitsSince(DateTime(now.year, now.month, now.day - 60));
});

/// Lists spending transactions and lets the user categorise them.
class UpiTrackerScreen extends ConsumerStatefulWidget {
  const UpiTrackerScreen({super.key});

  @override
  ConsumerState<UpiTrackerScreen> createState() => _UpiTrackerScreenState();
}

class _UpiTrackerScreenState extends ConsumerState<UpiTrackerScreen> {
  bool _onlyUncategorised = true;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(upiTxnsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/profile'),
        ),
        title: Text(
          'Categorise spending',
          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
        ),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load transactions: $e')),
        data: (all) {
          final rows = _onlyUncategorised
              ? all.where((t) => t.category == null).toList()
              : all;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(
                      value: true,
                      label: Text(
                        'To categorise (${all.where((t) => t.category == null).length})',
                      ),
                    ),
                    ButtonSegment(
                      value: false,
                      label: Text('All (${all.length})'),
                    ),
                  ],
                  selected: {_onlyUncategorised},
                  onSelectionChanged: (s) =>
                      setState(() => _onlyUncategorised = s.first),
                ),
              ),
              Expanded(
                child: rows.isEmpty
                    ? Center(
                        child: Text(
                          _onlyUncategorised
                              ? 'Everything is categorised 🎉'
                              : 'No spending found yet.',
                          style: GoogleFonts.inter(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                        itemCount: rows.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final t = rows[i];
                          return Material(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => CategorizeSheet.show(context, t.id),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.receipt_long_outlined,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            t.payee ?? 'Unknown merchant',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            '${DateFormat('d MMM, h:mm a').format(t.at)} · ${t.category ?? 'Uncategorised'}${t.kind == 'spend' ? '' : ' · not counted'}',
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: t.category == null
                                                  ? AppColors.amber
                                                  : AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      inr(t.amount / 100),
                                      style: GoogleFonts.spaceGrotesk(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
