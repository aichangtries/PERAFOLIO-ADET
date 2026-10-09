import 'package:flutter/material.dart';

import '../../models/payment.dart';
import '../../state/app_state.dart';
import '../../utils/formatters.dart';
import '../../widgets/cards/balance_update_card.dart';
import '../../widgets/detail_list.dart';
import '../../widgets/feedback/success_state.dart';

/// Screen 21 — Payment Successful.
class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key, required this.payment});

  final Payment payment;

  void _finish(BuildContext context, int tab) {
    AppScope.read(context).setHomeTab(tab);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final source = state.accountById(payment.sourceAccountId)!;
    return Scaffold(
      body: SafeArea(
        child: SuccessState(
          title: 'Payment sent',
          amount: formatMoney(payment.amount),
          details: [
            DetailItem('Paid to', payment.merchant),
            DetailItem('From', source.provider),
            DetailItem('Date', formatDateTime(payment.dateTime)),
            DetailItem('Reference', payment.reference),
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
