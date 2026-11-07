import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/settings.dart';
import '../../domain/models/enums.dart';

/// Settings repository backed by [SharedPreferences].
///
/// Keys:
///   hisaab_income_paise       → int
///   hisaab_budget_mode        → String (enum name)
///   hisaab_roast_level        → String (enum name)
///   hisaab_sms_enabled        → bool
///   hisaab_onboarding_done    → bool
///   hisaab_display_name       → String
///   hisaab_email              → String
class SettingsRepo {
  static const _kIncome = 'hisaab_income_paise';
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

    return Settings(
      monthlyIncomePaise: prefs.getInt(_kIncome) ?? 0,
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
    await prefs.setString(_kBudgetMode, s.budgetMode.name);
    await prefs.setString(_kRoastLevel, s.roastLevel.name);
    await prefs.setBool(_kSmsEnabled, s.smsEnabled);
    await prefs.setBool(_kOnboardingDone, s.onboardingDone);
    await prefs.setString(_kDisplayName, s.displayName);
    await prefs.setString(_kEmail, s.email);
  }
}
