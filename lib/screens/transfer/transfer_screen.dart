import 'package:flutter/material.dart';

import '../../models/financial_account.dart';
import '../../state/app_state.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../utils/validators.dart';
import '../../widgets/account_selector.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/feedback/empty_state.dart';
import '../../widgets/inputs/amount_field.dart';
import '../../widgets/navigation/app_top_bar.dart';
import '../../widgets/overlays/modal_sheet.dart';
import '../../widgets/transaction_breakdown.dart';
import 'review_transfer_screen.dart';

/// Screen 15 — Transfer Money (with insufficient-balance validation).
class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key, this.initialSourceId});

  final String? initialSourceId;

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _amount = TextEditingController();
  final _note = TextEditingController();
  String? _sourceId;
  String? _destinationId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final connected = AppScope.read(context).connectedAccounts;
    if (_sourceId == null && connected.length >= 2) {
      _sourceId = widget.initialSourceId ?? connected[0].id;
      _destinationId = connected.firstWhere((a) => a.id != _sourceId).id;
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickAccount({required bool isSource}) async {
    final state = AppScope.read(context);
    final excluded = isSource ? _destinationId : _sourceId;
    final options = state.connectedAccounts.where((a) => a.id != excluded).toList();
    final picked = await showModalSheet<String>(
      context,
      title: isSource ? 'Transfer from' : 'Transfer to',
      child: Column(
        children: [
          for (final a in options) ...[
            AccountSelector(
              account: a,
              label: isSource ? 'From account' : 'To account',
              selected: a.id == (isSource ? _sourceId : _destinationId),
              onTap: () => Navigator.of(context).pop(a.id),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
    if (picked == null) return;
    setState(() => isSource ? _sourceId = picked : _destinationId = picked);
  }

  void _swap() => setState(() {
        final s = _sourceId;
        _sourceId = _destinationId;
        _destinationId = s;
      });

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final text = Theme.of(context).textTheme;
    final source = _sourceId == null ? null : state.accountById(_sourceId!);
    final destination = _destinationId == null ? null : state.accountById(_destinationId!);

    if (source == null || destination == null || !source.isConnected || !destination.isConnected) {
      return Scaffold(
        appBar: AppTopBar(title: 'Transfer', onBack: () => Navigator.of(context).pop()),
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: EmptyState(
            icon: Icons.swap_horiz,
            message: 'You need at least two connected accounts to transfer money.',
            actionLabel: 'Connect an account',
            onAction: () {
              state.setHomeTab(2);
              Navigator.of(context).popUntil((r) => r.isFirst);
            },
          ),
        ),
      );
    }

    final amount = parseAmount(_amount.text);
    final error = amount == 0
        ? null
        : state.validateTransfer(sourceId: source.id, destinationId: destination.id, amount: amount);
    final canReview = amount > 0 && error == null;

    return Scaffold(
      appBar: AppTopBar(title: 'Transfer', onBack: () => Navigator.of(context).pop()),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _label(text, 'FROM'),
            AccountSelector(
              account: source,
              label: 'From account',
              showChevron: true,
              onTap: () => _pickAccount(isSource: true),
            ),
            Center(
              child: IconButton.filledTonal(
                tooltip: 'Swap accounts',
                onPressed: _swap,
                style: IconButton.styleFrom(backgroundColor: AppColors.surfaceContainerHigh),
                icon: const Icon(Icons.swap_vert, size: 20),
              ),
            ),
            _label(text, 'TO'),
            AccountSelector(
              account: destination,
              label: 'To account',
              showChevron: true,
              onTap: () => _pickAccount(isSource: false),
            ),
            const SizedBox(height: AppSpacing.lg),
            AmountField(
              controller: _amount,
              onChanged: (_) => setState(() {}),
              helperText: 'Available ${formatMoney(source.balance)}',
              errorText: error,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _note,
              maxLength: 60,
              decoration: const InputDecoration(hintText: 'Add a note (optional)', counterText: ''),
            ),
            const SizedBox(height: AppSpacing.md),
            TransactionBreakdown(
              amount: amount,
              fee: AppState.transferFee,
              feeLabel: 'Transfer fee',
              total: amount + AppState.transferFee,
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: 'Review transfer',
              onPressed: !canReview
                  ? null
                  : () => Navigator.of(context).push(MaterialPageRoute<void>(
                        builder: (_) => ReviewTransferScreen(
                          sourceId: source.id,
                          destinationId: destination.id,
                          amount: amount,
                          note: _note.text,
                        ),
                      )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(TextTheme text, String label) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Text(
          label,
          style: text.labelSmall?.copyWith(color: AppColors.onSurfaceVariant, letterSpacing: 1.5, fontSize: 11),
        ),
      );
}

/// Small helper so other screens can show "GCash · ₱12,450.00".
String accountWithBalance(FinancialAccount a) => '${a.provider} · ${formatMoney(a.balance)}';
