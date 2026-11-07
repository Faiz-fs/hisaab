import 'package:drift/drift.dart';

import '../tables.dart';
import '../app_database.dart';

part 'accounts_dao.g.dart';

/// DAO for the [Accounts] table.
@DriftAccessor(tables: [Accounts])
class AccountsDao extends DatabaseAccessor<AppDatabase> with _$AccountsDaoMixin {
  AccountsDao(super.db);

  /// Returns all accounts ordered by bankName.
  Future<List<Account>> getAllAccounts() =>
      (select(accounts)..orderBy([(t) => OrderingTerm.asc(t.bankName)])).get();

  /// Inserts or replaces an account.
  Future<void> upsertAccount(AccountsCompanion entry) =>
      into(accounts).insertOnConflictUpdate(entry);

  /// Updates the balance for [accountId] to [newBalancePaise].
  Future<void> updateBalance(String accountId, int newBalancePaise) =>
      (update(accounts)..where((t) => t.id.equals(accountId))).write(
        AccountsCompanion(
          balance: Value(newBalancePaise),
          updatedAt: Value(DateTime.now()),
        ),
      );
}
