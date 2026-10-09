import 'package:flutter/material.dart';

import '../../models/financial_account.dart';
import '../../state/app_state.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/buttons/secondary_button.dart';
import '../../widgets/cards/account_card.dart';
import '../../widgets/detail_list.dart';
import '../../widgets/feedback/empty_state.dart';
import '../../widgets/overlays/modal_sheet.dart';
import '../onboarding/verify_account_sheet.dart';
import '../transfer/transfer_screen.dart';
import 'tab_header.dart';

/// Screen 9 — Accounts: total, connected accounts, and accounts that can
/// still be connected.
class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final text = Theme.of(context).textTheme;
    final connected = state.connectedAccounts;
    final available = state.availableAccounts;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const TabHeader(title: 'Accounts'),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg - 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSpacing.radius + 4),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2A1638), Color(0xFF0E0E0E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL BALANCE',
                      style: text.labelSmall?.copyWith(color: AppColors.onSurfaceVariant, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(formatMoney(state.totalBalance), style: text.headlineSmall),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Across ${connected.length} connected account${connected.length == 1 ? '' : 's'}',
                      style: text.labelSmall?.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (connected.isEmpty)
                const EmptyState(
                  icon: Icons.account_balance_outlined,
                  message: 'No accounts connected yet. Connect one below.',
                ),
              for (final account in connected) ...[
                AccountCard(
                  account: account,
                  onTap: () => _showAccountDetails(context, account),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              if (available.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Text('Available to connect', style: text.titleMedium),
                const SizedBox(height: AppSpacing.md - 4),
                for (final account in available) ...[
                  AccountCard(
                    account: account,
                    onConnect: () => showVerifyAccountSheet(context, account),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Manage a connected account: sync, transfer from it, or disconnect.
void _showAccountDetails(BuildContext context, FinancialAccount account) {
  showModalSheet<void>(
    context,
    title: account.provider,
    child: _AccountDetails(accountId: account.id),
  );
}

class _AccountDetails extends StatefulWidget {
  const _AccountDetails({required this.accountId});

  final String accountId;

  @override
  State<_AccountDetails> createState() => _AccountDetailsState();
}

class _AccountDetailsState extends State<_AccountDetails> {
  bool _confirmDisconnect = false;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final account = state.accountById(widget.accountId)!;
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(formatMoney(account.balance), style: text.headlineMedium),
        const SizedBox(height: AppSpacing.md),
        DetailList(items: [
          DetailItem('Type', account.accountType),
          const DetailItem('Status', 'Connected (simulated)'),
          DetailItem('Last sync', account.lastSync == null ? '—' : formatDateTime(account.lastSync!)),
        ]),
        const SizedBox(height: AppSpacing.lg),
        PrimaryButton(
          label: 'Transfer from ${account.provider}',
          onPressed: state.connectedAccounts.length < 2
              ? null
              : () {
                  final navigator = Navigator.of(context);
                  navigator.pop();
                  navigator.push(MaterialPageRoute<void>(
                    builder: (_) => TransferScreen(initialSourceId: account.id),
                  ));
                },
        ),
        const SizedBox(height: AppSpacing.sm),
        SecondaryButton(
          label: 'Sync now',
          icon: Icons.sync,
          onPressed: () async {
            await state.syncAccount(account.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${account.provider} synced (simulated)')),
              );
            }
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        if (!_confirmDisconnect)
          TextButton(
            onPressed: () => setState(() => _confirmDisconnect = true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Disconnect account'),
          )
        else ...[
          Text(
            'Disconnect ${account.provider}? Its balance and activity will be hidden until you connect it again.',
            textAlign: TextAlign.center,
            style: text.labelSmall?.copyWith(color: AppColors.onSurfaceVariant),
          ),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => setState(() => _confirmDisconnect = false),
                  child: const Text('Keep'),
                ),
              ),
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);
                    await state.disconnectAccount(account.id);
                    navigator.pop();
                    messenger.showSnackBar(
                      SnackBar(content: Text('${account.provider} disconnected')),
                    );
                  },
                  child: const Text('Disconnect'),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
