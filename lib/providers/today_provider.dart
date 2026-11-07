import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/budget/daily_budget.dart';
import '../domain/models/daily_verdict.dart';
import 'repo_providers.dart';
import 'db_provider.dart';
import 'verdict_provider.dart';

/// Provider for today's [DailyBudget] snapshot.
final todayBudgetProvider = FutureProvider<DailyBudget>((ref) async {
  final settings = await ref.watch(settingsProvider.future);
  final spent = await ref.watch(dbProvider).txnsDao.totalDebitForDay(DateTime.now());
  return DailyBudget(
    monthlyIncomePaise: settings.monthlyIncomePaise,
    spentTodayPaise: spent,
    date: DateTime.now(),
  );
});

/// Provider for today's [DailyVerdictModel] (computed from local transactions).
final todayVerdictProvider = FutureProvider<DailyVerdictModel?>((ref) async {
  final view = await ref.watch(todayVerdictViewProvider.future);
  return view.verdict;
});
