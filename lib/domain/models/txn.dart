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
  });

  double get amountRupees => amountPaise / 100;
  bool get isDebit => direction == Direction.debit;
}
