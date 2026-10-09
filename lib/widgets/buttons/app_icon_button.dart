import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Icon-only button with an accessible label and an optional unread dot.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    this.showBadge = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String semanticLabel;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: semanticLabel,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon, color: AppColors.onSurface),
          if (showBadge)
            Positioned(
              right: -1,
              top: -1,
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.appBackground, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
