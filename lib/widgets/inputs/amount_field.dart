import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';

/// Large centered "₱ 2,000" amount entry with a helper/error line below.
class AmountField extends StatelessWidget {
  const AmountField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.helperText,
    this.errorText,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? helperText;
  final String? errorText;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(
          'AMOUNT',
          style: text.labelSmall?.copyWith(color: AppColors.onSurfaceVariant, letterSpacing: 1.5, fontSize: 11),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Text('₱', style: text.headlineSmall?.copyWith(color: AppColors.onSurfaceVariant)),
            Expanded(
              child: TextField(
                controller: controller,
                autofocus: autofocus,
                textAlign: TextAlign.center,
                style: text.headlineMedium,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  // Digits with at most one dot and two decimals.
                  FilteringTextInputFormatter.allow(RegExp(r'^\d{0,9}(\.\d{0,2})?')),
                ],
                onChanged: onChanged,
                decoration: const InputDecoration(
                  hintText: '0.00',
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
          ],
        ),
        Text(
          errorText ?? helperText ?? '',
          style: text.labelSmall?.copyWith(
            color: errorText != null ? AppColors.error : AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
