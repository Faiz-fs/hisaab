import 'enums.dart';

/// User settings domain model (backed by shared_preferences).
class Settings {
  /// Monthly take-home income in paise.
  final int monthlyIncomePaise;
  final BudgetMode budgetMode;
  final RoastLevel roastLevel;
  final bool smsEnabled;
  final bool onboardingDone;

  /// Local profile information. No online account required.
  final String displayName;
  final String email;

  const Settings({
    this.monthlyIncomePaise = 0,
    this.budgetMode = BudgetMode.daily,
    this.roastLevel = RoastLevel.honest,
    this.smsEnabled = false,
    this.onboardingDone = false,
    this.displayName = '',
    this.email = '',
  });

  double get monthlyIncomeRupees => monthlyIncomePaise / 100;

  Settings copyWith({
    int? monthlyIncomePaise,
    BudgetMode? budgetMode,
    RoastLevel? roastLevel,
    bool? smsEnabled,
    bool? onboardingDone,
    String? displayName,
    String? email,
  }) {
    return Settings(
      monthlyIncomePaise: monthlyIncomePaise ?? this.monthlyIncomePaise,
      budgetMode: budgetMode ?? this.budgetMode,
      roastLevel: roastLevel ?? this.roastLevel,
      smsEnabled: smsEnabled ?? this.smsEnabled,
      onboardingDone: onboardingDone ?? this.onboardingDone,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
    );
  }
}
