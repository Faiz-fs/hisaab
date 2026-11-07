import 'package:drift/drift.dart';

import '../tables.dart';
import '../app_database.dart';

part 'txns_dao.g.dart';

/// DAO for the [Txns] table.
@DriftAccessor(tables: [Txns])
class TxnsDao extends DatabaseAccessor<AppDatabase> with _$TxnsDaoMixin {
  TxnsDao(super.db);

  /// Inserts a transaction; replaces on duplicate id.
  Future<void> insertTxn(TxnsCompanion entry) =>
      into(txns).insertOnConflictUpdate(entry);

  /// All transactions (any kind) for a given day, newest first.
  Future<List<Txn>> getTxnsForDay(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return (select(txns)
          ..where((t) => t.at.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm.desc(t.at)]))
        .get();
  }

  /// Sum of real spending (debit AND kind = spend) in [start, endExclusive).
  Future<int> spendBetween(DateTime start, DateTime endExclusive) async {
    final total = txns.amount.sum();
    final query = selectOnly(txns)
      ..addColumns([total])
      ..where(
        txns.direction.equals('debit') &
            txns.kind.equals('spend') &
            txns.at.isBiggerOrEqualValue(start) &
            txns.at.isSmallerThanValue(endExclusive),
      );
    final row = await query.getSingle();
    return row.read(total) ?? 0;
  }

  /// Real spending for one calendar day, in paise.
  Future<int> totalSpendForDay(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    return spendBetween(start, start.add(const Duration(days: 1)));
  }

  /// Debits that have no category yet, newest first.
  Future<List<Txn>> getUncategorizedDebits() =>
      (select(txns)
            ..where((t) => t.direction.equals('debit') & t.category.isNull())
            ..orderBy([(t) => OrderingTerm.desc(t.at)]))
          .get();

  /// ALL debits since [from] (every kind), so family/SIP transfers can be tagged.
  Future<List<Txn>> getDebitsSince(DateTime from) =>
      (select(txns)
            ..where(
              (t) =>
                  t.direction.equals('debit') & t.at.isBiggerOrEqualValue(from),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.at)]))
          .get();

  /// Sets category + kind on one transaction.
  /// [source] 'user' protects it from later automatic changes;
  /// use 'auto' when the change comes from a payee rule.
  Future<void> setCategory(
    String id,
    String category, {
    String kind = 'spend',
    String source = 'user',
  }) => (update(txns)..where((t) => t.id.equals(id))).write(
    TxnsCompanion(
      category: Value(category),
      kind: Value(kind),
      categorySource: Value(source),
    ),
  );

  /// Applies a payee rule to every debit of [payee] (case-insensitive),
  /// skipping rows the user set manually (categorySource = 'user').
  Future<int> applyRuleToPayee(String payee, String category, String kind) =>
      (update(txns)..where(
            (t) =>
                t.direction.equals('debit') &
                t.payee.lower().equals(payee.toLowerCase()) &
                t.categorySource.equals('auto'),
          ))
          .write(TxnsCompanion(category: Value(category), kind: Value(kind)));
}
