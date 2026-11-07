import '../../domain/models/enums.dart';

/// Value object returned by every [BankParser.parse] call.
///
/// All monetary values are in **paise** (integer) to avoid floating-point drift.
/// Raw SMS body is NEVER stored here.
class ParsedTxn {
  /// Amount in paise (e.g. ₹500 → 50000).
  final int amountPaise;

  /// Debit or credit.
  final Direction direction;

  /// Payment mode (UPI, ATM, Card, etc.).
  final PayMode mode;

  /// Merchant / payee name, if extractable from the SMS.
  final String? payee;

  /// Bank reference number or UPI reference, if present.
  final String? refNo;

  /// Last 4 digits of the account or card.
  final String? last4;

  /// Available balance after transaction, in paise (if present in SMS).
  final int? balanceAfterPaise;

  /// Timestamp of the transaction.
  final DateTime at;

  const ParsedTxn({
    required this.amountPaise,
    required this.direction,
    required this.mode,
    this.payee,
    this.refNo,
    this.last4,
    this.balanceAfterPaise,
    required this.at,
  });

  @override
  String toString() =>
      'ParsedTxn(${direction.name} ₹${amountPaise / 100} via ${mode.name}'
      '${payee != null ? " to $payee" : ""}'
      '${last4 != null ? " [**$last4]" : ""})';
}
