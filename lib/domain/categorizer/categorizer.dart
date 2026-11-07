import 'merchant_rules.dart';

/// Maps a merchant name to a spend category.
///
/// Priority: user rules (pattern, category, isRegex) -> built-in
/// [kMerchantRules] -> fallback "Other".
class Categorizer {
  const Categorizer();

  String categorize(String merchant,
      {List<({String pattern, String category, bool isRegex})> userRules = const []}) {
    final lower = merchant.toLowerCase();
    for (final r in userRules) {
      try {
        if (r.isRegex
            ? RegExp(r.pattern, caseSensitive: false).hasMatch(merchant)
            : lower.contains(r.pattern.toLowerCase())) {
          return r.category;
        }
      } catch (_) {}
    }
    for (final entry in kMerchantRules.entries) {
      final raw = entry.key.trim();
      final key = RegExp.escape(raw);
      // Short keys must match a whole word ("ola" must not match "olive").
      final re = raw.length <= 4 ? RegExp('\\b$key\\b', caseSensitive: false) : RegExp('\\b$key', caseSensitive: false);
      if (re.hasMatch(lower)) return entry.value;
    }
    return 'Other';
  }

  /// Null when nothing matched, so the UI can still ask the user to categorise.
  String? categorizeOrNull(String? merchant,
      {List<({String pattern, String category, bool isRegex})> userRules = const []}) {
    if (merchant == null || merchant.trim().isEmpty) return null;
    final c = categorize(merchant, userRules: userRules);
    return c == 'Other' ? null : c;
  }
}
