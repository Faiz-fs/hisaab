// Small time helpers. Written by hand (not intl) so the output is always
// "5:58 PM" with a normal space on every device.

/// "5:58 PM"
String formatClock(DateTime t) {
  final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final m = t.minute.toString().padLeft(2, '0');
  final suffix = t.hour >= 12 ? 'PM' : 'AM';
  return '$h:$m $suffix';
}

/// "Good morning" / "Good afternoon" / "Good evening"
String greetingFor(DateTime t) {
  if (t.hour < 12) return 'Good morning';
  if (t.hour < 17) return 'Good afternoon';
  return 'Good evening';
}
