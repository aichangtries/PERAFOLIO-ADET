import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/cards/account_badge.dart';
import '../../widgets/navigation/app_top_bar.dart';
import '../../widgets/review_header.dart';
import '../../widgets/transaction_breakdown.dart';
import 'transfer_complete_screen.dart';
import 'transfer_screen.dart';

/// Screen 16 — Review Transfer.
class ReviewTransferScreen extends StatefulWidget {
  const ReviewTransferScreen({
    super.key,
    required this.sourceId,
    required this.destinationId,
    required this.amount,
    this.note = '',
  });

  final String sourceId;
  final String destinationId;
  final double amount;
  final String note;

  @override
  State<ReviewTransferScreen> createState() => _ReviewTransferScreenState();
}

class _ReviewTransferScreenState extends State<ReviewTransferScreen> {
  bool _busy = false;

  Future<void> _confirm() async {
    setState(() => _busy = true);
    final state = AppScope.read(context);
    final navigator = Navigator.of(context);
    try {
      final transfer = await state.confirmTransfer(
        sourceId: widget.sourceId,
        destinationId: widget.destinationId,
        amount: widget.amount,
        note: widget.note,
      );
      // Replace the whole transfer flow so "back" returns to the app.
      navigator.pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => TransferCompleteScreen(transfer: transfer)),
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
    final source = state.accountById(widget.sourceId)!;
    final destination = state.accountById(widget.destinationId)!;
    final total = widget.amount + AppState.transferFee;

    return Scaffold(
      appBar: AppTopBar(title: 'Review transfer', onBack: () => Navigator.of(context).pop()),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            ReviewHeader(
              leading: AccountBadge(
                label: destination.initial,
                highlighted: true,
                size: 52,
                color: BankColors.of(destination.id),
              ),
              title: destination.provider,
              subtitle: destination.accountType,
              amount: formatMoney(widget.amount),
            ),
            const SizedBox(height: AppSpacing.lg),
            TransactionBreakdown(
              leading: [
                ('From', accountWithBalance(source)),
                ('To', destination.provider),
                if (widget.note.trim().isNotEmpty) ('Note', widget.note.trim()),
              ],
              amount: widget.amount,
              fee: AppState.transferFee,
              total: total,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Balance after: ${formatMoney(source.balance - total)}',
              textAlign: TextAlign.center,
              style: text.labelSmall?.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(label: 'Confirm transfer', isLoading: _busy, onPressed: _confirm),
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
