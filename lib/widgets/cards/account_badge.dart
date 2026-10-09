import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Rounded square with a provider initial ("G", "M", "B").
///
/// Pass [color] (see [BankColors]) to fill the badge with a
/// bank's brand color instead of the neutral/purple styles.
class AccountBadge extends StatelessWidget {
  const AccountBadge({
    super.key,
    required this.label,
    this.highlighted = false,
    this.icon,
    this.size = 40,
    this.color,
  });

  final String label;
  final bool highlighted;
  final IconData? icon;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final brand = color;
    final Color background;
    final Color foreground;
    if (brand != null) {
      background = brand;
      foreground = BankColors.foregroundOn(brand);
    } else {
      background = highlighted ? const Color(0xFF241631) : AppColors.surfaceContainerHigh;
      foreground = highlighted ? AppColors.primary : AppColors.onSurfaceVariant;
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      alignment: Alignment.center,
      child: icon != null
          ? Icon(icon, color: foreground, size: size * 0.5)
          : Text(
              label,
              style: TextStyle(
                color: foreground,
                fontWeight: FontWeight.w700,
                fontSize: size * 0.38,
              ),
            ),
    );
  }
}
