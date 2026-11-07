import 'merchant_rules.dart';

/// A user-defined payee rule.
class UserRule {
  final String pattern;
  final String category;
  final String kind; // spend | family | savings | emi
  final bool isRegex;
  const UserRule({
    required this.pattern,
    required this.category,
    this.kind = 'spend',
    this.isRegex = false,
  });
}

/// Result of a categorisation match.
class CategoryMatch {
  final String category;
  final String kind;
  final bool fromUserRule;
  const CategoryMatch(this.category, this.kind, this.fromUserRule);
}

/// Maps a merchant name to a category and kind.
///
/// Priority: user rules (longest pattern first) -> built-in [kMerchantRules].
class Categorizer {
  const Categorizer();

  CategoryMatch? match(
    String? merchant, {
    List<UserRule> userRules = const [],
  }) {
    if (merchant == null || merchant.trim().isEmpty) return null;
    final lower = merchant.toLowerCase();

    final rules = [...userRules]
      ..sort((a, b) => b.pattern.length.compareTo(a.pattern.length));
    for (final r in rules) {
      try {
        final hit = r.isRegex
            ? RegExp(r.pattern, caseSensitive: false).hasMatch(merchant)
            : lower.contains(r.pattern.toLowerCase());
        if (hit) return CategoryMatch(r.category, r.kind, true);
      } catch (_) {}
    }

    for (final entry in kMerchantRules.entries) {
      final raw = entry.key.trim();
      final key = RegExp.escape(raw);
      // Short keys must match a whole word ("ola" must not match "olive").
      final re = raw.length <= 4
          ? RegExp('\\b$key\\b', caseSensitive: false)
          : RegExp('\\b$key', caseSensitive: false);
      if (re.hasMatch(lower)) return CategoryMatch(entry.value, 'spend', false);
    }
    return null;
  }

  String categorize(String merchant, {List<UserRule> userRules = const []}) =>
      match(merchant, userRules: userRules)?.category ?? 'Other';

  /// Null when nothing matched, so the UI can still ask the user to categorise.
  String? categorizeOrNull(
    String? merchant, {
    List<UserRule> userRules = const [],
  }) => match(merchant, userRules: userRules)?.category;
}
