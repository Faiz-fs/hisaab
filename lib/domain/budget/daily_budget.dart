import 'dart:math' as math;

/// A budget cycle: [start] (inclusive) to [endExclusive].
/// payDay = 1 behaves exactly like a calendar month.
class BudgetCycle {
  final DateTime start;
  final DateTime endExclusive;
  const BudgetCycle(this.start, this.endExclusive);

  factory BudgetCycle.forDate(DateTime date, int payDay) {
    final d = DateTime(date.year, date.month, date.day);
    final pd = math.min(28, math.max(1, payDay));
    final thisMonth = DateTime(d.year, d.month, pd);
    final start = d.isBefore(thisMonth)
        ? DateTime(d.year, d.month - 1, pd)
        : thisMonth;
    return BudgetCycle(start, DateTime(start.year, start.month + 1, pd));
  }

  /// Number of days in the cycle.
  int get totalDays => (endExclusive.difference(start).inHours / 24).round();

  /// Days left from [date] to the end of the cycle, including [date] (min 1).
  int daysLeftFrom(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final n = (endExclusive.difference(d).inHours / 24).round();
    return n < 1 ? 1 : n;
  }
}

/// Daily budget calculation. All amounts are in **paise**.
///
/// quota = (income - commitments) / days in cycle.
/// Only real spending (kind = spend) is passed in as spent amounts.
class DailyBudget {
  final int monthlyIncomePaise;
  final int spentTodayPaise;
  final DateTime date;

  /// Fixed monthly commitments (family support, rent, EMI, SIP...).
  final int commitmentsPaise;

  /// Real spending in the whole cycle so far, including today.
  final int spentInCyclePaise;

  /// Cycle start day (1-28).
  final int payDay;

  const DailyBudget({
    required this.monthlyIncomePaise,
    required this.spentTodayPaise,
    required this.date,
    this.commitmentsPaise = 0,
    this.spentInCyclePaise = 0,
    this.payDay = 1,
  });

  BudgetCycle get cycle => BudgetCycle.forDate(date, payDay);

  /// Money that is actually free to spend this cycle.
  int get flexiblePoolPaise =>
      math.max(0, monthlyIncomePaise - commitmentsPaise);

  /// Daily allowance = flexible pool / days in cycle.
  int get dailyBudgetPaise =>
      cycle.totalDays > 0 ? (flexiblePoolPaise / cycle.totalDays).round() : 0;

  /// Pool remaining after this cycle's spending so far (can be negative).
  int get poolLeftPaise => flexiblePoolPaise - spentInCyclePaise;

  int get daysLeft => cycle.daysLeftFrom(date);

  /// What you could spend per remaining day to finish the cycle exactly on budget.
  int get paceDailyPaise => math.max(0, (poolLeftPaise / daysLeft).round());

  /// Percentage of daily budget consumed (can exceed 1.0).
  double get burnPct =>
      dailyBudgetPaise > 0 ? spentTodayPaise / dailyBudgetPaise : 0;

  /// Remaining budget for today in paise (negative if overspent).
  int get leftPaise => dailyBudgetPaise - spentTodayPaise;

  /// Suggested cap for tomorrow, accounting for today's surplus/deficit.
  int get tomorrowCapPaise =>
      dailyBudgetPaise - math.min(dailyBudgetPaise, math.max(0, leftPaise));

  bool get isOverBudget => spentTodayPaise > dailyBudgetPaise;
}
