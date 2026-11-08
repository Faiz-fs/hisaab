import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import '../domain/models/enums.dart';
import '../providers/settings_provider.dart';

import '../data/repos/settings_repo.dart';

import '../features/onboarding/onboarding_screen.dart';
import '../features/onboarding/income_screen.dart';
import '../features/onboarding/add_bank_screen.dart';
import '../features/onboarding/sms_permission_screen.dart';
import '../features/onboarding/setup_done_screen.dart';
import '../features/today/today_screen.dart';
import '../features/today/week_screen.dart';
import '../features/money_map/money_map_screen.dart';
import '../features/calendar/calendar_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/accounts/accounts_screen.dart';
import '../features/verdict/verdict_screen.dart';
import '../features/onboarding/personal_details_screen.dart';
import '../features/upi/upi_tracker_screen.dart';
import '../features/export/export_screen.dart';
import '../features/feedback/feedback_screen.dart';
import 'app_shell.dart';

/// First launch opens onboarding; completed setup opens Today.
final GoRouter appRouter = GoRouter(
  initialLocation: '/today',
  redirect: (context, state) async {
    final done = (await SettingsRepo().load()).onboardingDone;
    final isOnboarding = state.matchedLocation.startsWith('/onboarding');
    if (!done && !isOnboarding) return '/onboarding';
    if (done && isOnboarding) return '/today';
    return null;
  },
  routes: [
    // ── Onboarding flow ──────────────────────────────────────────────────
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
      routes: [
        GoRoute(
          path: 'income',
          builder: (context, state) => const IncomeScreen(),
        ),
        GoRoute(
          path: 'add-bank',
          builder: (context, state) => const AddBankScreen(),
        ),
        GoRoute(
          path: 'sms-permission',
          builder: (context, state) => const SmsPermissionScreen(),
        ),
        GoRoute(
          path: 'personal-details',
          builder: (context, state) => const PersonalDetailsScreen(),
        ),
        GoRoute(
          path: 'done',
          builder: (context, state) => const SetupDoneScreen(),
        ),
      ],
    ),

    GoRoute(
      path: '/upi',
      builder: (context, state) => const UpiTrackerScreen(),
    ),
    GoRoute(path: '/export', builder: (context, state) => const ExportScreen()),
    GoRoute(
      path: '/feedback',
      builder: (context, state) => const FeedbackScreen(),
    ),

    // ── Main shell with bottom nav ────────────────────────────────────────
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/today',
          builder: (context, state) => const _CadenceHome(),
        ),
        GoRoute(
          path: '/money-map',
          builder: (context, state) => const MoneyMapScreen(),
        ),
        GoRoute(
          path: '/calendar',
          builder: (context, state) => const CalendarScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/accounts',
          builder: (context, state) => const AccountsScreen(),
        ),
        GoRoute(
          path: '/verdict',
          builder: (context, state) => const VerdictScreen(),
        ),
      ],
    ),
  ],
);

/// Keep /today stable for existing navigation while switching the dashboard.
class _CadenceHome extends ConsumerWidget {
  const _CadenceHome();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return settings.when(
      data: (value) => value.budgetMode == BudgetMode.weekly
          ? const WeekScreen()
          : const TodayScreen(),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('Unable to load budget settings: $error')),
    );
  }
}
