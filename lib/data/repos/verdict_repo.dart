import 'dart:convert';

import 'package:drift/drift.dart' as drift;

import '../../domain/models/daily_verdict.dart';
import '../db/app_database.dart';

/// Repository interface for daily verdict persistence.
abstract class VerdictRepo {
  Future<void> upsert(DailyVerdictModel verdict);
  Future<DailyVerdictModel?> getForDay(DateTime day);
  Future<List<DailyVerdictModel>> getRecent({int limit = 30});
}

/// SQLite-backed [VerdictRepo].
class DriftVerdictRepo implements VerdictRepo {
  final AppDatabase db;
  DriftVerdictRepo(this.db);

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  static DailyVerdictModel _toModel(DailyVerdict r) {
    List<String> culprits = const [];
    bool over = false;
    try {
      final j = jsonDecode(r.verdictJson) as Map<String, dynamic>;
      over = j['overBudget'] == true;
      culprits = (jsonDecode(r.topCulprits) as List).cast<String>();
    } catch (_) {}
    return DailyVerdictModel(
      date: r.date,
      rating: r.rating,
      totalSpentPaise: r.totalSpent,
      topCulprits: culprits,
      overBudget: over,
    );
  }

  @override
  Future<void> upsert(DailyVerdictModel v) async {
    // `date` is a unique key: reuse the existing row id so this updates in place.
    final existing = await db.verdictsDao.getVerdictForDay(v.date);
    await db.verdictsDao.upsertVerdict(
      DailyVerdictsCompanion(
        id: existing == null
            ? const drift.Value.absent()
            : drift.Value(existing.id),
        date: drift.Value(_day(v.date)),
        rating: drift.Value(v.rating),
        totalSpent: drift.Value(v.totalSpentPaise),
        topCulprits: drift.Value(jsonEncode(v.topCulprits)),
        verdictJson: drift.Value(jsonEncode({'overBudget': v.overBudget})),
      ),
    );
  }

  @override
  Future<DailyVerdictModel?> getForDay(DateTime day) async {
    final r = await db.verdictsDao.getVerdictForDay(day);
    return r == null ? null : _toModel(r);
  }

  @override
  Future<List<DailyVerdictModel>> getRecent({int limit = 30}) async =>
      (await db.verdictsDao.getRecentVerdicts(limit: limit))
          .map(_toModel)
          .toList();
}
