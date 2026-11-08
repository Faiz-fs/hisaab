import 'package:flutter/material.dart';

import '../../core/format/inr_format.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/hisaab_card.dart';

/// Shows incoming money, outgoing spending,
/// and net cash flow for a selected period.
///
/// All amounts are supplied in paise.
///
/// This widget is display-only. Credits do not increase
/// the daily spending quota or change the budget ring.
///
/// The title can be customized for different screens.
class CreditSummaryCard extends StatelessWidget {
  final int receivedPaise;
  final int spentPaise;
  final String title;

  const CreditSummaryCard({
    super.key,
    required this.receivedPaise,
    required this.spentPaise,
    this.title = "TODAY'S CASH FLOW",
  });

  @override
  Widget build(BuildContext context) {
    final received = receivedPaise / 100;
    final spent = spentPaise / 100;
    final net = received - spent;

    final netPositive = net >= 0;
    final netColor = netPositive ? AppColors.mint : AppColors.red;

    return HisaabCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                color: AppColors.mint,
                size: 21,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _AmountColumn(
                  label: 'RECEIVED TODAY',
                  amount: received,
                  icon: Icons.south_west_rounded,
                  color: AppColors.mint,
                  prefix: '+',
                ),
              ),
              Container(height: 56, width: 1, color: AppColors.border),
              const SizedBox(width: 16),
              Expanded(
                child: _AmountColumn(
                  label: 'SPENT TODAY',
                  amount: spent,
                  icon: Icons.north_east_rounded,
                  color: AppColors.red,
                  prefix: '-',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'NET CASH FLOW',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Text(
                '${netPositive ? '+' : '-'}${inr(net.abs())}',
                style: AppTextStyles.titleLarge.copyWith(
                  color: netColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            'Only everyday spending counts towards '
            'your daily budget. Income is tracked separately.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountColumn extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;
  final String prefix;

  const _AmountColumn({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    required this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 17),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          '$prefix${inr(amount)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.titleLarge.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
      ],
    );
  }
}
