import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repos/budget_loader.dart';
import '../domain/budget/roast_copy.dart';
import '../domain/budget/verdict_engine.dart';
import '../domain/models/daily_verdict.dart';
import '../domain/models/enums.dart';
import 'db_provider.dart';
import 'repo_providers.dart';

/// Verdict + roast text for one day.
class VerdictView {
  final DailyVerdictModel verdict;
  final int dailyBudgetPaise;
  final String roast;
  const VerdictView(this.verdict, this.dailyBudgetPaise, this.roast);
}

/// Computes (and stores) today's verdict from local transactions.
final todayVerdictViewProvider = FutureProvider.autoDispose<VerdictView>((
  ref,
) async {
  final settings = await ref.watch(settingsProvider.future);
  final now = DateTime.now();
  final txns = await ref.watch(txnRepoProvider).getForDay(now);
  final budget = (await loadDailyBudget(
    ref.watch(dbProvider),
    settings,
    now,
  )).dailyBudgetPaise;
  final verdict = const VerdictEngine().buildVerdict(
    date: now,
    txns: txns,
    dailyBudgetPaise: budget,
  );
  await ref.read(verdictRepoProvider).upsert(verdict);
  final top = verdict.topCulprits.isEmpty
      ? 'spending'
      : verdict.topCulprits.first;
  return VerdictView(
    verdict,
    budget,
    RoastCopy.generate(
      level: settings.roastLevel,
      category: top,
      overBudget: verdict.overBudget,
    ),
  );
});

final recentVerdictsProvider =
    FutureProvider.autoDispose<List<DailyVerdictModel>>((ref) async {
      ref.watch(dbProvider);
      return ref.watch(verdictRepoProvider).getRecent(limit: 7);
    });

/// Shared by notifications: build the roast level text for a verdict.
RoastLevel roastLevelOrDefault(RoastLevel? l) => l ?? RoastLevel.honest;
