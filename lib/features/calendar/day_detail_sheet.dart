
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../today/today_data.dart';

/// Shows spending details for the selected calendar day.
class DayDetailSheet extends StatelessWidget {
  final DateTime date;
  final List<TodayTxn> transactions;
  final int dailyBudgetPaise;

  const DayDetailSheet({
    super.key,
    required this.date,
    required this.transactions,
    required this.dailyBudgetPaise,
  });

  String _money(int paise) {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(paise / 100);
  }

  TextStyle _title(double size, {Color? color}) {
    return GoogleFonts.spaceGrotesk(
      fontSize: size,
      fontWeight: FontWeight.w700,
      color: color ?? AppColors.textPrimary,
    );
  }

  TextStyle _body(double size, {Color? color}) {
    return GoogleFonts.inter(
      fontSize: size,
      color: color ?? AppColors.textSecondary,
    );
  }

  String _verdict(int spent) {
    if (transactions.isEmpty) {
      return 'No tracked transactions for this day. '
          'Your bank SMS history will fill this in.';
    }

    if (spent > dailyBudgetPaise) {
      return 'Your wallet filed a complaint. '
          'You went over the daily budget.';
    }

    if (spent >= dailyBudgetPaise * 0.8) {
      return 'That was close. Your budget survived, barely.';
    }

    return 'A disciplined day. Your future self approves.';
  }

  @override
  Widget build(BuildContext context) {
    final sorted = [...transactions]
      ..sort((a, b) => b.amountPaise.compareTo(a.amountPaise));

    final spent = transactions.fold<int>(
      0,
      (sum, txn) => sum + txn.amountPaise,
    );

    final difference = dailyBudgetPaise - spent;
    final hasData = transactions.isNotEmpty;

    final statusColor = !hasData
        ? AppColors.textSecondary
        : difference < 0
            ? AppColors.red
            : spent >= dailyBudgetPaise * 0.8
                ? AppColors.amber
                : AppColors.mint;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ACTIVE SELECTION',
                      style: _title(
                        11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      DateFormat('EEEE, MMM d').format(date),
                      style: _title(19),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _money(spent),
                    style: _title(22, color: statusColor),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      !hasData
                          ? 'No data'
                          : difference < 0
                              ? 'Over by ${_money(-difference)}'
                              : '${_money(difference)} left',
                      style: _title(10, color: statusColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.nested,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  hasData
                      ? Icons.local_fire_department_outlined
                      : Icons.info_outline,
                  color: AppColors.primary,
                  size: 21,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _verdict(spent),
                    style: _body(
                      13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                'TOP 3 SPENDS',
                style: _title(12),
              ),
              const Spacer(),
              Text(
                '${transactions.length} items tracked',
                style: _body(11),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (sorted.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 26,
                horizontal: 12,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.receipt_long_outlined,
                    color: AppColors.textSecondary,
                    size: 30,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'No transactions recorded',
                    style: _title(13),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Tracked spending will appear here.',
                    style: _body(11),
                  ),
                ],
              ),
            )
          else
            for (final txn in sorted.take(3)) ...[
              _transactionTile(txn),
              const SizedBox(height: 8),
            ],
          if (hasData) ...[
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 49,
              child: ElevatedButton(
                onPressed: () => context.go('/verdict'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'View Night Verdict',
                      style: _title(
                        14,
                        color: AppColors.onPrimary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_forward, size: 19),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _transactionTile(TodayTxn txn) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.nested,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              txn.icon,
              color: txn.color,
              size: 21,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.merchant,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _title(13),
                ),
                const SizedBox(height: 4),
                Text(
                  '${txn.category} · '
                  '${DateFormat('h:mm a').format(txn.at)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _body(10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 7),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '− ${_money(txn.amountPaise)}',
                style: _title(13),
              ),
              const SizedBox(height: 4),
              Text(
                txn.mode,
                style: _body(10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
