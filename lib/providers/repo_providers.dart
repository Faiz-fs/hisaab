import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repos/settings_repo.dart';
import '../data/repos/account_repo.dart';
import '../domain/models/settings.dart';
import '../domain/models/account.dart';
import '../data/repos/txn_repo.dart';
import '../data/repos/verdict_repo.dart';
import 'db_provider.dart';

// ── Settings ──────────────────────────────────────────────────

final settingsRepoProvider = Provider<SettingsRepo>((ref) => SettingsRepo());

/// Async provider that loads [Settings] from
/// shared_preferences on first access.
final settingsProvider = FutureProvider<Settings>((ref) {
  final repo = ref.watch(settingsRepoProvider);
  return repo.load();
});

// ── Bank Accounts ─────────────────────────────────────────────

/// SQLite-backed account repository.
final accountRepoProvider = Provider<AccountRepo>((ref) {
  final db = ref.watch(dbProvider);
  return DriftAccountRepo(db);
});

/// Loads saved bank accounts from the local database.
///
/// Invalidate after inserting or updating an account
/// to refresh the UI.
final accountsProvider = FutureProvider<List<AccountModel>>((ref) {
  final repo = ref.watch(accountRepoProvider);
  return repo.getAll();
});

// ── Transactions & verdicts ───────────────────────────────────

final txnRepoProvider = Provider<TxnRepo>((ref) => DriftTxnRepo(ref.watch(dbProvider)));
final verdictRepoProvider = Provider<VerdictRepo>((ref) => DriftVerdictRepo(ref.watch(dbProvider)));
