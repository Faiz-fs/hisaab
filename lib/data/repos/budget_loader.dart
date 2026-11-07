import '../../domain/budget/daily_budget.dart';
import '../../domain/models/settings.dart';
import '../db/app_database.dart';

/// Builds today's [DailyBudget] from settings plus real spending in the DB.
/// Shared by the Today screen, verdict provider and background notifications.
Future<DailyBudget> loadDailyBudget(
  AppDatabase db,
  Settings settings,
  DateTime now,
) async {
  final cycle = BudgetCycle.forDate(now, settings.payDay);
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = DateTime(now.year, now.month, now.day + 1);
  final spentToday = await db.txnsDao.spendBetween(today, tomorrow);
  final spentCycle = await db.txnsDao.spendBetween(
    cycle.start,
    cycle.endExclusive,
  );
  return DailyBudget(
    monthlyIncomePaise: settings.monthlyIncomePaise,
    commitmentsPaise: settings.monthlyCommitmentsPaise,
    spentTodayPaise: spentToday,
    spentInCyclePaise: spentCycle,
    payDay: settings.payDay,
    date: now,
  );
}
