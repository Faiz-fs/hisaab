import 'package:drift/drift.dart' as drift;

import '../../domain/categorizer/categorizer.dart';
import '../db/app_database.dart';

/// A payee rule plus how many debit transactions it currently matches.
class RuleWithCount {
  final PayeeRule rule;
  final int count;
  const RuleWithCount(this.rule, this.count);
}

/// Creates, edits and deletes payee rules and re-applies them to past
/// transactions. Rows the user set by hand (categorySource = 'user') are never
/// changed. Future SMS use the same rules through the ingest service.
class RuleService {
  final AppDatabase db;
  const RuleService(this.db);

  static UserRule _toUser(PayeeRule r) => UserRule(
    pattern: r.pattern,
    category: r.category,
    isRegex: r.isRegex,
    kind: r.kind,
  );

  Future<List<UserRule>> _allRules() async =>
      (await db.payeeRulesDao.getAllRules()).map(_toUser).toList();

  Future<List<Txn>> _debitsWithPayee() => (db.select(
    db.txns,
  )..where((t) => t.direction.equals('debit') & t.payee.isNotNull())).get();

  List<Txn> _matching(List<Txn> rows, UserRule rule) =>
      rows.where((t) => Categorizer.ruleHits(rule, t.payee!)).toList();

  /// Auto-categorises debits that still have no category (older imports, or
  /// payees the dictionary did not know before). Never touches rows with a
  /// category or rows the user set by hand. Returns rows changed.
  Future<int> categorizeUncategorized() async {
    final rows =
        await (db.select(db.txns)..where(
              (t) =>
                  t.direction.equals('debit') &
                  t.payee.isNotNull() &
                  t.category.isNull() &
                  t.categorySource.equals('auto'),
            ))
            .get();
    if (rows.isEmpty) return 0;
    return _recompute(rows, await _allRules());
  }

  /// All rules with the number of transactions each one matches.
  Future<List<RuleWithCount>> rulesWithCounts() async {
    final rules = await db.payeeRulesDao.getAllRules();
    final rows = await _debitsWithPayee();
    final list = [
      for (final r in rules)
        RuleWithCount(r, _matching(rows, _toUser(r)).length),
    ];
    list.sort(
      (a, b) =>
          a.rule.pattern.toLowerCase().compareTo(b.rule.pattern.toLowerCase()),
    );
    return list;
  }

  /// Re-derives category + kind for [rows] from the current rules
  /// (user rules, then built-in merchants). Returns how many rows changed.
  Future<int> _recompute(Iterable<Txn> rows, List<UserRule> rules) async {
    var changed = 0;
    for (final t in rows) {
      if (t.categorySource == 'user') continue;
      final m = const Categorizer().match(t.payee, userRules: rules);
      final String? category = m?.category;
      final String kind = m?.kind ?? 'spend';
      if (t.category == category && t.kind == kind) continue;
      await (db.update(db.txns)..where((x) => x.id.equals(t.id))).write(
        TxnsCompanion(category: drift.Value(category), kind: drift.Value(kind)),
      );
      changed++;
    }
    return changed;
  }

  /// Creates a rule ([id] null) or edits one, then re-applies it.
  /// Returns the number of transactions that changed.
  Future<int> saveRule({
    int? id,
    required String pattern,
    required String category,
    required String kind,
    bool isRegex = false,
  }) async {
    final rows = await _debitsWithPayee();
    var oldHits = <Txn>[];
    if (id != null) {
      final old = await (db.select(
        db.payeeRules,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      if (old != null) oldHits = _matching(rows, _toUser(old));
    }

    if (id == null) {
      await db.payeeRulesDao.upsertByPattern(
        pattern: pattern,
        category: category,
        kind: kind,
        isRegex: isRegex,
      );
    } else {
      await (db.update(db.payeeRules)..where((t) => t.id.equals(id))).write(
        PayeeRulesCompanion(
          pattern: drift.Value(pattern),
          category: drift.Value(category),
          kind: drift.Value(kind),
          isRegex: drift.Value(isRegex),
        ),
      );
    }

    final rules = await _allRules();
    final newHits = _matching(
      rows,
      UserRule(
        pattern: pattern,
        category: category,
        kind: kind,
        isRegex: isRegex,
      ),
    );
    // Rows matched by the old pattern OR the new one are re-derived.
    final affected = <String, Txn>{
      for (final t in oldHits) t.id: t,
      for (final t in newHits) t.id: t,
    };
    return _recompute(affected.values, rules);
  }

  /// Deletes a rule; its rows fall back to the remaining rules / built-in
  /// merchants (or become uncategorised). Returns rows changed.
  Future<int> deleteRule(int id) async {
    final rows = await _debitsWithPayee();
    final old = await (db.select(
      db.payeeRules,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (old == null) return 0;
    final oldHits = _matching(rows, _toUser(old));
    await db.payeeRulesDao.deleteRule(id);
    return _recompute(oldHits, await _allRules());
  }
}
