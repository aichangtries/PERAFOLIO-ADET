import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../buttons/primary_button.dart';
import '../detail_list.dart';

/// Shared completion layout for Transfer Complete and Payment Successful.
class SuccessState extends StatelessWidget {
  const SuccessState({
    super.key,
    required this.title,
    required this.amount,
    required this.details,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.footer,
  });

  final String title;
  final String amount;
  final List<DetailItem> details;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  /// Extra content under the details (e.g. the updated balance).
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
              border: Border.all(color: const Color(0xFF241631), width: 8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 24,
                ),
              ],
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 36),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(title, textAlign: TextAlign.center, style: text.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Text(amount, textAlign: TextAlign.center, style: text.headlineMedium),
        const SizedBox(height: AppSpacing.lg),
        DetailList(items: details),
        if (footer != null) ...[
          const SizedBox(height: AppSpacing.md),
          footer!,
        ],
        const SizedBox(height: AppSpacing.lg),
        PrimaryButton(label: primaryLabel, onPressed: onPrimary),
        if (secondaryLabel != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: TextButton(
              onPressed: onSecondary,
              style: TextButton.styleFrom(foregroundColor: AppColors.onSurfaceVariant),
              child: Text(secondaryLabel!),
            ),
          ),
      ],
    );
  }
}
