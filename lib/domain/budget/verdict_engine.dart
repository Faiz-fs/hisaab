import '../models/daily_verdict.dart';
import '../models/txn.dart';

/// Builds a [DailyVerdictModel] from the day's transactions and budget context.
///
/// Rating algorithm (0–10):
///   10  → ≤ 50 % of budget spent
///   7   → ≤ 80 %
///   5   → ≤ 100 %
///   3   → ≤ 120 %
///   0   → > 120 %
class VerdictEngine {
  const VerdictEngine();

  /// Builds a verdict for [date] given [txns] and the [dailyBudgetPaise].
  DailyVerdictModel buildVerdict({
    required DateTime date,
    required List<TxnModel> txns,
    required int dailyBudgetPaise,
  }) {
    final debits = txns.where((t) => t.isSpend).toList();
    final totalSpent = debits.fold<int>(0, (sum, t) => sum + t.amountPaise);

    // Top 3 culprit categories by spend
    final categoryTotals = <String, int>{};
    for (final t in debits) {
      final cat = t.category ?? 'Other';
      categoryTotals[cat] = (categoryTotals[cat] ?? 0) + t.amountPaise;
    }
    final sorted = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCulprits = sorted.take(3).map((e) => e.key).toList();

    final pct = dailyBudgetPaise > 0 ? totalSpent / dailyBudgetPaise : 0.0;
    final rating = pct <= 0.5
        ? 10
        : pct <= 0.8
        ? 7
        : pct <= 1.0
        ? 5
        : pct <= 1.2
        ? 3
        : 0;

    return DailyVerdictModel(
      date: date,
      rating: rating,
      totalSpentPaise: totalSpent,
      topCulprits: topCulprits,
      overBudget: totalSpent > dailyBudgetPaise,
    );
  }
}
