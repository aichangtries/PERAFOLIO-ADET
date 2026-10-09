import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/financial_account.dart';
import '../../state/app_state.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/cards/account_badge.dart';
import '../../widgets/overlays/modal_sheet.dart';

/// Screen 6 — Verify Account. Returns true when the account was connected.
Future<bool> showVerifyAccountSheet(BuildContext context, FinancialAccount account) async {
  final connected = await showModalSheet<bool>(
    context,
    child: _VerifyForm(account: account),
  );
  if (connected == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${account.provider} connected')),
    );
  }
  return connected ?? false;
}

class _VerifyForm extends StatefulWidget {
  const _VerifyForm({required this.account});

  final FinancialAccount account;

  @override
  State<_VerifyForm> createState() => _VerifyFormState();
}

class _VerifyFormState extends State<_VerifyForm> {
  final _code = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    setState(() => _busy = true);
    // Short pause so the simulated "verifying" state is visible.
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    await AppScope.read(context).connectAccount(widget.account.id);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final provider = widget.account.provider;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AccountBadge(label: '', icon: Icons.verified_user_outlined, highlighted: true, size: 36),
        const SizedBox(height: AppSpacing.md),
        Text('Verify $provider', style: text.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'This is a simulated connection. Enter any 6-digit code '
          '(for example 002125) to link a demo $provider account.',
          style: text.labelSmall?.copyWith(color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.lg),
        TextField(
          controller: _code,
          autofocus: true,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(fontSize: 22, letterSpacing: 10, fontWeight: FontWeight.w600),
          decoration: const InputDecoration(hintText: '••••••', counterText: ''),
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _code.text.length == 6 ? _verify() : null,
        ),
        const SizedBox(height: AppSpacing.lg),
        PrimaryButton(
          label: 'Verify and connect',
          isLoading: _busy,
          onPressed: _code.text.length == 6 ? _verify : null,
        ),
        Center(
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(foregroundColor: AppColors.onSurfaceVariant),
            child: const Text('Cancel'),
          ),
        ),
      ],
    );
  }
}
