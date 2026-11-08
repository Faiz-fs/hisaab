import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide Column;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../db/app_database.dart';

enum ExportRange { thisMonth, last30, all, custom }

enum ExportType { all, spend, income }

/// Sentinel for the "Uncategorised" category filter.
const String kUncategorisedFilter = '__none__';

class ExportFilter {
  final ExportRange range;
  final DateTime? customStart; // inclusive, date only
  final DateTime? customEnd; // inclusive, date only
  final ExportType type;
  final String? accountId; // null = all accounts
  final String? category; // null = all, kUncategorisedFilter = none

  const ExportFilter({
    required this.range,
    this.customStart,
    this.customEnd,
    this.type = ExportType.all,
    this.accountId,
    this.category,
  });

  /// [start, endExclusive) in local time; null = unbounded.
  (DateTime?, DateTime?) get bounds {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    switch (range) {
      case ExportRange.thisMonth:
        return (DateTime(now.year, now.month, 1), tomorrow);
      case ExportRange.last30:
        return (DateTime(today.year, today.month, today.day - 29), tomorrow);
      case ExportRange.all:
        return (null, null);
      case ExportRange.custom:
        final s = customStart;
        final e = customEnd;
        return (
          s == null ? null : DateTime(s.year, s.month, s.day),
          e == null ? null : DateTime(e.year, e.month, e.day + 1),
        );
    }
  }
}

/// Builds and writes the transaction CSV (UTF-8 with BOM, opens cleanly in Excel).
class CsvExportService {
  final AppDatabase db;
  const CsvExportService(this.db);

  static const header = [
    'Date',
    'Time',
    'Account',
    'Bank',
    'Direction',
    'Kind',
    'Amount',
    'Payee',
    'Category',
    'Mode',
    'Ref',
    'Balance after',
  ];

  /// Transactions matching [f], oldest first.
  Future<List<Txn>> fetch(ExportFilter f) async {
    final (start, end) = f.bounds;
    final q = db.select(db.txns);
    if (start != null) q.where((t) => t.at.isBiggerOrEqualValue(start));
    if (end != null) q.where((t) => t.at.isSmallerThanValue(end));
    q.orderBy([(t) => OrderingTerm.asc(t.at)]);
    final rows = await q.get();

    return rows.where((t) {
      if (f.type == ExportType.spend && t.direction != 'debit') return false;
      if (f.type == ExportType.income && t.direction != 'credit') return false;
      if (f.accountId != null && t.accountId != f.accountId) return false;
      if (f.category == kUncategorisedFilter) {
        if (t.category != null) return false;
      } else if (f.category != null && t.category != f.category) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Paise -> "1234.50" using integer maths (no float rounding).
  static String rupees(int paise) {
    final neg = paise < 0;
    final a = paise.abs();
    final s = '${a ~/ 100}.${(a % 100).toString().padLeft(2, '0')}';
    return neg ? '-$s' : s;
  }

  /// Quotes a field when it contains a comma, quote or line break.
  static String csvField(String v) {
    if (v.contains(',') ||
        v.contains('"') ||
        v.contains('\n') ||
        v.contains('\r')) {
      return '"${v.replaceAll('"', '""')}"';
    }
    return v;
  }

  /// Text that starts with = + - @ can run as a formula in Excel/Sheets.
  /// Payee names come from SMS, so neutralise them with a leading apostrophe.
  static String _safeText(String? v) {
    if (v == null || v.isEmpty) return '';
    final first = v[0];
    if (first == '=' ||
        first == '+' ||
        first == '-' ||
        first == '@' ||
        first == '\t' ||
        first == '\r') {
      return "'$v";
    }
    return v;
  }

  static String buildCsv(List<Txn> rows, Map<String, Account> accounts) {
    final date = DateFormat('yyyy-MM-dd');
    final time = DateFormat('HH:mm:ss');
    final out = StringBuffer()
      ..write(header.map(csvField).join(','))
      ..write('\r\n');
    for (final t in rows) {
      final a = accounts[t.accountId];
      final fields = <String>[
        date.format(t.at),
        time.format(t.at),
        a == null ? '' : 'XX${a.last4}',
        a?.bankName ?? '',
        t.direction,
        t.kind,
        rupees(t.amount),
        _safeText(t.payee),
        _safeText(t.category),
        t.mode,
        t.refNo ?? '',
        t.balanceAfter == null ? '' : rupees(t.balanceAfter!),
      ];
      out
        ..write(fields.map(csvField).join(','))
        ..write('\r\n');
    }
    return out.toString();
  }

  /// Writes the CSV to <app documents>/exports and returns the file.
  /// Older exports are removed so the folder never grows.
  Future<File> writeCsv(List<Txn> rows) async {
    final accounts = {
      for (final a in await db.accountsDao.getAllAccounts()) a.id: a,
    };
    final csv = buildCsv(rows, accounts);

    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory(p.join(dir.path, 'exports'));
    await folder.create(recursive: true);
    await for (final e in folder.list()) {
      if (e is File && e.path.toLowerCase().endsWith('.csv')) {
        try {
          await e.delete();
        } catch (_) {}
      }
    }

    final name =
        'hisaab_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.csv';
    final file = File(p.join(folder.path, name));
    // UTF-8 BOM so Excel reads Hindi/Indian names correctly.
    await file.writeAsBytes([
      0xEF,
      0xBB,
      0xBF,
      ...utf8.encode(csv),
    ], flush: true);
    return file;
  }
}
