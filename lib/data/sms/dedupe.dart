import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Computes a deterministic deduplication ID for a parsed SMS transaction.
///
/// The hash is derived from: bank + last4 + refNo + amount + timestamp (day).
/// Raw SMS body is NEVER included to prevent sensitive data leakage.
String computeDedupeId({
  required String bank,
  required String last4,
  required String? refNo,
  required int amountPaise,
  required DateTime at,
}) {
  // Truncate timestamp to minute precision to absorb minor delivery jitter.
  final ts = DateTime(
    at.year,
    at.month,
    at.day,
    at.hour,
    at.minute,
  ).millisecondsSinceEpoch;

  final raw = '$bank|$last4|${refNo ?? ""}|$amountPaise|$ts';
  final bytes = utf8.encode(raw);
  return sha256.convert(bytes).toString();
}
