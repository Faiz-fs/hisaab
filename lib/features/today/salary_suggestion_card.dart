import 'package:flutter/material.dart';

import '../../core/format/inr_format.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/hisaab_card.dart';

/// Displays a possible salary credit and asks the user
/// whether to update their monthly income.
///
/// The parent screen handles saving and dismissing.
/// This widget never changes settings by itself.
class SalarySuggestionCard extends StatelessWidget {
  final int detectedAmountPaise;
  final int currentIncomePaise;
  final bool isSaving;
  final VoidCallback onAccept;
  final VoidCallback onDismiss;

  const SalarySuggestionCard({
    super.key,
    required this.detectedAmountPaise,
    required this.currentIncomePaise,
    required this.onAccept,
    required this.onDismiss,
    this.isSaving = false,
  });

  @override
  Widget build(BuildContext context) {
    final detected = detectedAmountPaise / 100;
    final current = currentIncomePaise / 100;

    return HisaabCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'POSSIBLE SALARY DETECTED',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Dismiss suggestion',
                onPressed: isSaving ? null : onDismiss,
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${inr(detected)} received',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.mint,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This looks like your salary. Your current '
            'monthly income is ${inr(current)}.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Update your monthly income to '
            '${inr(detected)}? Your commitments '
            'will remain unchanged.',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isSaving ? null : onDismiss,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Not now'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: isSaving ? null : onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onPrimary,
                          ),
                        )
                      : const Text('Update income'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
