import 'package:drift/drift.dart' as drift;
import '../db/app_database.dart';
import '../parser/parser_registry.dart';
import '../../domain/models/enums.dart';
import '../../domain/categorizer/categorizer.dart';
import 'dedupe.dart';

/// Why an SMS was (not) imported. Used for diagnostics.
enum IngestOutcome {
  imported,
  updated,
  notBank,
  promoOrOtp,
  notTransaction,
  unparsed,
  noAccountMatch,
  ambiguousAccount,
  duplicate,
}

/// Parses financial alerts and stores only extracted fields, never SMS bodies.
class SmsIngestService {
  final AppDatabase db;
  /// Called with the balance printed in each parsed SMS (for balance reconciliation).
  final void Function(String accountId, DateTime at, int balancePaise)? onBalance;
  const SmsIngestService(this.db, {this.onBalance});

  static final _phoneLike = RegExp(r'^\+?\d{8,}$');
  static final _debitRe = RegExp(r'\b(debited|debit of|spent|withdrawn|paid|sent|deducted|purchase|purchased)\b', caseSensitive: false);
  static final _creditRe = RegExp(r'\b(credited|received|deposited)\b', caseSensitive: false);
  static final _otpRe = RegExp(r'\b(OTP|one.time password|verification code)\b', caseSensitive: false);
  static final _promoRe = RegExp(r'\b(offer|cashback offer|loan offer|pre.approved|apply now|click)\b', caseSensitive: false);
  static final _notTxnRe = RegExp(r'(will be (?:debited|credited)|is due|payment due|minimum amount due|requested? (?:money|payment)|collect request|statement)', caseSensitive: false);

  // sender/body tokens for each bank name offered in the Add Bank screen.
  static const _bankTokens = <String, List<String>>{
    'hdfc': ['hdfc'],
    'state bank': ['sbi', 'state bank'],
    'icici': ['icici'],
    'axis': ['axis'],
    'indian bank': ['indbnk', 'indian bank', 'indianbk'],
    'canara': ['canara', 'cnrb'],
    'kotak': ['kotak'],
    'punjab national': ['pnb', 'punjab national'],
    'baroda': ['bob', 'baroda'],
    'union bank': ['union bank', 'ubi'],
    'idfc': ['idfc'],
    'federal': ['federal', 'fedbnk'],
    'indusind': ['indus'],
  };

  /// Returns true only when a new transaction was inserted.
  Future<bool> ingest({required String sender, required String body, required DateTime timestamp}) async =>
      (await ingestDetailed(sender: sender, body: body, timestamp: timestamp)) == IngestOutcome.imported;

  Future<IngestOutcome> ingestDetailed({required String sender, required String body, required DateTime timestamp}) async {
    // Personal numbers are never bank alerts.
    if (_phoneLike.hasMatch(sender.replaceAll(RegExp(r'[\s-]'), ''))) return IngestOutcome.notBank;
    if (_notTxnRe.hasMatch(body)) return IngestOutcome.notTransaction;

    final debitPos = _debitRe.firstMatch(body)?.start ?? -1;
    final creditPos = _creditRe.firstMatch(body)?.start ?? -1;
    if (debitPos == -1 && creditPos == -1) return IngestOutcome.notTransaction;
    // Messages such as "debited ...; NAME credited" mention both: first keyword wins.
    final debit = debitPos != -1 && (creditPos == -1 || debitPos < creditPos);

    if (_otpRe.hasMatch(body) && !RegExp(r'debited|credited', caseSensitive: false).hasMatch(body)) {
      return IngestOutcome.promoOrOtp;
    }

    final parsed = ParserRegistry.parse(sender, body, timestamp);
    if (parsed == null || parsed.amountPaise <= 0) return IngestOutcome.unparsed;
    if (parsed.last4 == null && _promoRe.hasMatch(body)) return IngestOutcome.promoOrOtp;

    final accounts = await db.accountsDao.getAllAccounts();
    final hay = '${sender.toLowerCase()} ${body.toLowerCase()}';

    List<dynamic> matches;
    if (parsed.last4 != null) {
      final l = parsed.last4!;
      // ICICI-style masks show only 3 digits ("XX110"): match on the tail.
      matches = accounts.where((a) => a.last4 == l || (l.length < 4 && a.last4.endsWith(l))).toList();
      if (matches.length > 1) {
        final narrowed = matches.where((a) => _bankMatches(a.bankName, hay)).toList();
        if (narrowed.isNotEmpty) matches = narrowed;
      }
    } else {
      // No digits in the SMS: accept only if exactly one account of that bank exists.
      matches = accounts.where((a) => _bankMatches(a.bankName, hay)).toList();
    }
    if (matches.isEmpty) return IngestOutcome.noAccountMatch;
    if (matches.length != 1) return IngestOutcome.ambiguousAccount;
    final account = matches.single;
    if (parsed.balanceAfterPaise != null) onBalance?.call(account.id, timestamp, parsed.balanceAfterPaise!);

    final id = computeDedupeId(
      bank: account.bankName.toUpperCase(),
      last4: account.last4,
      refNo: parsed.refNo,
      amountPaise: parsed.amountPaise,
      at: timestamp,
    );
    final rules = (await db.payeeRulesDao.getAllRules())
        .map((r) => (pattern: r.pattern, category: r.category, isRegex: r.isRegex))
        .toList();
    final category = debit ? const Categorizer().categorizeOrNull(parsed.payee, userRules: rules) : null;

    final existing = await (db.select(db.txns)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (existing != null) {
      // Re-scan fills in details the older parser missed (payee / category).
      final needPayee = existing.payee == null && parsed.payee != null;
      final needCat = existing.category == null && category != null;
      if (needPayee || needCat) {
        await (db.update(db.txns)..where((t) => t.id.equals(id))).write(TxnsCompanion(
          payee: needPayee ? drift.Value(parsed.payee) : const drift.Value.absent(),
          category: needCat ? drift.Value(category) : const drift.Value.absent(),
        ));
        return IngestOutcome.updated;
      }
      return IngestOutcome.duplicate;
    }
    await db.into(db.txns).insert(TxnsCompanion.insert(
      id: id, accountId: account.id, amount: parsed.amountPaise,
      direction: debit ? Direction.debit.name : Direction.credit.name,
      mode: parsed.mode.name, payee: drift.Value(parsed.payee),
      category: drift.Value(category), refNo: drift.Value(parsed.refNo),
      balanceAfter: drift.Value(parsed.balanceAfterPaise), at: timestamp,
    ), mode: drift.InsertMode.insertOrIgnore);
    // Keep the account balance in step with new transactions. Only SMS newer than
    // the last balance update count, so history can never double-count.
    final fresh = await (db.select(db.accounts)..where((a) => a.id.equals(account.id))).getSingleOrNull();
    if (fresh != null && timestamp.isAfter(fresh.updatedAt)) {
      final newBalance = parsed.balanceAfterPaise ??
          (debit ? fresh.balance - parsed.amountPaise : fresh.balance + parsed.amountPaise);
      await (db.update(db.accounts)..where((a) => a.id.equals(account.id))).write(
        AccountsCompanion(balance: drift.Value(newBalance), updatedAt: drift.Value(timestamp)),
      );
    }
    return IngestOutcome.imported;
  }

  static bool _bankMatches(String bankName, String hay) {
    final name = bankName.toLowerCase();
    for (final e in _bankTokens.entries) {
      if (name.contains(e.key)) return e.value.any(hay.contains);
    }
    return false;
  }
}