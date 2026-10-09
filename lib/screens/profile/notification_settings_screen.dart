import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../widgets/navigation/app_top_bar.dart';
import '../../widgets/settings/settings_toggle.dart';

/// Screen 12 — Notification Settings. Each switch is saved to Hive.
class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final p = state.preferences;
    return Scaffold(
      appBar: AppTopBar(title: 'Notifications', onBack: () => Navigator.of(context).pop()),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(
              'Choose how PeraFolio keeps you updated.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.md),
            SettingsGroup(children: [
              SettingsToggle(
                label: 'Push notifications',
                subtitle: 'Alerts on this device',
                value: p.pushNotifications,
                onChanged: (v) => state.updatePreferences((p) => p.pushNotifications = v),
              ),
              SettingsToggle(
                label: 'Email',
                subtitle: 'Statements and important updates',
                value: p.emailNotifications,
                onChanged: (v) => state.updatePreferences((p) => p.emailNotifications = v),
              ),
              SettingsToggle(
                label: 'SMS alerts',
                subtitle: 'Transaction confirmations by text',
                value: p.smsAlerts,
                onChanged: (v) => state.updatePreferences((p) => p.smsAlerts = v),
              ),
              SettingsToggle(
                label: 'Promotions',
                subtitle: 'Offers and product news',
                value: p.promotions,
                onChanged: (v) => state.updatePreferences((p) => p.promotions = v),
              ),
            ]),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Prototype: these preferences are saved, but no real messages are sent.',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
