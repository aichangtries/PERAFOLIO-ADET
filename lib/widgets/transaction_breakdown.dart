import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

/// Amount / fee / total summary (Transfer entry, Transfer and Payment review).
class TransactionBreakdown extends StatelessWidget {
  const TransactionBreakdown({
    super.key,
    required this.amount,
    required this.fee,
    required this.total,
    this.feeLabel = 'Fee',
    this.leading,
  });

  final double amount;
  final double fee;
  final double total;
  final String feeLabel;

  /// Optional rows above the amount (e.g. From / To).
  final List<(String, String)>? leading;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    Widget row(String label, String value, {bool bold = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Text(
                label,
                style: text.bodySmall?.copyWith(
                  color: bold ? AppColors.onSurface : AppColors.onSurfaceVariant,
                  fontWeight: bold ? FontWeight.w600 : null,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: text.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: [
          for (final (label, value) in leading ?? const <(String, String)>[]) row(label, value),
          row('Amount', formatMoney(amount)),
          row(feeLabel, fee == 0 ? 'Free' : formatMoney(fee)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Divider(),
          ),
          row('Total', formatMoney(total), bold: true),
        ],
      ),
    );
  }
}
