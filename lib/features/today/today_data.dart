import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/db/app_database.dart';
import '../../data/repos/budget_loader.dart';
import '../../domain/budget/daily_budget.dart';
import '../../providers/db_provider.dart';
import '../../providers/settings_provider.dart';

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

  /// true for money received.
  final bool isCredit;

  /// spend | family | savings | emi | income | internal | refund
  final String kind;

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
    this.isCredit = false,
    this.kind = 'spend',
  });

  double get rupees => amountPaise / 100;
}

/// A detected credit that may be the user's salary.
class IncomeSuggestion {
  final String txnId;
  final int amountPaise;
  const IncomeSuggestion(this.txnId, this.amountPaise);
}

/// Everything the Today screen needs in one object.
class TodayData {
  final String userName;
  final DateTime now;
  final String syncLabel;
  final DailyBudget budget;

  /// Today's real spending (kind = spend), newest first.
  final List<TodayTxn> txns;

  /// Real spending from the last ~6 months (Money Map + Calendar use this).
  final List<TodayTxn> historyTxns;

  /// Money received today (kind = income), newest first.
  final List<TodayTxn> todayCredits;
  final int todayIncomePaise;

  /// Money received in the last ~6 months (kind = income).
  final List<TodayTxn> historyIncomeTxns;

  /// Non-spend debits (family / savings / emi) in the last ~6 months.
  final List<TodayTxn> historyOtherTxns;

  final int weekSpentPaise;
  final int weekBudgetPaise;

  /// Spending since the cycle start.
  final int monthSpentPaise;

  /// Typed monthly income.
  final int monthIncomePaise;

  /// Income minus commitments (the pool the cycle spending is measured against).
  final int monthBudgetPaise;

  final int streakDays;
  final int streakSavedPaise;

  /// Set when a received credit looks like the salary and differs from typed income.
  final IncomeSuggestion? incomeSuggestion;

  const TodayData({
    required this.userName,
    required this.now,
    required this.syncLabel,
    required this.budget,
    required this.txns,
    this.historyTxns = const [],
    this.todayCredits = const [],
    this.todayIncomePaise = 0,
    this.historyIncomeTxns = const [],
    this.historyOtherTxns = const [],
    required this.weekSpentPaise,
    required this.weekBudgetPaise,
    required this.monthSpentPaise,
    required this.monthIncomePaise,
    this.monthBudgetPaise = 0,
    required this.streakDays,
    required this.streakSavedPaise,
    this.incomeSuggestion,
  });
}

IconData _kindIcon(String kind) {
  switch (kind) {
    case 'family':
      return Icons.home_outlined;
    case 'savings':
      return Icons.savings_outlined;
    case 'emi':
      return Icons.account_balance_outlined;
    default:
      return Icons.receipt_long_outlined;
  }
}

// ── Live local data provider ───────────────────────────────────────────────
final todayDataProvider = FutureProvider<TodayData>((ref) async {
  final settings = await ref.watch(settingsProvider.future);
  final db = ref.watch(dbProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final weekStart = today.subtract(Duration(days: now.weekday - 1));
  final cycle = BudgetCycle.forDate(now, settings.payDay);
  final historyStart = DateTime(now.year, now.month - 5, 1);

  final historyRows =
      await (db.select(db.txns)
            ..where((t) => t.at.isBiggerOrEqualValue(historyStart))
            ..orderBy([(t) => OrderingTerm.desc(t.at)]))
          .get();

  bool isSpend(Txn t) => t.direction == 'debit' && t.kind == 'spend';
  bool isIncome(Txn t) => t.direction == 'credit' && t.kind == 'income';
  bool isOtherOut(Txn t) => t.direction == 'debit' && t.kind != 'spend';
  bool isToday(Txn t) => !t.at.isBefore(today);
  int sum(Iterable<Txn> rows) => rows.fold<int>(0, (s, t) => s + t.amount);

  TodayTxn toTxn(Txn t) {
    final credit = t.direction == 'credit';
    return TodayTxn(
      id: t.id,
      merchant: t.payee ?? (credit ? 'Money received' : 'Unknown merchant'),
      note: credit ? 'Credit' : (t.category ?? 'Uncategorized'),
      category: credit ? 'Income' : (t.category ?? 'Uncategorized'),
      mode: t.mode,
      amountPaise: t.amount,
      at: t.at,
      icon: credit ? Icons.south_west : _kindIcon(t.kind),
      color: credit ? AppColors.mint : AppColors.primary,
      isCredit: credit,
      kind: t.kind,
    );
  }

  final spendRows = historyRows.where(isSpend).toList();
  final incomeRows = historyRows.where(isIncome).toList();
  final otherRows = historyRows.where(isOtherOut).toList();

  final txns = spendRows.where(isToday).map(toTxn).toList();
  final todayCredits = incomeRows.where(isToday).map(toTxn).toList();
  final historyTxns = spendRows.map(toTxn).toList();
  final historyIncomeTxns = incomeRows.map(toTxn).toList();
  final historyOtherTxns = otherRows.map(toTxn).toList();

  final weekSpent = sum(spendRows.where((t) => !t.at.isBefore(weekStart)));
  final monthSpent = sum(spendRows.where((t) => !t.at.isBefore(cycle.start)));

  final budget = await loadDailyBudget(db, settings, now);

  // Savings streak: consecutive days (ending yesterday) at or under the daily
  // budget, counted only from the first day we have any data for.
  var streak = 0;
  var saved = 0;
  if (historyRows.isNotEmpty && budget.dailyBudgetPaise > 0) {
    final first = historyRows
        .map((t) => DateTime(t.at.year, t.at.month, t.at.day))
        .reduce((a, b) => a.isBefore(b) ? a : b);
    final perDay = <DateTime, int>{};
    for (final t in spendRows) {
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

  // Salary suggestion: the biggest credit this cycle (>= Rs 10,000) when it differs
  // from the typed income by more than 2% and was not already answered.
  IncomeSuggestion? suggestion;
  final cycleCredits = incomeRows.where(
    (t) => !t.at.isBefore(cycle.start) && t.amount >= 1000000,
  );
  if (cycleCredits.isNotEmpty) {
    final big = cycleCredits.reduce((a, b) => a.amount >= b.amount ? a : b);
    final typed = settings.monthlyIncomePaise;
    final differs = typed <= 0 || (big.amount - typed).abs() / typed > 0.02;
    if (differs && big.id != settings.dismissedIncomeSuggestionId) {
      suggestion = IncomeSuggestion(big.id, big.amount);
    }
  }

  return TodayData(
    userName: settings.displayName.isEmpty ? 'there' : settings.displayName,
    now: now,
    syncLabel: 'LOCAL DATA',
    budget: budget,
    txns: txns,
    historyTxns: historyTxns,
    todayCredits: todayCredits,
    todayIncomePaise: sum(incomeRows.where(isToday)),
    historyIncomeTxns: historyIncomeTxns,
    historyOtherTxns: historyOtherTxns,
    weekSpentPaise: weekSpent,
    weekBudgetPaise: budget.dailyBudgetPaise * 7,
    monthSpentPaise: monthSpent,
    monthIncomePaise: settings.monthlyIncomePaise,
    monthBudgetPaise: budget.flexiblePoolPaise,
    streakDays: streak,
    streakSavedPaise: saved,
    incomeSuggestion: suggestion,
  );
});
