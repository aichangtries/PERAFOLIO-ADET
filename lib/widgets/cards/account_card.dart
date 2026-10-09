import 'package:flutter/material.dart';

import '../../models/financial_account.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../feedback/status_indicator.dart';
import 'account_badge.dart';

/// A bank/e-wallet row. Connected accounts show their balance (or a
/// "Connected" status when [showStatus] is true); available accounts show
/// a Connect pill that calls [onConnect].
class AccountCard extends StatelessWidget {
  const AccountCard({
    super.key,
    required this.account,
    this.onTap,
    this.onConnect,
    this.showStatus = false,
  });

  final FinancialAccount account;
  final VoidCallback? onTap;
  final VoidCallback? onConnect;
  final bool showStatus;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final dimmed = showStatus && account.isConnected;

    Widget trailing;
    if (!account.isConnected) {
      trailing = FilledButton(
        onPressed: onConnect,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          shape: const StadiumBorder(),
        ),
        child: const Text('Connect'),
      );
    } else if (showStatus) {
      trailing = const StatusIndicator(label: 'Connected', status: StatusType.success);
    } else {
      trailing = Text(formatMoney(account.balance), style: text.titleMedium);
    }

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md - 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radius),
            border: Border.all(color: AppColors.outline),
          ),
          child: Opacity(
            opacity: dimmed ? 0.6 : 1,
            child: Row(
              children: [
                AccountBadge(
                  label: account.initial,
                  color: BankColors.of(account.id),
                  highlighted: account.isConnected,
                ),
                const SizedBox(width: AppSpacing.md - 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(account.provider, style: text.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        account.accountType,
                        style: text.labelSmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
