import 'package:flutter/services.dart';

/// Bridges the native Android [SmsReceiver] to Flutter via platform channels.
///
/// Channel: "hisaab/sms"
/// EventChannel streams incoming SMS payloads as `Map<String, dynamic>`:
///   { "sender": String, "body": String, "timestamp": int (ms since epoch) }
class SmsChannel {
  static const String _channelName = 'hisaab/sms';

  static const EventChannel _eventChannel = EventChannel(_channelName);

  /// Stream of raw SMS events from the native receiver.
  static Stream<Map<String, dynamic>> get smsStream {
    return _eventChannel.receiveBroadcastStream().map(
          (event) => Map<String, dynamic>.from(event as Map),
        );
  }
}
