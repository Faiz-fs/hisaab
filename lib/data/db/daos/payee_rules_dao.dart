import 'package:drift/drift.dart';

import '../tables.dart';
import '../app_database.dart';

part 'payee_rules_dao.g.dart';

/// DAO for the [PayeeRules] table.
@DriftAccessor(tables: [PayeeRules])
class PayeeRulesDao extends DatabaseAccessor<AppDatabase>
    with _$PayeeRulesDaoMixin {
  PayeeRulesDao(super.db);

  /// Returns all payee categorisation rules.
  Future<List<PayeeRule>> getAllRules() => select(payeeRules).get();

  /// Inserts a new rule.
  Future<int> insertRule(PayeeRulesCompanion entry) =>
      into(payeeRules).insert(entry);

  /// Deletes a rule by [id].
  Future<int> deleteRule(int id) =>
      (delete(payeeRules)..where((t) => t.id.equals(id))).go();
}
