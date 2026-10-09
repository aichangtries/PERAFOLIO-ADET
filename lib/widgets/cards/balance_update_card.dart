import 'package:flutter/material.dart';

import '../../models/financial_account.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import 'account_badge.dart';

/// "New GCash balance ₱10,435.00" box on the success screens.
class BalanceUpdateCard extends StatelessWidget {
  const BalanceUpdateCard({super.key, required this.account});

  final FinancialAccount account;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md - 2),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0B0B),
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          AccountBadge(
            label: account.initial,
            highlighted: true,
            size: 36,
            color: BankColors.of(account.id),
          ),
          const SizedBox(width: AppSpacing.md - 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'New ${account.provider} balance',
                style: text.labelSmall?.copyWith(color: AppColors.onSurfaceVariant),
              ),
              Text(formatMoney(account.balance), style: text.titleMedium),
            ],
          ),
        ],
      ),
    );
  }
}
