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

class _Payee {
  final String compact; // "bharatpetroleum"
  final List<String> tokens; // ["bharat", "petroleum"]
  const _Payee(this.compact, this.tokens);
}

/// Maps a payee to a category and kind.
///
/// Priority: the user's own payee rules (longest pattern first), then the
/// built-in [kBuiltinRules]. Returns null when nothing is recognised, so the
/// app can ask the user once (Categorise Spending) and remember the answer.
class Categorizer {
  const Categorizer();

  /// True when [r] matches [merchant]. Shared by ingest and the rule service.
  static bool ruleHits(UserRule r, String merchant) {
    if (r.pattern.trim().isEmpty) return false;
    try {
      return r.isRegex
          ? RegExp(r.pattern, caseSensitive: false).hasMatch(merchant)
          : merchant.toLowerCase().contains(r.pattern.toLowerCase());
    } catch (_) {
      return false;
    }
  }

  static _Payee _normalise(String merchant) {
    final lower = merchant.toLowerCase();
    // For a UPI id the part after "@" is the bank/app handle (ybl, okaxis...),
    // not a hint about the merchant.
    final at = lower.indexOf('@');
    final base = at > 0 ? lower.substring(0, at) : lower;
    final tokens = base
        .split(RegExp(r'[^a-z0-9]+'))
        .where((t) => t.isNotEmpty)
        .toList();
    return _Payee(tokens.join(), tokens);
  }

  static bool _keyHits(String key, _Payee p) {
    var k = key;
    var exact = false;
    if (k.startsWith('=')) {
      exact = true;
      k = k.substring(1);
    }
    if (exact || k.length <= 3) return p.tokens.contains(k);
    if (k.length <= 5) return p.tokens.any((t) => t.startsWith(k));
    return p.compact.contains(k);
  }

  CategoryMatch? match(
    String? merchant, {
    List<UserRule> userRules = const [],
  }) {
    if (merchant == null || merchant.trim().isEmpty) return null;

    final rules = [...userRules]
      ..sort((a, b) => b.pattern.length.compareTo(a.pattern.length));
    for (final r in rules) {
      if (ruleHits(r, merchant)) return CategoryMatch(r.category, r.kind, true);
    }

    final payee = _normalise(merchant);
    if (payee.compact.isEmpty) return null;
    for (final (key, category) in kBuiltinRules) {
      if (_keyHits(key, payee)) {
        return CategoryMatch(
          category,
          kCategoryKinds[category] ?? 'spend',
          false,
        );
      }
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
