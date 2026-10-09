import 'package:flutter/material.dart';

import '../models/transaction.dart';
import '../state/app_state.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'cards/account_badge.dart';

/// [badge] Merchant / account · category · time        −₱180.00
class TransactionRow extends StatelessWidget {
  const TransactionRow({super.key, required this.transaction, this.onTap});

  final Transaction transaction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final account = AppScope.of(context).accountName(transaction.accountId);
    final t = transaction;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radius),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
        child: Row(
          children: [
            AccountBadge(
              label: t.merchantOrDescription.isEmpty ? '?' : t.merchantOrDescription[0].toUpperCase(),
              color: BankColors.of(t.accountId),
            ),
            const SizedBox(width: AppSpacing.md - 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.merchantOrDescription,
                    style: text.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$account · ${t.category} · ${formatTime(t.dateTime)}',
                    overflow: TextOverflow.ellipsis,
                    style: text.labelSmall?.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              formatSignedMoney(t.amount, positive: t.isIncome),
              style: text.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: t.isIncome ? AppColors.success : AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
