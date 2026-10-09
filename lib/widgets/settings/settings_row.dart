import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../cards/account_badge.dart';

/// Icon + label (+ subtitle) + chevron row for Profile and settings.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.boxed = false,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  /// Draws the row as its own bordered card (Security & privacy "Manage").
  final bool boxed;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final content = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: boxed ? AppSpacing.md - 4 : 0,
        vertical: AppSpacing.md - 4,
      ),
      child: Row(
        children: [
          AccountBadge(label: '', icon: icon, size: 36),
          const SizedBox(width: AppSpacing.md - 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: text.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: text.labelSmall?.copyWith(color: AppColors.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
        ],
      ),
    );

    if (!boxed) {
      return InkWell(onTap: onTap, child: content);
    }
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radius),
            border: Border.all(color: AppColors.outline),
          ),
          child: content,
        ),
      ),
    );
  }
}
