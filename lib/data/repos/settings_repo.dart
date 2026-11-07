import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/settings.dart';
import '../../domain/models/enums.dart';

/// Settings repository backed by [SharedPreferences].
class SettingsRepo {
  static const _kIncome = 'hisaab_income_paise';
  static const _kCommitments = 'hisaab_commitments_paise';
  static const _kPayDay = 'hisaab_pay_day';
  static const _kDismissedSuggestion = 'hisaab_dismissed_income_suggestion';
  static const _kBudgetMode = 'hisaab_budget_mode';
  static const _kRoastLevel = 'hisaab_roast_level';
  static const _kSmsEnabled = 'hisaab_sms_enabled';
  static const _kOnboardingDone = 'hisaab_onboarding_done';
  static const _kDisplayName = 'hisaab_display_name';
  static const _kEmail = 'hisaab_email';

  Future<Settings> load() async {
    final prefs = await SharedPreferences.getInstance();

    BudgetMode budgetMode;
    RoastLevel roastLevel;

    try {
      budgetMode = BudgetMode.values.byName(
        prefs.getString(_kBudgetMode) ?? BudgetMode.daily.name,
      );
    } catch (_) {
      budgetMode = BudgetMode.daily;
    }

    try {
      roastLevel = RoastLevel.values.byName(
        prefs.getString(_kRoastLevel) ?? RoastLevel.honest.name,
      );
    } catch (_) {
      roastLevel = RoastLevel.honest;
    }

    var payDay = prefs.getInt(_kPayDay) ?? 1;
    if (payDay < 1) payDay = 1;
    if (payDay > 28) payDay = 28;

    return Settings(
      monthlyIncomePaise: prefs.getInt(_kIncome) ?? 0,
      monthlyCommitmentsPaise: prefs.getInt(_kCommitments) ?? 0,
      payDay: payDay,
      dismissedIncomeSuggestionId: prefs.getString(_kDismissedSuggestion) ?? '',
      budgetMode: budgetMode,
      roastLevel: roastLevel,
      smsEnabled: prefs.getBool(_kSmsEnabled) ?? false,
      onboardingDone: prefs.getBool(_kOnboardingDone) ?? false,
      displayName: prefs.getString(_kDisplayName) ?? '',
      email: prefs.getString(_kEmail) ?? '',
    );
  }

  Future<void> save(Settings s) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_kIncome, s.monthlyIncomePaise);
    await prefs.setInt(_kCommitments, s.monthlyCommitmentsPaise);
    await prefs.setInt(_kPayDay, s.payDay);
    await prefs.setString(_kDismissedSuggestion, s.dismissedIncomeSuggestionId);
    await prefs.setString(_kBudgetMode, s.budgetMode.name);
    await prefs.setString(_kRoastLevel, s.roastLevel.name);
    await prefs.setBool(_kSmsEnabled, s.smsEnabled);
    await prefs.setBool(_kOnboardingDone, s.onboardingDone);
    await prefs.setString(_kDisplayName, s.displayName);
    await prefs.setString(_kEmail, s.email);
  }
}
