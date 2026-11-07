import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import 'router.dart';
import '../data/sms/sms_tracking_controller.dart';

/// Root application widget.
/// Wires MaterialApp.router with [AppTheme] and [appRouter].
class HisaabApp extends ConsumerWidget {
  const HisaabApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SmsTrackingController(
      child: MaterialApp.router(
        title: 'Hisaab',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.dark,
        routerConfig: appRouter,
      ),
    );
  }
}
