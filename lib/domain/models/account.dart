/// Account domain model (maps from Drift [Account] row).
class AccountModel {
  final String id;
  final String bankName;
  final String last4;

  /// Balance in paise.
  final int balancePaise;
  final DateTime updatedAt;

  const AccountModel({
    required this.id,
    required this.bankName,
    required this.last4,
    required this.balancePaise,
    required this.updatedAt,
  });

  double get balanceRupees => balancePaise / 100;
}
