import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/inr_format.dart';
import '../../core/format/time_format.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/budget_ring.dart';
import '../../core/widgets/hisaab_card.dart';
import '../../core/widgets/money_text.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/txn_tile.dart';
import 'day_timeline_sheet.dart';
import 'overspent_banner.dart';
import 'reality_check_card.dart';
import 'today_data.dart';
import '../../providers/settings_provider.dart';
import '../../domain/models/enums.dart';

/// Today screen: daily budget ring, reality check, stats and today's spending.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(todayDataProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: async.when(
          data: (data) => _TodayBody(data: data),
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Something broke while loading today.\n$e',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TodayBody extends ConsumerWidget {
  final TodayData data;
  const _TodayBody({required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = data.budget;
    final spent = b.spentTodayPaise / 100;
    final daily = b.dailyBudgetPaise / 100;
    final left = b.leftPaise / 100;
    final pct = b.burnPct;
    final accent = BudgetRing.colorFor(pct);

    final modeLabel = pct > 1.0
        ? 'OVERSPENT  |  DAMAGE DONE'
        : pct >= 0.8
            ? 'WATCH MODE  |  CAREFUL'
            : 'SAFE MODE  |  ACTIVE';

    final bottomInset = MediaQuery.paddingOf(context).bottom + 16;

    return ListView(
      padding: EdgeInsets.fromLTRB(16, 8, 16, bottomInset),
      children: [
        const _Header(),
        const SizedBox(height: 16),

        // Status row
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

        // Greeting. Long-press toggles the overspent mock (debug builds only).
        GestureDetector(
          onLongPress: null,
          child: Text(
            '${greetingFor(data.now)}, ${data.userName}.',
            style: AppTextStyles.headlineLarge.copyWith(fontSize: 30),
          ),
        ),
        const SizedBox(height: 6),
        Text.rich(
          TextSpan(
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
            children: [
              const TextSpan(text: 'Daily burn quota: '),
              TextSpan(
                text: inr(daily),
                style: AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimary),
              ),
              TextSpan(
                text: '  (${inr(b.monthlyIncomePaise / 100)} / 30d)',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Budget ring card
        HisaabCard(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          onTap: () => DayTimelineSheet.show(context, data),
          child: Column(
            children: [
              BudgetRing(
                spent: spent,
                budget: daily,
                size: 240,
                strokeWidth: 16,
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'SPENT TODAY',
                      style: AppTextStyles.labelSmall.copyWith(
                        letterSpacing: 1.6,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    MoneyText(
                      spent,
                      style: AppTextStyles.displayLarge.copyWith(fontSize: 44),
                    ),
                    const SizedBox(height: 8),
                    _LeftPill(left: left, color: accent),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.touch_app_outlined,
                      size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text('Tap ring for burn velocity', style: AppTextStyles.bodyMedium),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (pct > 1.0) ...[
          OverspentBanner(
            message: "You are ${inr(-left)} over today's limit of ${inr(daily)}.",
          ),
          const SizedBox(height: 12),
        ],
        RealityCheckCard(burnPct: pct, now: data.now, roastLevel: ref.watch(settingsProvider).asData?.value.roastLevel ?? RoastLevel.honest),
        const SizedBox(height: 16),

        _StatsRow(data: data),
        const SizedBox(height: 24),

        // Today's damage
        Row(
          children: [
            Text("Today's Damage",
                style: AppTextStyles.headlineMedium.copyWith(fontSize: 22)),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.nested,
                borderRadius: BorderRadius.circular(AppRadii.pill),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                '${data.txns.length} logs',
                style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => DayTimelineSheet.show(context, data),
              child: Text(
                'Full Feed',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (data.txns.isEmpty)
          HisaabCard(
            child: Text(
              'Nothing spent yet. Suspiciously disciplined.',
              style: AppTextStyles.bodyMedium,
            ),
          )
        else
          for (final t in data.txns) ...[
            TxnTile(
              icon: t.icon,
              iconColor: t.color,
              merchant: t.merchant,
              note: t.note,
              meta: '${formatClock(t.at)}  |  ${t.category}',
              amount: t.rupees,
              modeLabel: t.mode,
            ),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.currency_rupee, size: 18, color: AppColors.onPrimary),
        ),
        const SizedBox(width: 10),
        Text('Today', style: AppTextStyles.headlineMedium.copyWith(fontSize: 22)),
        const Spacer(),
        Stack(
          clipBehavior: Clip.none,
          children: [
            const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.notifications_none, color: AppColors.textPrimary, size: 26),
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
                  border: Border.all(color: AppColors.background, width: 1.5),
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
            border: Border.all(color: AppColors.primary, width: 1.5),
          ),
          child: Text('A', style: AppTextStyles.titleMedium),
        ),
      ],
    );
  }
}

class _LeftPill extends StatelessWidget {
  final double left; // rupees, negative when overspent
  final Color color;
  const _LeftPill({required this.left, required this.color});

  @override
  Widget build(BuildContext context) {
    final over = left < 0;
    final style = AppTextStyles.titleMedium.copyWith(color: color, fontSize: 15);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.nested,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: AppColors.borderInteractive),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          if (over) ...[
            MoneyText(left.abs(), prefix: '-', style: style),
            Text(' over budget', style: style),
          ] else ...[
            MoneyText(left, style: style),
            Text(' left', style: style),
          ],
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final TodayData data;
  const _StatsRow({required this.data});

  @override
  Widget build(BuildContext context) {
    final weekOk = data.weekSpentPaise <= data.weekBudgetPaise;
    final monthPct = data.monthIncomePaise > 0
        ? data.monthSpentPaise / data.monthIncomePaise
        : 0.0;
    final monthColor = BudgetRing.colorFor(monthPct);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: StatCard(
            label: 'This Week',
            value: inrCompact(data.weekSpentPaise / 100),
            secondary: '/ ${inrCompact(data.weekBudgetPaise / 100)}',
            footer: weekOk ? 'On track' : 'Over pace',
            footerColor: weekOk ? AppColors.mint : AppColors.red,
            footerIcon: weekOk ? Icons.check_circle_outline : Icons.warning_amber_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatCard(
            label: 'This Month',
            value: inr(data.monthSpentPaise / 100),
            secondary: '/ ${inr(data.monthIncomePaise / 100)}',
            footer: '${(monthPct * 100).toStringAsFixed(1)}% burnt',
            footerColor: monthColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatCard(
            label: 'Savings Streak',
            value: '🔥 ${data.streakDays} Days',
            secondary: '+${inr(data.streakSavedPaise / 100)} saved',
            footer: data.streakDays >= 3 ? 'God tier' : 'Keep going',
            footerColor: AppColors.mint,
          ),
        ),
      ],
    );
  }
}
