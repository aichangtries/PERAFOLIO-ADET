import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';

/// One label/value line inside a summary card.
class DetailItem {
  const DetailItem(this.label, this.value, {this.emphasize = false});

  final String label;
  final String value;
  final bool emphasize;
}

/// Bordered card listing [DetailItem]s (review and success screens).
class DetailList extends StatelessWidget {
  const DetailList({super.key, required this.items});

  final List<DetailItem> items;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: [
          for (final item in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: text.bodySmall?.copyWith(
                      color: item.emphasize ? AppColors.onSurface : AppColors.onSurfaceVariant,
                      fontWeight: item.emphasize ? FontWeight.w600 : null,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      item.value,
                      textAlign: TextAlign.right,
                      style: text.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
