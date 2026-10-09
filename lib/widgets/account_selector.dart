import 'package:flutter/material.dart';

import '../models/financial_account.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'cards/account_badge.dart';

/// Selectable account row used by Transfer (with a dropdown chevron) and
/// Pay (with a check mark when [selected]).
class AccountSelector extends StatelessWidget {
  const AccountSelector({
    super.key,
    required this.account,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.showChevron = false,
  });

  final FinancialAccount account;

  /// Accessible description, e.g. "From account" or "Pay with".
  final String label;
  final VoidCallback onTap;
  final bool selected;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Semantics(
      label: '$label: ${account.provider}',
      selected: selected,
      button: true,
      child: Material(
        color: selected ? const Color(0xFF120B18) : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md - 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radius),
              border: Border.all(
                color: selected ? AppColors.primary.withValues(alpha: 0.7) : AppColors.outline,
              ),
            ),
            child: Row(
              children: [
                AccountBadge(
                  label: account.initial,
                  highlighted: selected || showChevron,
                  color: BankColors.of(account.id),
                ),
                const SizedBox(width: AppSpacing.md - 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(account.provider, style: text.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        'Balance ${formatMoney(account.balance)}',
                        style: text.labelSmall?.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                if (showChevron)
                  const Icon(Icons.keyboard_arrow_down, color: AppColors.onSurfaceVariant)
                else if (selected)
                  const Icon(Icons.check, color: AppColors.primary, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
