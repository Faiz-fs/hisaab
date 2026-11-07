import 'enums.dart';

/// Transaction domain model (maps from Drift [Txn] row).
class TxnModel {
  final String id;
  final String accountId;

  /// Amount in paise.
  final int amountPaise;
  final Direction direction;
  final PayMode mode;
  final String? payee;
  final String? category;
  final String? refNo;
  final int? balanceAfterPaise;
  final DateTime at;
  final TxnKind kind;

  const TxnModel({
    required this.id,
    required this.accountId,
    required this.amountPaise,
    required this.direction,
    required this.mode,
    this.payee,
    this.category,
    this.refNo,
    this.balanceAfterPaise,
    required this.at,
    this.kind = TxnKind.spend,
  });

  double get amountRupees => amountPaise / 100;
  bool get isDebit => direction == Direction.debit;

  /// A debit that counts toward the daily limit.
  bool get isSpend => isDebit && kind == TxnKind.spend;
}
