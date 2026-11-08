import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Determines which transaction flow is displayed.
enum MoneyFlowType { spend, income }

/// Reusable Spend / Income selector.
///
/// The parent screen owns the selected value and
/// handles switching between transaction datasets.
class MoneyFlowToggle extends StatelessWidget {
  final MoneyFlowType selected;
  final ValueChanged<MoneyFlowType> onChanged;

  const MoneyFlowToggle({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _option(
            type: MoneyFlowType.spend,
            label: 'SPENDING',
            icon: Icons.north_east_rounded,
            activeColor: AppColors.primary,
          ),
          const SizedBox(width: 5),
          _option(
            type: MoneyFlowType.income,
            label: 'INCOME',
            icon: Icons.south_west_rounded,
            activeColor: AppColors.mint,
          ),
        ],
      ),
    );
  }

  Widget _option({
    required MoneyFlowType type,
    required String label,
    required IconData icon,
    required Color activeColor,
  }) {
    final isSelected = selected == type;

    return Expanded(
      child: InkWell(
        onTap: () {
          if (!isSelected) {
            onChanged(type);
          }
        },
        borderRadius: BorderRadius.circular(11),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withValues(alpha: 0.13)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: isSelected
                  ? activeColor.withValues(alpha: 0.45)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? activeColor : AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                    color: isSelected ? activeColor : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
