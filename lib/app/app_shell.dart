import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/enums.dart';
import '../providers/settings_provider.dart';

import 'package:go_router/go_router.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// Shell scaffold with a floating bottom navigation bar.
/// Tabs: Today | Money Map | Calendar | Profile
class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  static const _tabs = [
    (icon: Icons.today_outlined, label: 'Today', path: '/today'),
    (icon: Icons.track_changes, label: 'Money Map', path: '/money-map'),
    (icon: Icons.calendar_month_outlined, label: 'Calendar', path: '/calendar'),
    (icon: Icons.person_outline, label: 'Profile', path: '/profile'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    for (int i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWeekly =
        ref.watch(settingsProvider).asData?.value.budgetMode ==
        BudgetMode.weekly;
    final idx = _currentIndex(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: child,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Material(
            color: AppColors.card,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: const BorderSide(color: AppColors.border),
            ),
            child: SizedBox(
              height: 72,
              child: Row(
                children: [
                  for (int i = 0; i < _tabs.length; i++)
                    Expanded(
                      child: InkWell(
                        onTap: () => context.go(_tabs[i].path),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              i == 0 && isWeekly
                                  ? Icons.date_range_outlined
                                  : _tabs[i].icon,
                              size: 24,
                              color: i == idx
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              i == 0 && isWeekly ? 'Week' : _tabs[i].label,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: i == idx
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
