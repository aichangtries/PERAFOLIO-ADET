import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Home · Activity · [Pay] · Accounts.
///
/// [currentIndex] is 0 = Home, 1 = Activity, 2 = Accounts. Pay is not a tab:
/// it opens the Pay flow through [onPay].
class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.onPay,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFF0B0B0B),
        border: Border(top: BorderSide(color: AppColors.outline)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                label: 'Home',
                selected: currentIndex == 0,
                onTap: () => onDestinationSelected(0),
              ),
              _NavItem(
                icon: Icons.show_chart,
                label: 'Activity',
                selected: currentIndex == 1,
                onTap: () => onDestinationSelected(1),
              ),
              Expanded(
                child: Semantics(
                  button: true,
                  label: 'Pay',
                  child: InkWell(
                    onTap: onPay,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 46,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.45),
                                blurRadius: 14,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.qr_code_2, color: Colors.white),
                        ),
                        const SizedBox(height: 2),
                        const Text('Pay', style: TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ),
              _NavItem(
                icon: Icons.grid_view,
                label: 'Accounts',
                selected: currentIndex == 2,
                onTap: () => onDestinationSelected(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.onSurfaceVariant;
    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 11, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
