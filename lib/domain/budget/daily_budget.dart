

/// Daily budget calculation helpers.
///
/// All amounts are in **paise**.
class DailyBudget {
  final int monthlyIncomePaise;
  final int spentTodayPaise;
  final DateTime date;

  const DailyBudget({
    required this.monthlyIncomePaise,
    required this.spentTodayPaise,
    required this.date,
  });

  /// Daily allowance = income / 30 (simple even split).
  int get dailyBudgetPaise => (monthlyIncomePaise / 30).round();

  /// Percentage of daily budget consumed (0.0 – can exceed 1.0).
  double get burnPct =>
      dailyBudgetPaise > 0 ? spentTodayPaise / dailyBudgetPaise : 0;

  /// Remaining budget for today in paise (can be negative if overspent).
  int get leftPaise => dailyBudgetPaise - spentTodayPaise;

  /// Suggested cap for tomorrow, accounting for today's surplus/deficit.
  int get tomorrowCapPaise => dailyBudgetPaise - leftPaise.clamp(0, dailyBudgetPaise);

  bool get isOverBudget => spentTodayPaise > dailyBudgetPaise;
}
