import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import '../db/app_database.dart';
import '../repos/rule_service.dart';
import 'sms_ingest_service.dart';

class SmsImportResult {
  final int scanned;
  final int imported;

  /// Existing rows that got a payee/category filled in.
  final int updated;
  final Map<IngestOutcome, int> outcomes;

  /// Newest balance seen in SMS per account id.
  final Map<String, ({DateTime at, int balancePaise})> balances;
  const SmsImportResult(
    this.scanned,
    this.imported, [
    this.outcomes = const {},
    this.balances = const {},
  ]) : updated = 0;
  const SmsImportResult.withUpdates(
    this.scanned,
    this.imported,
    this.updated,
    this.outcomes, [
    this.balances = const {},
  ]);

  /// Short human-readable reason breakdown for skipped messages.
  String get skippedSummary {
    final parts = <String>[];
    void add(IngestOutcome o, String label) {
      final n = outcomes[o] ?? 0;
      if (n > 0) parts.add('$n $label');
    }

    add(IngestOutcome.updated, 'updated with merchant/category');
    add(IngestOutcome.noAccountMatch, 'no matching account');
    add(IngestOutcome.unparsed, 'unparsed');
    add(IngestOutcome.ambiguousAccount, 'ambiguous account');
    add(IngestOutcome.duplicate, 'already imported');
    return parts.join(', ');
  }
}

/// Reads the last 15 days on demand, on launch, and when the app resumes.
/// Android-side implementation is required in MainActivity.kt.
class SmsBackfillService {
  final AppDatabase db;
  const SmsBackfillService(this.db);
  static const _channel = MethodChannel('hisaab/sms_backfill');

  Future<SmsImportResult> run({int days = 15}) async {
    try {
      await RuleService(db).categorizeUncategorized();
    } catch (_) {}
    if (!(await Permission.sms.status).isGranted) {
      return const SmsImportResult(0, 0);
    }
    final messages = List<dynamic>.of(
      await _channel.invokeListMethod<dynamic>('readRecentSms', {
            'days': days,
          }) ??
          <dynamic>[],
    );
    // Oldest first, so balance changes are applied in the order they happened.
    messages.sort(
      (a, b) => ((a as Map)['timestamp'] as num).compareTo(
        (b as Map)['timestamp'] as num,
      ),
    );
    final balances = <String, ({DateTime at, int balancePaise})>{};
    final ingest = SmsIngestService(
      db,
      onBalance: (id, at, bal) {
        final cur = balances[id];
        if (cur == null || at.isAfter(cur.at))
          balances[id] = (at: at, balancePaise: bal);
      },
    );
    final outcomes = <IngestOutcome, int>{};
    var imported = 0;
    for (final raw in messages) {
      try {
        final sms = Map<String, dynamic>.from(raw as Map);
        final outcome = await ingest.ingestDetailed(
          sender: (sms['sender'] ?? '').toString(),
          body: (sms['body'] ?? '').toString(),
          timestamp: DateTime.fromMillisecondsSinceEpoch(
            (sms['timestamp'] as num).toInt(),
          ),
        );
        outcomes[outcome] = (outcomes[outcome] ?? 0) + 1;
        if (outcome == IngestOutcome.imported ||
            outcome == IngestOutcome.updated)
          imported++;
      } catch (_) {
        // Malformed SMS must not abort the rest of the import.
      }
    }
    return SmsImportResult.withUpdates(
      messages.length,
      imported,
      outcomes[IngestOutcome.updated] ?? 0,
      outcomes,
      balances,
    );
  }
}
