import 'package:flutter/material.dart';

import '../../models/payment.dart';
import '../../state/app_state.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/cards/account_badge.dart';
import '../../widgets/navigation/app_top_bar.dart';
import '../../widgets/review_header.dart';
import '../../widgets/transaction_breakdown.dart';
import '../transfer/transfer_screen.dart';
import 'payment_success_screen.dart';

/// Screen 20 — Review Payment.
class ReviewPaymentScreen extends StatefulWidget {
  const ReviewPaymentScreen({super.key, required this.draft});

  final PaymentDraft draft;

  @override
  State<ReviewPaymentScreen> createState() => _ReviewPaymentScreenState();
}

class _ReviewPaymentScreenState extends State<ReviewPaymentScreen> {
  bool _busy = false;

  Future<void> _confirm() async {
    setState(() => _busy = true);
    final state = AppScope.read(context);
    final navigator = Navigator.of(context);
    try {
      final payment = await state.confirmPayment(widget.draft);
      navigator.pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => PaymentSuccessScreen(payment: payment)),
        (route) => route.isFirst,
      );
    } on StateError catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final text = Theme.of(context).textTheme;
    final draft = widget.draft;
    final source = state.accountById(draft.sourceAccountId)!;
    final error = state.validatePayment(draft);

    return Scaffold(
      appBar: AppTopBar(title: 'Review payment', onBack: () => Navigator.of(context).pop()),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            ReviewHeader(
              leading: const AccountBadge(label: '', icon: Icons.qr_code_2, highlighted: true, size: 52),
              title: draft.merchant,
              subtitle: draft.merchantDetail,
              amount: formatMoney(draft.amount),
            ),
            const SizedBox(height: AppSpacing.lg),
            TransactionBreakdown(
              leading: [('Paying from', accountWithBalance(source))],
              amount: draft.amount,
              fee: draft.fee,
              total: draft.total,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              error ?? 'Balance after: ${formatMoney(source.balance - draft.total)}',
              textAlign: TextAlign.center,
              style: text.labelSmall?.copyWith(
                color: error != null ? AppColors.error : AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: 'Confirm payment',
              isLoading: _busy,
              onPressed: error == null ? _confirm : null,
            ),
            TextButton(
              onPressed: _busy ? null : () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(foregroundColor: AppColors.onSurfaceVariant),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
