import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../widgets/buttons/secondary_button.dart';
import '../../widgets/cards/profile_card.dart';
import '../../widgets/settings/settings_row.dart';
import 'notification_settings_screen.dart';
import 'personal_details_screen.dart';
import 'security_privacy_screen.dart';

/// Screen 10 — Profile.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('Your simulated accounts and activity stay saved on this device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final state = AppScope.read(context);
    // Close every pushed screen; the gate underneath then shows Landing.
    Navigator.of(context).popUntil((route) => route.isFirst);
    await state.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final profile = AppScope.of(context).profile;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Text('Profile', style: Theme.of(context).textTheme.headlineSmall),
        actions: [
          IconButton(
            tooltip: 'Close',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            ProfileCard(
              name: profile.fullName,
              email: profile.email,
              initial: profile.initial,
              onTap: () => _open(context, const PersonalDetailsScreen()),
            ),
            const SizedBox(height: AppSpacing.md),
            SettingsRow(
              icon: Icons.person_outline,
              label: 'Personal details',
              onTap: () => _open(context, const PersonalDetailsScreen()),
            ),
            const Divider(),
            SettingsRow(
              icon: Icons.notifications_none,
              label: 'Notifications',
              onTap: () => _open(context, const NotificationSettingsScreen()),
            ),
            const Divider(),
            SettingsRow(
              icon: Icons.shield_outlined,
              label: 'Security & privacy',
              onTap: () => _open(context, const SecurityPrivacyScreen()),
            ),
            const Divider(),
            const SizedBox(height: AppSpacing.lg),
            SecondaryButton(label: 'Sign out', onPressed: () => _signOut(context)),
          ],
        ),
      ),
    );
  }
}
