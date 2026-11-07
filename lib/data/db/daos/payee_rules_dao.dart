import 'package:drift/drift.dart';

import '../tables.dart';
import '../app_database.dart';

part 'payee_rules_dao.g.dart';

/// DAO for the [PayeeRules] table.
@DriftAccessor(tables: [PayeeRules])
class PayeeRulesDao extends DatabaseAccessor<AppDatabase>
    with _$PayeeRulesDaoMixin {
  PayeeRulesDao(super.db);

  Future<List<PayeeRule>> getAllRules() => select(payeeRules).get();

  Future<int> insertRule(PayeeRulesCompanion entry) =>
      into(payeeRules).insert(entry);

  Future<int> deleteRule(int id) =>
      (delete(payeeRules)..where((t) => t.id.equals(id))).go();

  /// Creates or updates the rule for [pattern] (case-insensitive), so a payee
  /// never ends up with two conflicting rules.
  Future<void> upsertByPattern({
    required String pattern,
    required String category,
    required String kind,
    bool isRegex = false,
  }) async {
    final existing = await (select(
      payeeRules,
    )..where((t) => t.pattern.lower().equals(pattern.toLowerCase()))).get();
    if (existing.isEmpty) {
      await into(payeeRules).insert(
        PayeeRulesCompanion.insert(
          pattern: pattern,
          category: category,
          isRegex: Value(isRegex),
          kind: Value(kind),
        ),
      );
      return;
    }
    await (update(
      payeeRules,
    )..where((t) => t.id.equals(existing.first.id))).write(
      PayeeRulesCompanion(
        category: Value(category),
        kind: Value(kind),
        isRegex: Value(isRegex),
      ),
    );
    for (final extra in existing.skip(1)) {
      await deleteRule(extra.id);
    }
  }
}
