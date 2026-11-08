import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../today/today_data.dart';

/// Shows spending and incoming credit details for the
/// selected calendar day.
///
/// Spending alone determines the daily budget verdict.
/// Incoming credits never increase the spending quota.
class DayDetailSheet extends StatelessWidget {
  final DateTime date;
  final List<TodayTxn> transactions;
  final List<TodayTxn> incomeTransactions;
  final int dailyBudgetPaise;

  const DayDetailSheet({
    super.key,
    required this.date,
    required this.transactions,
    this.incomeTransactions = const [],
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
      if (incomeTransactions.isNotEmpty) {
        return 'Money came in today. No everyday spending '
            'was tracked, so there is no spending verdict.';
      }

      return 'No tracked transactions for this day. '
          'Your bank SMS history will fill this in.';
    }

    if (dailyBudgetPaise <= 0) {
      return 'Your spending is tracked, but no positive '
          'daily budget is available for comparison.';
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
    final sortedSpending = [...transactions]
      ..sort((a, b) => b.amountPaise.compareTo(a.amountPaise));

    final sortedIncome = [...incomeTransactions]
      ..sort((a, b) => b.at.compareTo(a.at));

    final spent = transactions.fold<int>(
      0,
      (sum, txn) => sum + txn.amountPaise,
    );

    final received = incomeTransactions.fold<int>(
      0,
      (sum, txn) => sum + txn.amountPaise,
    );

    final difference = dailyBudgetPaise - spent;
    final hasSpending = transactions.isNotEmpty;
    final hasIncome = incomeTransactions.isNotEmpty;

    final statusColor = !hasSpending
        ? AppColors.textSecondary
        : dailyBudgetPaise <= 0 || difference < 0
        ? AppColors.red
        : spent >= dailyBudgetPaise * 0.8
        ? AppColors.amber
        : AppColors.mint;

    final statusText = !hasSpending
        ? 'No spending'
        : dailyBudgetPaise <= 0
        ? 'No budget set'
        : difference < 0
        ? 'Over by ${_money(-difference)}'
        : '${_money(difference)} left';

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
                      style: _title(11, color: AppColors.textSecondary),
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
                  Text(_money(spent), style: _title(22, color: statusColor)),
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
                      statusText,
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
                  hasSpending
                      ? Icons.local_fire_department_outlined
                      : hasIncome
                      ? Icons.south_west_rounded
                      : Icons.info_outline,
                  color: hasIncome && !hasSpending
                      ? AppColors.mint
                      : AppColors.primary,
                  size: 21,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _verdict(spent),
                    style: _body(13, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Text('TOP 3 SPENDS', style: _title(12)),
              const Spacer(),
              Text('${transactions.length} items tracked', style: _body(11)),
            ],
          ),
          const SizedBox(height: 12),

          if (sortedSpending.isEmpty)
            _emptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No spending recorded',
              subtitle: 'Tracked spending will appear here.',
            )
          else
            for (final txn in sortedSpending.take(3)) ...[
              _transactionTile(txn, isIncome: false),
              const SizedBox(height: 8),
            ],

          if (hasSpending) ...[
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
                      style: _title(14, color: AppColors.onPrimary),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_forward, size: 19),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 20),

          Row(
            children: [
              const Icon(
                Icons.south_west_rounded,
                color: AppColors.mint,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text('INCOMING CREDITS', style: _title(12))),
              Text(
                '+${_money(received)}',
                style: _title(15, color: AppColors.mint),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            '${incomeTransactions.length} incoming transactions',
            style: _body(11),
          ),
          const SizedBox(height: 14),

          if (sortedIncome.isEmpty)
            _emptyState(
              icon: Icons.account_balance_wallet_outlined,
              title: 'No income recorded',
              subtitle: 'Incoming bank credits will appear here.',
            )
          else
            for (final txn in sortedIncome) ...[
              _transactionTile(txn, isIncome: true),
              const SizedBox(height: 8),
            ],

          if (hasIncome) ...[
            const SizedBox(height: 10),
            Text(
              'Credits are tracked separately and do not '
              'increase your daily spending budget.',
              style: _body(11),
            ),
          ],
        ],
      ),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 30),
          const SizedBox(height: 10),
          Text(title, style: _title(13)),
          const SizedBox(height: 5),
          Text(subtitle, textAlign: TextAlign.center, style: _body(11)),
        ],
      ),
    );
  }

  Widget _transactionTile(TodayTxn txn, {required bool isIncome}) {
    final amountColor = isIncome ? AppColors.mint : AppColors.textPrimary;

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
              isIncome ? Icons.south_west_rounded : txn.icon,
              color: isIncome ? AppColors.mint : txn.color,
              size: 21,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.merchant.trim().isEmpty
                      ? (isIncome ? 'Incoming credit' : 'Unknown merchant')
                      : txn.merchant,
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
                '${isIncome ? '+' : '−'} ${_money(txn.amountPaise)}',
                style: _title(13, color: amountColor),
              ),
              const SizedBox(height: 4),
              Text(txn.mode, style: _body(10)),
            ],
          ),
        ],
      ),
    );
  }
}
