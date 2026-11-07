import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../providers/db_provider.dart';
import '../../providers/repo_providers.dart';
import '../../features/today/today_data.dart';
import '../../providers/today_provider.dart';
import 'sms_backfill_service.dart';
import 'sms_channel.dart';
import 'sms_ingest_service.dart';

/// Foreground live listener plus catch-up scan after app resumes.
class SmsTrackingController extends ConsumerStatefulWidget {
  final Widget child;
  const SmsTrackingController({super.key, required this.child});
  @override
  ConsumerState<SmsTrackingController> createState() => _SmsTrackingControllerState();
}

class _SmsTrackingControllerState extends ConsumerState<SmsTrackingController> with WidgetsBindingObserver {
  StreamSubscription<Map<String, dynamic>>? _subscription;
  bool _busy = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }
  Future<void> _start() async {
    if (!mounted || _busy) return;
    _busy = true;
    try {
      final settings = await ref.read(settingsRepoProvider).load();
      if (!settings.smsEnabled || !(await Permission.sms.status).isGranted) return;
      _subscription ??= SmsChannel.smsStream.listen((sms) async {
        try {
          final added = await SmsIngestService(ref.read(dbProvider)).ingest(
            sender: sms['sender'] as String,
            body: sms['body'] as String,
            timestamp: DateTime.fromMillisecondsSinceEpoch((sms['timestamp'] as num).toInt()),
          );
          if (added && mounted) _refresh();
        } catch (_) {}
      }, onError: (Object _) {});
      final result = await SmsBackfillService(ref.read(dbProvider)).run();
      if ((result.imported > 0 || result.updated > 0) && mounted) _refresh();
    } catch (_) {
      // Native SMS bridge may not yet be installed on this Android build.
    } finally {
      _busy = false;
    }
  }
  void _refresh() {
    ref.invalidate(todayBudgetProvider);
    ref.invalidate(todayDataProvider);
    ref.invalidate(accountsProvider);
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _start();
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) => widget.child;
}
