import 'package:drift/drift.dart' as drift;

import '../../domain/categorizer/categorizer.dart';
import '../db/app_database.dart';

/// Credit intelligence that needs no SMS text:
///  - own-account transfers (a debit and a credit of the same amount on two of
///    your accounts) are marked kind = 'internal' and excluded from spend AND income;
///  - credits from a payee you tagged Family become kind = 'family' (not income).
/// Rows you categorised by hand (categorySource = 'user') are never touched.
class TransferService {
  final AppDatabase db;
  const TransferService(this.db);

  /// Both legs of a transfer share the UPI ref number, so allow a wide window.
  static const _refWindow = Duration(hours: 1);

  /// Without a ref number only a near-simultaneous pair counts.
  static const _noRefWindow = Duration(minutes: 2);

  /// Pairs debits and credits across different accounts. Returns pairs found.
  Future<int> markOwnTransfers({DateTime? since}) async {
    final from = since ?? DateTime.now().subtract(const Duration(days: 190));
    final rows =
        await (db.select(db.txns)
              ..where(
                (t) =>
                    t.at.isBiggerOrEqualValue(from) &
                    t.kind.isNotValue('internal'),
              )
              ..orderBy([(t) => drift.OrderingTerm.asc(t.at)]))
            .get();

    final debits = rows
        .where((t) => t.direction == 'debit' && t.categorySource != 'user')
        .toList();
    final credits = rows
        .where((t) => t.direction == 'credit' && t.categorySource != 'user')
        .toList();

    final usedCredits = <String>{};
    var pairs = 0;

    for (final d in debits) {
      Txn? best;
      var bestScore = 1 << 40;
      for (final c in credits) {
        if (usedCredits.contains(c.id) ||
            c.accountId == d.accountId ||
            c.amount != d.amount) {
          continue;
        }
        final gap = c.at.difference(d.at).abs();
        final sameRef =
            d.refNo != null && d.refNo!.isNotEmpty && d.refNo == c.refNo;
        if (gap > (sameRef ? _refWindow : _noRefWindow)) continue;
        final score = (sameRef ? 0 : 1000000) + gap.inSeconds;
        if (score < bestScore) {
          best = c;
          bestScore = score;
        }
      }
      if (best == null) continue;
      usedCredits.add(best.id);
      for (final id in [d.id, best.id]) {
        await (db.update(db.txns)..where((t) => t.id.equals(id))).write(
          const TxnsCompanion(
            kind: drift.Value('internal'),
            category: drift.Value('Own transfer'),
            categorySource: drift.Value('auto'),
          ),
        );
      }
      pairs++;
    }
    return pairs;
  }

  /// Credits from a payee that has a Family rule become 'family', not income.
  Future<int> applyFamilyToCredits() async {
    final rules = (await db.payeeRulesDao.getAllRules())
        .where((r) => r.kind == 'family')
        .map(
          (r) => UserRule(
            pattern: r.pattern,
            category: r.category,
            isRegex: r.isRegex,
            kind: r.kind,
          ),
        )
        .toList();
    if (rules.isEmpty) return 0;

    final rows =
        await (db.select(db.txns)..where(
              (t) =>
                  t.direction.equals('credit') &
                  t.kind.equals('income') &
                  t.categorySource.equals('auto') &
                  t.payee.isNotNull(),
            ))
            .get();

    var changed = 0;
    for (final t in rows) {
      if (!rules.any((r) => Categorizer.ruleHits(r, t.payee!))) continue;
      await (db.update(db.txns)..where((x) => x.id.equals(t.id))).write(
        const TxnsCompanion(
          kind: drift.Value('family'),
          category: drift.Value('Family'),
        ),
      );
      changed++;
    }
    return changed;
  }
}
