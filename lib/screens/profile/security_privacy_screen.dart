import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../state/app_state.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/buttons/secondary_button.dart';
import '../../widgets/detail_list.dart';
import '../../widgets/inputs/app_text_field.dart';
import '../../widgets/navigation/app_top_bar.dart';
import '../../widgets/overlays/modal_sheet.dart';
import '../../widgets/settings/settings_row.dart';
import '../../widgets/settings/settings_toggle.dart';

/// Screen 13 — Privacy and Security.
class SecurityPrivacyScreen extends StatelessWidget {
  const SecurityPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final p = state.preferences;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppTopBar(title: 'Security & privacy', onBack: () => Navigator.of(context).pop()),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            SettingsGroup(children: [
              SettingsToggle(
                label: 'Biometric login',
                subtitle: 'Use Face ID or fingerprint to sign in (simulated)',
                value: p.biometricLogin,
                onChanged: (v) => state.updatePreferences((p) => p.biometricLogin = v),
              ),
              SettingsToggle(
                label: 'Two-factor authentication',
                subtitle: 'Require a code for new devices (simulated)',
                value: p.twoFactorAuthentication,
                onChanged: (v) => state.updatePreferences((p) => p.twoFactorAuthentication = v),
              ),
            ]),
            const SizedBox(height: AppSpacing.lg),
            Text('Manage', style: text.titleMedium),
            const SizedBox(height: AppSpacing.md - 4),
            SettingsRow(
              boxed: true,
              icon: Icons.pin_outlined,
              label: 'Change PIN',
              subtitle: 'Simulated · PINs are never stored',
              onTap: () => showModalSheet<void>(context, title: 'Change PIN', child: const _ChangePinForm()),
            ),
            const SizedBox(height: AppSpacing.sm),
            SettingsRow(
              boxed: true,
              icon: Icons.devices_outlined,
              label: 'Active sessions',
              subtitle: '1 device signed in',
              onTap: () => showModalSheet<void>(
                context,
                title: 'Active sessions',
                child: const DetailList(items: [
                  DetailItem('This browser', 'Active now', emphasize: true),
                  DetailItem('Storage', 'Local (Hive CE)'),
                ]),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SettingsRow(
              boxed: true,
              icon: Icons.storage_outlined,
              label: 'Data & privacy',
              subtitle: 'Review or reset your local data',
              onTap: () => showModalSheet<void>(context, title: 'Data & privacy', child: const _DataPrivacy()),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChangePinForm extends StatefulWidget {
  const _ChangePinForm();

  @override
  State<_ChangePinForm> createState() => _ChangePinFormState();
}

class _ChangePinFormState extends State<_ChangePinForm> {
  final _pin = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _pin.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    String? error;
    if (_pin.text.length < 4) {
      error = 'PIN must be 4 to 6 digits.';
    } else if (_pin.text != _confirm.text) {
      error = 'PINs do not match.';
    }
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(const SnackBar(content: Text('PIN updated (simulated)')));
  }

  @override
  Widget build(BuildContext context) {
    final digits = [FilteringTextInputFormatter.digitsOnly];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: 'New PIN',
          controller: _pin,
          obscureText: true,
          maxLength: 6,
          keyboardType: TextInputType.number,
          inputFormatters: digits,
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'Confirm PIN',
          controller: _confirm,
          obscureText: true,
          maxLength: 6,
          keyboardType: TextInputType.number,
          inputFormatters: digits,
          errorText: _error,
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: AppSpacing.lg),
        PrimaryButton(label: 'Update PIN', onPressed: _submit),
      ],
    );
  }
}

class _DataPrivacy extends StatefulWidget {
  const _DataPrivacy();

  @override
  State<_DataPrivacy> createState() => _DataPrivacyState();
}

class _DataPrivacyState extends State<_DataPrivacy> {
  bool _confirming = false;

  Future<void> _reset() async {
    final state = AppScope.read(context);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    await state.resetDemoData();
    navigator.popUntil((route) => route.isFirst);
    state.setHomeTab(0);
    messenger.showSnackBar(const SnackBar(content: Text('Demo data restored')));
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'PeraFolio is a prototype. Your profile, simulated accounts, activity, '
          'transfers, payments, notifications and preferences are stored only in '
          'this browser using Hive CE. Nothing is sent to a server or a real bank.',
          style: text.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (!_confirming)
          SecondaryButton(
            label: 'Reset demo data',
            icon: Icons.restart_alt,
            foregroundColor: AppColors.error,
            onPressed: () => setState(() => _confirming = true),
          )
        else ...[
          Text(
            'This erases your changes and restores the original sample data.',
            textAlign: TextAlign.center,
            style: text.labelSmall?.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: AppSpacing.sm),
          PrimaryButton(label: 'Yes, reset everything', onPressed: _reset),
          TextButton(
            onPressed: () => setState(() => _confirming = false),
            child: const Text('Cancel'),
          ),
        ],
      ],
    );
  }
}
