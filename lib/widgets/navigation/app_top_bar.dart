import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Centered title with a back arrow, used on pushed screens
/// (Transfer, Pay, review screens, settings/details).
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({super.key, required this.title, this.onBack, this.actions});

  final String title;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(57);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leading: onBack == null
          ? null
          : IconButton(
              onPressed: onBack,
              tooltip: 'Back',
              icon: const Icon(Icons.arrow_back),
            ),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      actions: actions,
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: AppColors.outline),
      ),
    );
  }
}
