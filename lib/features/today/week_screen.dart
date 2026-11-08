import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/inr_format.dart';
import '../../core/format/time_format.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/budget_ring.dart';
import '../../core/widgets/hisaab_card.dart';
import '../../core/widgets/money_text.dart';
import '../../core/widgets/txn_tile.dart';
import '../../domain/models/enums.dart';
import '../../providers/settings_provider.dart';
import 'reality_check_card.dart';
import 'today_data.dart';

/// Weekly dashboard. Uses the same local transactions and flexible budget
/// as Today, aggregated from Monday 00:00 through the current moment.
class WeekScreen extends ConsumerWidget {
  const WeekScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(todayDataProvider);
    final settings = ref.watch(settingsProvider).asData?.value;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: async.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (error, _) =>
              Center(child: Text('Unable to load week: $error')),
          data: (data) {
            final now = data.now;
            final monday = DateTime(
              now.year,
              now.month,
              now.day,
            ).subtract(Duration(days: now.weekday - 1));
            final sunday = monday.add(const Duration(days: 6));
            final weeklyTxns = data.historyTxns
                .where((t) => !t.at.isBefore(monday) && !t.at.isAfter(now))
                .toList();
            final spent = data.weekSpentPaise / 100;
            final budget = data.weekBudgetPaise / 100;
            final remaining = budget - spent;
            final pct = budget > 0 ? spent / budget : (spent > 0 ? 1.01 : 0.0);
            final accent = BudgetRing.colorFor(pct);
            final modeLabel = pct > 1.0
                ? 'OVERSPENT  |  DAMAGE DONE'
                : pct >= 0.8
                ? 'WATCH MODE  |  CAREFUL'
                : 'SAFE MODE  |  ACTIVE';
            final displayName = settings?.displayName.trim() ?? '';
            final initial = displayName.isEmpty
                ? 'U'
                : displayName.substring(0, 1).toUpperCase();
            return ListView(
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                MediaQuery.paddingOf(context).bottom + 24,
              ),
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.currency_rupee,
                        size: 18,
                        color: AppColors.onPrimary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Week',
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontSize: 22,
                      ),
                    ),
                    const Spacer(),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.notifications_none,
                            color: AppColors.textPrimary,
                            size: 26,
                          ),
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              color: AppColors.mint,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.background,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.nested,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                      child: Text(initial, style: AppTextStyles.titleMedium),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      modeLabel,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.mint,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      data.syncLabel,
                      style: AppTextStyles.labelSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${monday.day}/${monday.month} – ${sunday.day}/${sunday.month}/${sunday.year}',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  'Weekly burn quota: ${inr(budget)}',
                  style: AppTextStyles.titleLarge,
                ),
                const SizedBox(height: 16),
                HisaabCard(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 16,
                  ),
                  child: Column(
                    children: [
                      BudgetRing(
                        spent: spent,
                        budget: budget,
                        size: 240,
                        strokeWidth: 16,
                        center: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'SPENT THIS WEEK',
                              style: AppTextStyles.labelSmall,
                            ),
                            const SizedBox(height: 8),
                            MoneyText(
                              spent,
                              style: AppTextStyles.displayLarge.copyWith(
                                fontSize: 40,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              remaining >= 0
                                  ? '${inr(remaining)} left'
                                  : '${inr(-remaining)} over budget',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (remaining < 0) ...[
                  Text(
                    'Weekly budget exceeded by ${inr(-remaining)}',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.red,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                RealityCheckCard(
                  burnPct: pct,
                  now: now,
                  roastLevel: settings?.roastLevel ?? RoastLevel.honest,
                  isWeekly: true,
                ),
                const SizedBox(height: 24),
                Text(
                  "This Week's Spending",
                  style: AppTextStyles.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '${weeklyTxns.length} transactions',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 12),
                if (weeklyTxns.isEmpty)
                  const HisaabCard(
                    child: Text('No spending recorded this week.'),
                  )
                else
                  for (final txn in weeklyTxns) ...[
                    TxnTile(
                      icon: txn.icon,
                      iconColor: txn.color,
                      merchant: txn.merchant,
                      note: txn.note,
                      meta:
                          '${txn.at.day}/${txn.at.month} ${formatClock(txn.at)}  |  ${txn.category}',
                      amount: txn.rupees,
                      modeLabel: txn.mode,
                    ),
                    const SizedBox(height: 10),
                  ],
              ],
            );
          },
        ),
      ),
    );
  }
}
