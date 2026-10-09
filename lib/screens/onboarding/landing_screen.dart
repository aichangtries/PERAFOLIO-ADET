import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../widgets/brand/perafolio_logo.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/buttons/secondary_button.dart';
import 'auth_sheet.dart';

/// Screen 1 — Landing Page.
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                const PeraFolioLogo(height: 120),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'All your money.\nOne place.',
                  textAlign: TextAlign.center,
                  style: text.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Connect your banks and e-wallets to see your complete financial picture.',
                  textAlign: TextAlign.center,
                  style: text.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  label: 'Get started',
                  onPressed: () => showAuthSheet(context, mode: AuthMode.signUp),
                ),
                const SizedBox(height: AppSpacing.md - 4),
                SecondaryButton(
                  label: 'I already have an account',
                  onPressed: () => showAuthSheet(context, mode: AuthMode.logIn),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shield_outlined, size: 14, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: Text(
                        'Prototype · simulated accounts, no real bank access',
                        style: text.labelSmall?.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
