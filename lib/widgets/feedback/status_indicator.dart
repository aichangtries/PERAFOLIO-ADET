import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

enum StatusType { success, warning, error, neutral }

/// "✓ Connected" style label for account / status states.
class StatusIndicator extends StatelessWidget {
  const StatusIndicator({super.key, required this.label, required this.status});

  final String label;
  final StatusType status;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (status) {
      StatusType.success => (AppColors.success, Icons.check),
      StatusType.warning => (const Color(0xFFFFC857), Icons.schedule),
      StatusType.error => (AppColors.error, Icons.error_outline),
      StatusType.neutral => (AppColors.onSurfaceVariant, Icons.circle_outlined),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
