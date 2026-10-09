import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../utils/validators.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/inputs/app_text_field.dart';
import '../../widgets/overlays/modal_sheet.dart';
import '../../widgets/segmented_tabs.dart';

enum AuthMode { logIn, signUp }

/// Screens 2–4 — Sign Up, Log In and their Validation Error state,
/// shown as one bottom sheet with a Log in / Sign up switch.
Future<void> showAuthSheet(BuildContext context, {required AuthMode mode}) {
  return showModalSheet(context, child: _AuthForm(initialMode: mode));
}

class _AuthForm extends StatefulWidget {
  const _AuthForm({required this.initialMode});

  final AuthMode initialMode;

  @override
  State<_AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<_AuthForm> {
  late AuthMode _mode = widget.initialMode;
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _submitting = false;
  bool _submitted = false;
  String? _formError;
  String? _formInfo;

  bool get _isSignUp => _mode == AuthMode.signUp;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String? get _nameError => _submitted && _isSignUp ? validateName(_name.text) : null;
  String? get _emailError => _submitted ? validateEmail(_email.text) : null;
  String? get _passwordError => _submitted ? validatePassword(_password.text) : null;

  Future<void> _submit() async {
    setState(() {
      _submitted = true;
      _formError = null;
      _formInfo = null;
    });
    if (_nameError != null || _emailError != null || _passwordError != null) return;

    setState(() => _submitting = true);
    final state = AppScope.read(context);
    final String? message;
    if (_isSignUp) {
      message = await state.signUp(
        fullName: _name.text,
        email: _email.text,
        password: _password.text,
      );
    } else {
      message = await state.logIn(email: _email.text, password: _password.text);
    }
    if (!mounted) return;
    if (state.isSignedIn) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _submitting = false;
      if (_isSignUp && message != null && message.startsWith('Check ')) {
        // Supabase wants the email confirmed first: switch to Log in.
        _mode = AuthMode.logIn;
        _submitted = false;
        _formInfo = message;
      } else {
        _formError = message ?? 'Something went wrong. Please try again.';
      }
    });
  }

  void _switchMode(int index) {
    setState(() {
      _mode = AuthMode.values[index];
      _submitted = false;
      _formError = null;
      _formInfo = null;
    });
  }

  Future<void> _forgotPassword() async {
    final state = AppScope.read(context);
    final String title;
    final String body;
    if (!state.usesRemoteDatabase) {
      title = 'Forgot password?';
      body = 'Password reset is simulated in this offline demo. Passwords are '
          'never stored, so log in with your account email and any password '
          'of 6+ characters.\n\nDemo account: ${state.demoAccountEmail}';
    } else {
      final emailError = validateEmail(_email.text);
      if (emailError != null) {
        setState(() => _formError = 'Enter your email above, then tap Forgot password.');
        return;
      }
      final error = await state.sendPasswordReset(_email.text);
      if (!mounted) return;
      title = error == null ? 'Check your email' : 'Could not send reset link';
      body = error ?? 'We sent a password reset link to ${_email.text.trim()}.';
    }
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final muted = text.labelSmall?.copyWith(color: AppColors.onSurfaceVariant);
    final firstError = _formError ?? _nameError ?? _emailError ?? _passwordError;

    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedTabs(
            labels: const ['Log in', 'Sign up'],
            selectedIndex: _mode.index,
            onChanged: _switchMode,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(_isSignUp ? 'Create your account' : 'Welcome back', style: text.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _isSignUp
                ? 'Set up your PeraFolio account in a minute.'
                : 'Log in to see your accounts and activity.',
            style: muted,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_isSignUp) ...[
            AppTextField(
              label: 'Full name',
              hintText: 'Juan Dela Cruz',
              controller: _name,
              errorText: _nameError,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          AppTextField(
            label: 'Email',
            hintText: 'you@example.com',
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            errorText: _emailError,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            onChanged: (_) => setState(() {
              _formError = null;
              _formInfo = null;
            }),
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Password',
            hintText: 'Enter your password',
            controller: _password,
            obscureText: _obscure,
            errorText: _passwordError,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            onChanged: (_) => setState(() {}),
            suffixIcon: IconButton(
              tooltip: _obscure ? 'Show password' : 'Hide password',
              icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
          if (!_isSignUp)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: _forgotPassword, child: const Text('Forgot password?')),
            ),
          const SizedBox(height: AppSpacing.md),
          if (firstError == null && _formInfo != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md - 4),
              child: Text(
                _formInfo!,
                textAlign: TextAlign.center,
                style: text.labelSmall?.copyWith(color: AppColors.success),
              ),
            ),
          if (firstError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md - 4),
              child: Text(
                firstError,
                textAlign: TextAlign.center,
                style: text.labelSmall?.copyWith(color: AppColors.error),
              ),
            ),
          PrimaryButton(
            label: _isSignUp ? 'Create account' : 'Log in',
            isLoading: _submitting,
            onPressed: _submit,
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(foregroundColor: AppColors.onSurfaceVariant),
            child: const Text('Cancel'),
          ),
          if (!_isSignUp && AppScope.read(context).demoAccountEmail != null)
            Text(
              'Demo account: ${AppScope.read(context).demoAccountEmail}',
              textAlign: TextAlign.center,
              style: muted,
            ),
        ],
      ),
    );
  }
}
