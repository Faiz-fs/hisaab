/// Daily verdict domain model.
/// One per calendar day, summarising spend behaviour and rating.
class DailyVerdictModel {
  final DateTime date;

  /// Rating 0–10 (10 = perfect).
  final int rating;

  /// Total spent today in paise.
  final int totalSpentPaise;

  /// Top 3 culprit categories.
  final List<String> topCulprits;

  /// Whether the user was over or under budget.
  final bool overBudget;

  const DailyVerdictModel({
    required this.date,
    required this.rating,
    required this.totalSpentPaise,
    required this.topCulprits,
    required this.overBudget,
  });

  double get totalSpentRupees => totalSpentPaise / 100;
}
