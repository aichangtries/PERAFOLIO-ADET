import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';

/// Centered recipient + amount at the top of Review Transfer / Review Payment.
class ReviewHeader extends StatelessWidget {
  const ReviewHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    this.leading,
  });

  final String title;
  final String subtitle;
  final String amount;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      children: [
        ?leading, // only added when not null
        const SizedBox(height: AppSpacing.md - 4),
        Text(title, style: text.titleMedium, textAlign: TextAlign.center),
        const SizedBox(height: 2),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: text.labelSmall?.copyWith(color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(amount, style: text.headlineMedium),
      ],
    );
  }
}
