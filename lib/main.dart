import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'features/notifications/notification_service.dart';
import 'features/notifications/background_tasks.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Notification channels.
  await NotificationService.instance.init();

  // Morning (08:00) and night-verdict (23:45) background jobs.
  await BackgroundTasks.init();

  runApp(const ProviderScope(child: HisaabApp()));
}
