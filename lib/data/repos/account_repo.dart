import 'package:drift/drift.dart' as drift;

import '../../domain/models/account.dart';
import '../db/app_database.dart';

/// Repository interface for account persistence.
abstract class AccountRepo {
  Future<List<AccountModel>> getAll();
  Future<void> upsert(AccountModel account);
  Future<void> updateBalance(String id, int balancePaise);
}

/// SQLite-backed implementation of [AccountRepo].
///
/// Uses the existing AccountsDao and stores only the
/// bank name, last four digits, and current known balance.
class DriftAccountRepo implements AccountRepo {
  final AppDatabase db;

  DriftAccountRepo(this.db);

  @override
  Future<List<AccountModel>> getAll() async {
    final rows = await db.accountsDao.getAllAccounts();

    return rows.map((row) {
      return AccountModel(
        id: row.id,
        bankName: row.bankName,
        last4: row.last4,
        balancePaise: row.balance,
        updatedAt: row.updatedAt,
      );
    }).toList();
  }

  @override
  Future<void> upsert(AccountModel account) async {
    await db.accountsDao.upsertAccount(
      AccountsCompanion(
        id: drift.Value(account.id),
        bankName: drift.Value(account.bankName),
        last4: drift.Value(account.last4),
        balance: drift.Value(account.balancePaise),
        updatedAt: drift.Value(account.updatedAt),
      ),
    );
  }

  @override
  Future<void> updateBalance(String id, int balancePaise) {
    return db.accountsDao.updateBalance(id, balancePaise);
  }
}
