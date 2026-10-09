import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/cards/account_card.dart';
import '../../widgets/navigation/app_top_bar.dart';
import 'verify_account_sheet.dart';

/// Screen 5 — Connect Accounts (shown right after sign up / log in).
class ConnectAccountsScreen extends StatelessWidget {
  const ConnectAccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final connectedCount = state.connectedAccounts.length;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppTopBar(
        title: 'Connect accounts',
        // Leaving onboarding signs the user out and returns to Landing.
        onBack: state.signOut,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(
              'Choose the banks and e-wallets you use. You can add more later.',
              style: text.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final account in state.accounts) ...[
              AccountCard(
                account: account,
                showStatus: true,
                onConnect: () => showVerifyAccountSheet(context, account),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              label: connectedCount == 1
                  ? 'Continue with 1 account'
                  : 'Continue with $connectedCount accounts',
              onPressed: connectedCount == 0 ? null : state.finishOnboarding,
            ),
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: TextButton(
                onPressed: state.finishOnboarding,
                style: TextButton.styleFrom(foregroundColor: AppColors.onSurfaceVariant),
                child: const Text('Skip for now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
