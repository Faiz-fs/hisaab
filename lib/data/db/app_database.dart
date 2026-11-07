import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'dart:io';

import 'tables.dart';
import 'daos/accounts_dao.dart';
import 'daos/txns_dao.dart';
import 'daos/payee_rules_dao.dart';
import 'daos/verdicts_dao.dart';

part 'app_database.g.dart';

/// Main Drift database for Hisaab.
@DriftDatabase(
  tables: [Accounts, Txns, PayeeRules, DailyVerdicts],
  daos: [AccountsDao, TxnsDao, PayeeRulesDao, VerdictsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(txns, txns.kind);
        await m.addColumn(txns, txns.categorySource);
        await m.addColumn(payeeRules, payeeRules.kind);
        // Backfill: debits stay 'spend' (column default), credits become income.
        await customStatement(
          "UPDATE txns SET kind = 'income' WHERE direction = 'credit'",
        );
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'hisaab.db'));
    return NativeDatabase.createInBackground(file);
  });
}
