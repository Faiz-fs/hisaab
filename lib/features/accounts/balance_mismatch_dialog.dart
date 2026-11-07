import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/inr_format.dart';
import '../../core/theme/app_colors.dart';

/// Dialog shown when the balance in a bank SMS differs from the stored balance.
/// Pops `true` to use the SMS balance, `false` to keep the stored one.
class BalanceMismatchDialog extends ConsumerWidget {
  final String bankName;
  final double smsBalance;
  final double storedBalance;
  const BalanceMismatchDialog({
    super.key,
    required this.bankName,
    required this.smsBalance,
    required this.storedBalance,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      title: Text('$bankName balance differs'),
      content: Text(
        'Latest bank SMS shows ${inr(smsBalance)} but Hisaab has ${inr(storedBalance)}.\n\n'
        'Update to the bank balance?',
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep mine')),
        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Use bank balance')),
      ],
    );
  }
}
