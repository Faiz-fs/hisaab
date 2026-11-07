import 'package:flutter/material.dart';

import '../../core/format/time_format.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/budget_ring.dart';
import '../../core/widgets/money_text.dart';
import 'today_data.dart';

/// Bottom sheet showing how the day's budget burned, transaction by
/// transaction (oldest first) with a running total.
class DayTimelineSheet extends StatelessWidget {
  final TodayData data;
  const DayTimelineSheet({super.key, required this.data});

  static Future<void> show(BuildContext context, TodayData data) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DayTimelineSheet(data: data),
    );
  }

  @override
  Widget build(BuildContext context) {
    final budget = data.budget.dailyBudgetPaise / 100;
    final ordered = [...data.txns]..sort((a, b) => a.at.compareTo(b.at));

    var running = 0.0;
    final rows = <Widget>[];
    for (final t in ordered) {
      running += t.rupees;
      final pct = budget > 0 ? running / budget : 0.0;
      rows.add(_TimelineRow(txn: t, running: running, pct: pct));
    }

    final maxHeight = MediaQuery.sizeOf(context).height * 0.8;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: AppColors.borderInteractive)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderInteractive,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Burn velocity', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 4),
            Row(
              children: [
                Text('Budget ', style: AppTextStyles.bodyMedium),
                MoneyText(budget,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
                Text('  |  Spent ', style: AppTextStyles.bodyMedium),
                MoneyText(data.budget.spentTodayPaise / 100,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
              ],
            ),
            const SizedBox(height: 16),
            if (rows.isEmpty)
              Text('Nothing spent yet today.', style: AppTextStyles.bodyMedium)
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: rows.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (_, i) => rows[i],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final TodayTxn txn;
  final double running;
  final double pct;

  const _TimelineRow({required this.txn, required this.running, required this.pct});

  @override
  Widget build(BuildContext context) {
    final color = BudgetRing.colorFor(pct);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 64,
          child: Text(formatClock(txn.at), style: AppTextStyles.labelMedium),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      txn.merchant,
                      style: AppTextStyles.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  MoneyText(
                    txn.rupees,
                    prefix: '- ',
                    style: AppTextStyles.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pct.clamp(0.0, 1.0).toDouble(),
                  minHeight: 6,
                  backgroundColor: AppColors.nested,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(pct * 100).round()}% of the day\'s budget gone',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
