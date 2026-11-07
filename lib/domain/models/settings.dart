import 'enums.dart';

/// User settings domain model (backed by shared_preferences).
class Settings {
  /// Monthly take-home income in paise.
  final int monthlyIncomePaise;

  /// Fixed monthly outgoings (family support, rent, EMI, SIP...) in paise.
  final int monthlyCommitmentsPaise;

  /// Day of month the budget cycle starts (1-28). 1 = calendar month.
  final int payDay;

  /// Id of the credit whose "use as income?" suggestion the user dismissed/accepted.
  final String dismissedIncomeSuggestionId;

  final BudgetMode budgetMode;
  final RoastLevel roastLevel;
  final bool smsEnabled;
  final bool onboardingDone;
  final String displayName;
  final String email;

  const Settings({
    this.monthlyIncomePaise = 0,
    this.monthlyCommitmentsPaise = 0,
    this.payDay = 1,
    this.dismissedIncomeSuggestionId = '',
    this.budgetMode = BudgetMode.daily,
    this.roastLevel = RoastLevel.honest,
    this.smsEnabled = false,
    this.onboardingDone = false,
    this.displayName = '',
    this.email = '',
  });

  double get monthlyIncomeRupees => monthlyIncomePaise / 100;

  /// Income left after commitments (never negative).
  int get flexiblePoolPaise {
    final v = monthlyIncomePaise - monthlyCommitmentsPaise;
    return v < 0 ? 0 : v;
  }

  Settings copyWith({
    int? monthlyIncomePaise,
    int? monthlyCommitmentsPaise,
    int? payDay,
    String? dismissedIncomeSuggestionId,
    BudgetMode? budgetMode,
    RoastLevel? roastLevel,
    bool? smsEnabled,
    bool? onboardingDone,
    String? displayName,
    String? email,
  }) {
    return Settings(
      monthlyIncomePaise: monthlyIncomePaise ?? this.monthlyIncomePaise,
      monthlyCommitmentsPaise:
          monthlyCommitmentsPaise ?? this.monthlyCommitmentsPaise,
      payDay: payDay ?? this.payDay,
      dismissedIncomeSuggestionId:
          dismissedIncomeSuggestionId ?? this.dismissedIncomeSuggestionId,
      budgetMode: budgetMode ?? this.budgetMode,
      roastLevel: roastLevel ?? this.roastLevel,
      smsEnabled: smsEnabled ?? this.smsEnabled,
      onboardingDone: onboardingDone ?? this.onboardingDone,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
    );
  }
}
