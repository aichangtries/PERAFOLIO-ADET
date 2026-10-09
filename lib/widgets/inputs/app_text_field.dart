import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';

/// Labelled text field: small uppercase caption above an input.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.keyboardType,
    this.errorText,
    this.obscureText = false,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.maxLength,
    this.autofillHints,
  });

  final String label;
  final String? hintText;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? errorText;
  final bool obscureText;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final int? maxLength;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.onSurfaceVariant,
                letterSpacing: 1.2,
                fontSize: 11,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          textInputAction: textInputAction,
          readOnly: readOnly,
          onTap: onTap,
          maxLength: maxLength,
          autofillHints: autofillHints,
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errorText,
            suffixIcon: suffixIcon,
            counterText: '',
          ),
        ),
      ],
    );
  }
}
