import 'package:drift/drift.dart';

import '../tables.dart';
import '../app_database.dart';

part 'txns_dao.g.dart';

/// DAO for the [Txns] table.
@DriftAccessor(tables: [Txns])
class TxnsDao extends DatabaseAccessor<AppDatabase> with _$TxnsDaoMixin {
  TxnsDao(super.db);

  /// Inserts a transaction; silently ignores duplicates (dedup by hash id).
  Future<void> insertTxn(TxnsCompanion entry) =>
      into(txns).insertOnConflictUpdate(entry);

  /// Returns all transactions for a given day, newest first.
  Future<List<Txn>> getTxnsForDay(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return (select(txns)
          ..where((t) => t.at.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm.desc(t.at)]))
        .get();
  }

  /// Returns total debit amount in paise for [day].
  Future<int> totalDebitForDay(DateTime day) async {
    final rows = await getTxnsForDay(day);
    return rows
        .where((t) => t.direction == 'debit')
        .fold<int>(0, (sum, t) => sum + t.amount);
  }

  /// Debits that have no category yet, newest first.
  Future<List<Txn>> getUncategorizedDebits() => (select(txns)
        ..where((t) => t.direction.equals('debit') & t.category.isNull())
        ..orderBy([(t) => OrderingTerm.desc(t.at)]))
      .get();

  /// Debits since [from], newest first.
  Future<List<Txn>> getDebitsSince(DateTime from) => (select(txns)
        ..where((t) => t.direction.equals('debit') & t.at.isBiggerOrEqualValue(from))
        ..orderBy([(t) => OrderingTerm.desc(t.at)]))
      .get();

  Future<void> setCategory(String id, String category) =>
      (update(txns)..where((t) => t.id.equals(id)))
          .write(TxnsCompanion(category: Value(category)));

  /// Applies [category] to every debit of [payee] (case-insensitive).
  Future<int> setCategoryForPayee(String payee, String category) =>
      (update(txns)
            ..where((t) => t.direction.equals('debit') & t.payee.lower().equals(payee.toLowerCase())))
          .write(TxnsCompanion(category: Value(category)));
}
