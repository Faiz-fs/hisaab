import 'package:workmanager/workmanager.dart';

import '../../core/format/inr_format.dart';
import '../../data/db/app_database.dart';
import '../../data/repos/settings_repo.dart';
import '../../data/repos/txn_repo.dart';
import '../../domain/budget/daily_budget.dart';
import '../../domain/budget/roast_copy.dart';
import '../../domain/budget/verdict_engine.dart';
import 'notification_service.dart';

/// Workmanager background task registration.
///
/// Jobs:
///   - morningReminder : fires at 08:00, shows daily budget prompt
///   - nightVerdict    : fires at 23:45, shows spend summary
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    AppDatabase? db;
    try {
      await NotificationService.instance.init();
      db = AppDatabase();
      final settings = await SettingsRepo().load();
      final repo = DriftTxnRepo(db);
      final now = DateTime.now();
      final budget = DailyBudget(
        monthlyIncomePaise: settings.monthlyIncomePaise,
        spentTodayPaise: 0,
        date: now,
      ).dailyBudgetPaise;

      switch (taskName) {
        case BackgroundTasks.morningTaskName:
          final yesterday = DateTime(now.year, now.month, now.day - 1);
          final spentYesterday = await repo.totalDebitForDay(yesterday);
          await NotificationService.instance.showMorningReminder(
            budget > 0
                ? "Today's budget is ${inr(budget / 100)}. Yesterday you spent ${inr(spentYesterday / 100)}."
                : "Set your monthly income in Hisaab to get a daily budget.",
          );
        case BackgroundTasks.nightTaskName:
          final txns = await repo.getForDay(now);
          final v = const VerdictEngine().buildVerdict(date: now, txns: txns, dailyBudgetPaise: budget);
          final top = v.topCulprits.isEmpty ? 'spending' : v.topCulprits.first;
          final roast = RoastCopy.generate(level: settings.roastLevel, category: top, overBudget: v.overBudget);
          await NotificationService.instance.showNightVerdict(
            '${v.rating}/10 · spent ${inr(v.totalSpentRupees)}. $roast',
          );
      }
      return true;
    } catch (_) {
      return false;
    } finally {
      await db?.close();
    }
  });
}

/// Registers the Workmanager background tasks.
abstract final class BackgroundTasks {
  static const morningTaskName = 'hisaab_morning_reminder';
  static const nightTaskName = 'hisaab_night_verdict';

  /// Call once in [main] after [WidgetsFlutterBinding.ensureInitialized].
  static Future<void> init() async {
    // isInDebugMode removed — deprecated in workmanager 0.10.x
    await Workmanager().initialize(callbackDispatcher);

    // Morning job — daily at ~08:00
    await Workmanager().registerPeriodicTask(
      morningTaskName,
      morningTaskName,
      frequency: const Duration(hours: 24),
      initialDelay: _delayUntil(8, 0),
      // No networkType constraint needed for local notifications
    );

    // Night job — daily at ~23:45
    await Workmanager().registerPeriodicTask(
      nightTaskName,
      nightTaskName,
      frequency: const Duration(hours: 24),
      initialDelay: _delayUntil(23, 45),
    );
  }

  /// Computes delay until the next occurrence of [hour]:[minute].
  static Duration _delayUntil(int hour, int minute) {
    final now = DateTime.now();
    var target = DateTime(now.year, now.month, now.day, hour, minute);
    if (target.isBefore(now)) target = target.add(const Duration(days: 1));
    return target.difference(now);
  }
}
