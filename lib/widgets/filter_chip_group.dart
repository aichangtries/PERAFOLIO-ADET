import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';

/// Horizontally scrolling single-select chips (Dashboard categories,
/// Activity "All / Money in / Money out").
class FilterChipGroup extends StatelessWidget {
  const FilterChipGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final option in options)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: ChoiceChip(
                label: Text(option),
                selected: option == selected,
                showCheckmark: false,
                onSelected: (_) => onSelected(option),
                labelStyle: TextStyle(
                  fontSize: 13,
                  color: option == selected ? Colors.white : AppColors.onSurfaceVariant,
                ),
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surface,
                side: BorderSide(
                  color: option == selected ? AppColors.primary : AppColors.outline,
                ),
                shape: const StadiumBorder(),
              ),
            ),
        ],
      ),
    );
  }
}
