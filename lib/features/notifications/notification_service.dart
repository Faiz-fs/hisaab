import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Manages three notification channels:
///   - morning  : daily budget reminder at 08:00
///   - instant  : real-time SMS transaction alert
///   - night    : night verdict summary at 23:45
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelMorning = AndroidNotificationChannel(
    'hisaab_morning',
    'Morning Reminders',
    description: 'Daily budget reminder at 08:00',
    importance: Importance.defaultImportance,
  );

  static const _channelInstant = AndroidNotificationChannel(
    'hisaab_instant',
    'Transaction Alerts',
    description: 'Real-time SMS transaction notifications',
    importance: Importance.high,
  );

  static const _channelNight = AndroidNotificationChannel(
    'hisaab_night',
    'Night Verdict',
    description: 'Daily spend verdict summary at 23:45',
    importance: Importance.defaultImportance,
  );

  /// Must be called in [main] before [runApp].
  Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    // v22 uses named parameter `settings:`
    await _plugin.initialize(settings: initSettings);

    // Create notification channels (Android 8+)
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_channelMorning);
    await androidPlugin?.createNotificationChannel(_channelInstant);
    await androidPlugin?.createNotificationChannel(_channelNight);
  }

  /// Shows an instant transaction notification.
  Future<void> showTransactionAlert({
    required int id,
    required String title,
    required String body,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'hisaab_instant',
        'Transaction Alerts',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
    // v22: show() uses named parameters
    await _plugin.show(id: id, title: title, body: body, notificationDetails: details);
  }

  /// Shows morning reminder notification.
  Future<void> showMorningReminder(String body) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'hisaab_morning',
        'Morning Reminders',
      ),
    );
    await _plugin.show(
      id: 1000,
      title: 'Good morning 🌅',
      body: body,
      notificationDetails: details,
    );
  }

  /// Shows night verdict notification.
  Future<void> showNightVerdict(String body) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'hisaab_night',
        'Night Verdict',
      ),
    );
    await _plugin.show(
      id: 1001,
      title: 'Daily Verdict 🧾',
      body: body,
      notificationDetails: details,
    );
  }
}
