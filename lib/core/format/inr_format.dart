import 'package:intl/intl.dart';

/// Formats a [double] amount as Indian Rupee notation.
///
/// [inr] → "₹1,00,000" using en_IN locale.
/// [inrCompact] → "₹18.4k" for values ≥ 1000.
String inr(double amount) {
  final fmt = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );
  return fmt.format(amount);
}

/// Compact rupee display: "₹18.4k", "₹2.3L", "₹1.2Cr".
String inrCompact(double amount) {
  if (amount >= 1e7) {
    return '₹${(amount / 1e7).toStringAsFixed(1)}Cr';
  } else if (amount >= 1e5) {
    return '₹${(amount / 1e5).toStringAsFixed(1)}L';
  } else if (amount >= 1000) {
    return '₹${(amount / 1000).toStringAsFixed(1)}k';
  }
  return inr(amount);
}
