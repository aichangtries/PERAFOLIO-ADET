import 'package:flutter/material.dart';

import '../../models/transfer.dart';
import '../../state/app_state.dart';
import '../../utils/formatters.dart';
import '../../widgets/cards/balance_update_card.dart';
import '../../widgets/detail_list.dart';
import '../../widgets/feedback/success_state.dart';

/// Screen 17 — Transfer Complete.
class TransferCompleteScreen extends StatelessWidget {
  const TransferCompleteScreen({super.key, required this.transfer});

  final Transfer transfer;

  void _finish(BuildContext context, int tab) {
    AppScope.read(context).setHomeTab(tab);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final source = state.accountById(transfer.sourceAccountId)!;
    return Scaffold(
      body: SafeArea(
        child: SuccessState(
          title: 'Transfer complete',
          amount: formatMoney(transfer.amount),
          details: [
            DetailItem('Sent to', state.accountName(transfer.destinationAccountId)),
            DetailItem('From', source.provider),
            DetailItem('Fee', formatMoney(transfer.fee)),
            DetailItem('Date', formatDateTime(transfer.dateTime)),
            DetailItem('Reference', transfer.reference),
            if (transfer.note.isNotEmpty) DetailItem('Note', transfer.note),
          ],
          footer: BalanceUpdateCard(account: source),
          primaryLabel: 'Done',
          onPrimary: () => _finish(context, 0),
          secondaryLabel: 'View in activity',
          onSecondary: () => _finish(context, 1),
        ),
      ),
    );
  }
}
