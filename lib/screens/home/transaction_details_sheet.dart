import 'package:flutter/material.dart';

import '../../models/transaction.dart';
import '../../state/app_state.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/detail_list.dart';
import '../../widgets/overlays/modal_sheet.dart';

/// Bottom sheet opened by tapping any TransactionRow.
Future<void> showTransactionDetails(BuildContext context, Transaction t) {
  final account = AppScope.read(context).accountName(t.accountId);
  return showModalSheet(
    context,
    title: t.merchantOrDescription,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          formatSignedMoney(t.amount, positive: t.isIncome),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: t.isIncome ? AppColors.success : null,
              ),
        ),
        const SizedBox(height: AppSpacing.md),
        DetailList(items: [
          DetailItem('Account', account),
          DetailItem('Category', t.category),
          DetailItem('Type', t.isIncome ? 'Money in' : 'Money out'),
          DetailItem('Date', formatDateTime(t.dateTime)),
          DetailItem('Status', t.status),
        ]),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Simulated transaction · stored on this device',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant),
        ),
      ],
    ),
  );
}
