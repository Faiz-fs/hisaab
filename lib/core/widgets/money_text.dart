import 'package:flutter/material.dart';

import '../format/inr_format.dart';

/// Currency text with the ₹ glyph at 85% of the font size (per DESIGN.md).
///
/// [amount] is in rupees. [prefix] is placed before the symbol, e.g. "-".
class MoneyText extends StatelessWidget {
  final double amount;
  final TextStyle style;
  final String prefix;
  final bool compact;
  final TextAlign? textAlign;

  const MoneyText(
    this.amount, {
    super.key,
    required this.style,
    this.prefix = '',
    this.compact = false,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final formatted = compact ? inrCompact(amount) : inr(amount);
    final hasSymbol = formatted.startsWith('₹');
    final number = hasSymbol ? formatted.substring(1) : formatted;
    final base = style.fontSize ?? 14;

    return Text.rich(
      TextSpan(
        style: style,
        children: [
          if (prefix.isNotEmpty) TextSpan(text: prefix),
          if (hasSymbol)
            TextSpan(text: '₹', style: style.copyWith(fontSize: base * 0.85)),
          TextSpan(text: number),
        ],
      ),
      textAlign: textAlign,
    );
  }
}
