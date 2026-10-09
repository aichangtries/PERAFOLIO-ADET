// lib/theme/app_theme.dart
// Dark-only theme from the M7A3 design system.
import 'package:flutter/material.dart';

/// Brand colors that do not have a matching slot in [ColorScheme].
abstract final class AppColors {
  static const appBackground = Color(0xFF000000);
  static const surface = Color(0xFF151515);
  static const surfaceContainerHigh = Color(0xFF232323);
  static const primary = Color(0xFFA449E0);
  static const secondary = Color(0xFF7432A3);
  static const onSurface = Color(0xFFFFFFFF);
  static const onSurfaceVariant = Color(0xFFA3A3A3);
  static const outline = Color(0xFF2E2E2E);
  static const error = Color(0xFFFF5C6C);
  static const success = Color(0xFF48D597);

  /// Purple gradient used on primary buttons and highlight cards.
  static const primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

/// Each bank / e-wallet keeps its own brand color so it is recognizable at
/// a glance in badges, pickers and activity rows. Keyed by account id.
abstract final class BankColors {
  static const gcash = Color(0xFF007DFE);
  static const gotyme = Color(0xFF00F1FB);
  static const maribank = Color(0xFFED5F00);
  static const maya = Color(0xFF22F99F);
  static const bpi = Color(0xFF940005);

  static const _byAccountId = {
    'gcash': gcash,
    'gotyme': gotyme,
    'maribank': maribank,
    'maya': maya,
    'bpi': bpi,
  };

  /// The brand color for [accountId], or null for an unknown provider.
  static Color? of(String accountId) => _byAccountId[accountId];

  /// Black or white, whichever reads better on top of [color].
  static Color foregroundOn(Color color) =>
      ThemeData.estimateBrightnessForColor(color) == Brightness.dark
          ? Colors.white
          : Colors.black;
}

const perafolioScheme = ColorScheme.dark(
  primary: AppColors.primary,
  onPrimary: Color(0xFFFFFFFF),
  secondary: AppColors.secondary,
  onSecondary: Color(0xFFFFFFFF),
  surface: AppColors.surface,
  surfaceContainerHigh: AppColors.surfaceContainerHigh,
  onSurface: AppColors.onSurface,
  onSurfaceVariant: AppColors.onSurfaceVariant,
  error: AppColors.error,
  onError: Color(0xFFFFFFFF),
  outline: AppColors.outline,
);

const _textTheme = TextTheme(
  headlineMedium: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
  headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
  titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
  bodySmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
  labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
);

final appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.appBackground,
  colorScheme: perafolioScheme,
  textTheme: _textTheme,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.appBackground,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
  ),
  dividerTheme: const DividerThemeData(color: AppColors.outline, space: 1),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
  ),
  dialogTheme: const DialogThemeData(
    backgroundColor: AppColors.surface,
    surfaceTintColor: Colors.transparent,
  ),
  snackBarTheme: const SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    backgroundColor: AppColors.surfaceContainerHigh,
    contentTextStyle: TextStyle(color: AppColors.onSurface),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: const WidgetStatePropertyAll(Colors.white),
    trackColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? AppColors.primary
          : AppColors.surfaceContainerHigh,
    ),
    trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceContainerHigh,
    hintStyle: const TextStyle(color: AppColors.onSurfaceVariant),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.outline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.outline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error),
    ),
  ),
);
