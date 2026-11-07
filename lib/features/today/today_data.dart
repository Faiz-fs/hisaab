import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/budget/daily_budget.dart';
import '../../providers/settings_provider.dart';
import '../../providers/db_provider.dart';
import '../../data/db/app_database.dart';
import 'package:drift/drift.dart';

/// One transaction as shown on the Today screen. Amounts are in paise.
class TodayTxn {
  final String id;
  final String merchant;
  final String note;
  final String category;
  final String mode; // UPI / Card / Net Banking / ATM
  final int amountPaise;
  final DateTime at;
  final IconData icon;
  final Color color;

  const TodayTxn({
    required this.id,
    required this.merchant,
    required this.note,
    required this.category,
    required this.mode,
    required this.amountPaise,
    required this.at,
    required this.icon,
    required this.color,
  });

  double get rupees => amountPaise / 100;
}

/// Everything the Today screen needs in one object.
class TodayData {
  final String userName;
  final DateTime now;
  final String syncLabel;
  final DailyBudget budget;
  final List<TodayTxn> txns; // today's debits, newest first
  /// Debits from the last ~6 months (Money Map + Calendar use this).
  final List<TodayTxn> historyTxns;

  final int weekSpentPaise;
  final int weekBudgetPaise;
  final int monthSpentPaise;
  final int monthIncomePaise;
  final int streakDays;
  final int streakSavedPaise;

  const TodayData({
    required this.userName,
    required this.now,
    required this.syncLabel,
    required this.budget,
    required this.txns,
    this.historyTxns = const [],
    required this.weekSpentPaise,
    required this.weekBudgetPaise,
    required this.monthSpentPaise,
    required this.monthIncomePaise,
    required this.streakDays,
    required this.streakSavedPaise,
  });
}

/// Data source for the Today screen. The real implementation will read from
/// the Drift database; for now [MockTodayRepository] fills the UI.
abstract class TodayRepository {
  Future<TodayData> load({bool overspent = false});
}

class MockTodayRepository implements TodayRepository {
  @override
  Future<TodayData> load({bool overspent = false}) async {
    final today = DateTime.now();
    DateTime at(int h, int m) => DateTime(today.year, today.month, today.day, h, m);

    final txns = <TodayTxn>[
      if (overspent)
        TodayTxn(
          id: 't6',
          merchant: 'Social Pub & Bar',
          note: 'Friday plans, apparently',
          category: 'Social',
          mode: 'UPI',
          amountPaise: 170000,
          at: at(17, 40),
          icon: Icons.local_bar_outlined,
          color: AppColors.red,
        ),
      TodayTxn(
        id: 't5',
        merchant: 'Swiggy',
        note: 'Dinner & late iced latte',
        category: 'Food Delivery',
        mode: 'Card',
        amountPaise: 50000,
        at: at(17, 24),
        icon: Icons.lunch_dining_outlined,
        color: AppColors.primary,
      ),
      TodayTxn(
        id: 't4',
        merchant: 'Zepto',
        note: 'Avocados & zero-calorie guilt',
        category: 'Quick Commerce',
        mode: 'UPI',
        amountPaise: 40000,
        at: at(15, 15),
        icon: Icons.bolt_outlined,
        color: AppColors.mint,
      ),
      TodayTxn(
        id: 't3',
        merchant: 'Blinkit',
        note: 'Soda, chips & emergency maggi',
        category: 'Quick Commerce',
        mode: 'UPI',
        amountPaise: 60000,
        at: at(13, 10),
        icon: Icons.shopping_bag_outlined,
        color: AppColors.primary,
      ),
      TodayTxn(
        id: 't2',
        merchant: 'Third Wave Coffee',
        note: 'Fuel for corporate servitude',
        category: 'Cafe',
        mode: 'UPI',
        amountPaise: 25000,
        at: at(9, 42),
        icon: Icons.local_cafe_outlined,
        color: AppColors.textSecondary,
      ),
      TodayTxn(
        id: 't1',
        merchant: 'Amazon',
        note: 'Ergonomic mousepad you didn\'t need',
        category: 'Shopping',
        mode: 'Net Banking',
        amountPaise: 75000,
        at: at(8, 15),
        icon: Icons.inventory_2_outlined,
        color: const Color(0xFFFF8A9B),
      ),
    ];

    final spent = txns.fold<int>(0, (sum, t) => sum + t.amountPaise);
    const income = 10000000; // Rs 1,00,000 in paise

    final budget = DailyBudget(
      monthlyIncomePaise: income,
      spentTodayPaise: spent,
      date: today,
    );

    return TodayData(
      userName: 'Arjun',
      now: at(17, 58), // fixed clock so the mock matches the design
      syncLabel: 'SYNCED 2M AGO',
      budget: budget,
      txns: txns,
      weekSpentPaise: 1840000,
      weekBudgetPaise: budget.dailyBudgetPaise * 7,
      monthSpentPaise: 6420000,
      monthIncomePaise: income,
      streakDays: 4,
      streakSavedPaise: 210000,
    );
  }
}

// ── Live local data providers ──────────────────────────────────────────────
final todayDataProvider = FutureProvider<TodayData>((ref) async {
  final settings = await ref.watch(settingsProvider.future);
  final db = ref.watch(dbProvider);
  final now = DateTime.now();
  final rows = await db.txnsDao.getTxnsForDay(now);
  final monthStart = DateTime(now.year, now.month, 1);
  final weekStart = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
  final historyStart = DateTime(now.year, now.month - 5, 1);
  final historyRows = await (db.select(db.txns)
        ..where((t) => t.at.isBiggerOrEqualValue(historyStart))
        ..orderBy([(t) => OrderingTerm.desc(t.at)]))
      .get();
  final monthRows = historyRows.where((t) => !t.at.isBefore(monthStart)).toList();
  final weekSpent = monthRows.where((t) => !t.at.isBefore(weekStart) && t.direction == 'debit')
      .fold<int>(0, (sum, t) => sum + t.amount);
  final monthSpent = monthRows.where((t) => t.direction == 'debit')
      .fold<int>(0, (sum, t) => sum + t.amount);
  TodayTxn toTxn(Txn t) => TodayTxn(
    id: t.id, merchant: t.payee ?? 'Unknown merchant', note: t.category ?? 'Uncategorized',
    category: t.category ?? 'Uncategorized', mode: t.mode,
    amountPaise: t.amount, at: t.at, icon: Icons.receipt_long_outlined,
    color: AppColors.primary,
  );
  final txns = rows.where((t) => t.direction == 'debit').map(toTxn).toList();
  final historyTxns = historyRows.where((t) => t.direction == 'debit').map(toTxn).toList();
  final spent = txns.fold<int>(0, (sum, t) => sum + t.amountPaise);
  final budget = DailyBudget(monthlyIncomePaise: settings.monthlyIncomePaise,
    spentTodayPaise: spent, date: now);
  // Savings streak: consecutive days (ending yesterday) at or under the daily
  // budget, counted only from the first day we have any data for.
  var streak = 0;
  var saved = 0;
  if (historyRows.isNotEmpty && budget.dailyBudgetPaise > 0) {
    final first = historyRows.map((t) => DateTime(t.at.year, t.at.month, t.at.day)).reduce((a, b) => a.isBefore(b) ? a : b);
    final perDay = <DateTime, int>{};
    for (final t in historyRows.where((t) => t.direction == 'debit')) {
      final d = DateTime(t.at.year, t.at.month, t.at.day);
      perDay[d] = (perDay[d] ?? 0) + t.amount;
    }
    var day = DateTime(now.year, now.month, now.day - 1);
    while (!day.isBefore(first) && streak < 60) {
      final spentDay = perDay[day] ?? 0;
      if (spentDay > budget.dailyBudgetPaise) break;
      streak++;
      saved += budget.dailyBudgetPaise - spentDay;
      day = DateTime(day.year, day.month, day.day - 1);
    }
  }
  return TodayData(
    userName: settings.displayName.isEmpty ? 'there' : settings.displayName,
    now: now, syncLabel: 'LOCAL DATA', budget: budget, txns: txns,
    historyTxns: historyTxns,
    weekSpentPaise: weekSpent, weekBudgetPaise: budget.dailyBudgetPaise * 7,
    monthSpentPaise: monthSpent, monthIncomePaise: settings.monthlyIncomePaise,
    streakDays: streak, streakSavedPaise: saved,
  );
});
