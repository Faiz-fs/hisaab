import 'package:drift/drift.dart';

import '../tables.dart';
import '../app_database.dart';

part 'verdicts_dao.g.dart';

/// DAO for the [DailyVerdicts] table.
@DriftAccessor(tables: [DailyVerdicts])
class VerdictsDao extends DatabaseAccessor<AppDatabase>
    with _$VerdictsDaoMixin {
  VerdictsDao(super.db);

  /// Upserts the daily verdict for [date].
  Future<void> upsertVerdict(DailyVerdictsCompanion entry) =>
      into(dailyVerdicts).insertOnConflictUpdate(entry);

  /// Returns the verdict for [date] if it exists.
  Future<DailyVerdict?> getVerdictForDay(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return (select(dailyVerdicts)..where((t) => t.date.equals(day)))
        .getSingleOrNull();
  }

  /// Returns the last [limit] verdicts ordered by date descending.
  Future<List<DailyVerdict>> getRecentVerdicts({int limit = 30}) =>
      (select(dailyVerdicts)
            ..orderBy([(t) => OrderingTerm.desc(t.date)])
            ..limit(limit))
          .get();
}
