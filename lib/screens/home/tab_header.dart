import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/cards/profile_card.dart';
import '../profile/profile_screen.dart';

/// "Activity  (A)" / "Accounts  (A)" title row; the avatar opens Profile.
class TabHeader extends StatelessWidget {
  const TabHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final profile = AppScope.of(context).profile;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
      child: Row(
        children: [
          Expanded(child: Text(title, style: Theme.of(context).textTheme.headlineSmall)),
          ProfileAvatarButton(initial: profile.initial),
        ],
      ),
    );
  }
}

class ProfileAvatarButton extends StatelessWidget {
  const ProfileAvatarButton({super.key, required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Open profile',
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
      ),
      icon: UserAvatar(initial: initial),
    );
  }
}
