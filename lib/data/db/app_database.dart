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
/// Tables: Accounts, Txns, PayeeRules, DailyVerdicts.
/// DAOs are code-generated via build_runner.
@DriftDatabase(
  tables: [Accounts, Txns, PayeeRules, DailyVerdicts],
  daos: [AccountsDao, TxnsDao, PayeeRulesDao, VerdictsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'hisaab.db'));
    return NativeDatabase.createInBackground(file);
  });
}
