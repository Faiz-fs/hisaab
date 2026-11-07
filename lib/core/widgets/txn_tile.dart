import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_text_styles.dart';
import 'money_text.dart';

/// Transaction row, shown as its own card.
///
/// [icon] circle | merchant + note + "time . category" | amount + mode chip
class TxnTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String merchant;
  final String note;
  final String meta;
  final double amount; // rupees
  final String? modeLabel;
  final bool isDebit;
  final VoidCallback? onTap;

  const TxnTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.merchant,
    required this.meta,
    required this.amount,
    this.note = '',
    this.modeLabel,
    this.isDebit = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final amountStyle = AppTextStyles.headlineMedium.copyWith(
      fontSize: 20,
      color: isDebit ? AppColors.textPrimary : AppColors.mint,
    );

    return Material(
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card - 4),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.nested,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      merchant,
                      style: AppTextStyles.titleMedium.copyWith(fontSize: 17),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (note.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        note,
                        style: AppTextStyles.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 3),
                    Text(
                      meta,
                      style: AppTextStyles.labelSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MoneyText(
                    amount,
                    prefix: isDebit ? '- ' : '+ ',
                    style: amountStyle,
                  ),
                  if (modeLabel != null) ...[
                    const SizedBox(height: 4),
                    _ModeChip(label: modeLabel!),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  const _ModeChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.nested,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(label, style: AppTextStyles.labelSmall.copyWith(fontSize: 10)),
    );
  }
}
