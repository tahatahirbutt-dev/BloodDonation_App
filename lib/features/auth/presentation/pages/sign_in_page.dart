import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:blood_donation_app/core/presentation/failure_ui.dart';
import 'package:blood_donation_app/core/presentation/widgets/message_banner.dart';

import '../notifiers/auth_form_notifier.dart';
import '../notifiers/password_reset_notifier.dart';

/// One screen for both "Sign in" and "Create account". All validation
/// lives in the use cases; this widget only shows what they report, under
/// the right field.
class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  static const Key emailFieldKey = Key('signIn.email');
  static const Key passwordFieldKey = Key('signIn.password');
  static const Key confirmPasswordFieldKey = Key('signIn.confirmPassword');
  static const Key submitButtonKey = Key('signIn.submit');
  static const Key toggleModeButtonKey = Key('signIn.toggleMode');
  static const Key forgotPasswordButtonKey = Key('signIn.forgotPassword');

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  static const Set<String> _inlineFields = {
    'email',
    'password',
    'confirmPassword',
  };

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  bool _isSignUp = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    final form = ref.read(authFormProvider.notifier);
    if (_isSignUp) {
      unawaited(
        form.signUp(
          email: _email.text,
          password: _password.text,
          confirmPassword: _confirmPassword.text,
        ),
      );
    } else {
      unawaited(form.signIn(email: _email.text, password: _password.text));
    }
  }

  void _toggleMode() {
    setState(() => _isSignUp = !_isSignUp);
    // Errors from one mode make no sense in the other.
    ref.invalidate(authFormProvider);
  }

  Future<void> _openForgotPassword() {
    return showDialog<void>(
      context: context,
      builder: (_) => _ForgotPasswordDialog(initialEmail: _email.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authFormProvider);
    final isLoading = state.isLoading;
    final failure = failureOf(state);
    final banner = bannerFailure(failure, _inlineFields);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.bloodtype,
                      size: 56,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isSignUp ? 'Create your account' : 'Welcome back',
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    if (banner != null) ...[
                      MessageBanner(message: banner.message),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      key: SignInPage.emailFieldKey,
                      controller: _email,
                      enabled: !isLoading,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: const OutlineInputBorder(),
                        errorText: fieldErrorFor(failure, 'email'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: SignInPage.passwordFieldKey,
                      controller: _password,
                      enabled: !isLoading,
                      obscureText: _obscurePassword,
                      textInputAction: _isSignUp
                          ? TextInputAction.next
                          : TextInputAction.done,
                      autofillHints: [
                        _isSignUp
                            ? AutofillHints.newPassword
                            : AutofillHints.password,
                      ],
                      onFieldSubmitted: (_) {
                        if (!_isSignUp && !isLoading) _submit();
                      },
                      decoration: InputDecoration(
                        labelText: 'Password',
                        helperText: _isSignUp
                            ? 'At least 8 characters, with a letter and a number.'
                            : null,
                        border: const OutlineInputBorder(),
                        errorText: fieldErrorFor(failure, 'password'),
                        suffixIcon: IconButton(
                          tooltip: _obscurePassword
                              ? 'Show password'
                              : 'Hide password',
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                    ),
                    if (_isSignUp) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        key: SignInPage.confirmPasswordFieldKey,
                        controller: _confirmPassword,
                        enabled: !isLoading,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.newPassword],
                        decoration: InputDecoration(
                          labelText: 'Confirm password',
                          border: const OutlineInputBorder(),
                          errorText: fieldErrorFor(failure, 'confirmPassword'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      key: SignInPage.submitButtonKey,
                      onPressed: isLoading ? null : _submit,
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_isSignUp ? 'Create account' : 'Sign in'),
                    ),
                    const SizedBox(height: 8),
                    if (!_isSignUp)
                      TextButton(
                        key: SignInPage.forgotPasswordButtonKey,
                        onPressed: isLoading ? null : _openForgotPassword,
                        child: const Text('Forgot password?'),
                      ),
                    TextButton(
                      key: SignInPage.toggleModeButtonKey,
                      onPressed: isLoading ? null : _toggleMode,
                      child: Text(
                        _isSignUp
                            ? 'Already have an account? Sign in'
                            : 'New here? Create an account',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ForgotPasswordDialog extends ConsumerStatefulWidget {
  const _ForgotPasswordDialog({required this.initialEmail});

  final String initialEmail;

  @override
  ConsumerState<_ForgotPasswordDialog> createState() =>
      _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends ConsumerState<_ForgotPasswordDialog> {
  static const Key emailFieldKey = Key('forgotPassword.email');

  late final TextEditingController _email = TextEditingController(
    text: widget.initialEmail,
  );

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(passwordResetProvider);
    final sent = state.value ?? false;
    final isLoading = state.isLoading;
    final failure = failureOf(state);
    final banner = bannerFailure(failure, const {'email'});

    return AlertDialog(
      title: const Text('Reset password'),
      content: sent
          ? const Text(
              'If an account exists for that address, a reset link is on its '
              'way. Check your inbox and spam folder.',
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (banner != null) ...[
                  MessageBanner(message: banner.message),
                  const SizedBox(height: 12),
                ],
                TextField(
                  key: emailFieldKey,
                  controller: _email,
                  enabled: !isLoading,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: const OutlineInputBorder(),
                    errorText: fieldErrorFor(failure, 'email'),
                  ),
                ),
              ],
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(sent ? 'Close' : 'Cancel'),
        ),
        if (!sent)
          FilledButton(
            onPressed: isLoading
                ? null
                : () => unawaited(
                    ref.read(passwordResetProvider.notifier).send(_email.text),
                  ),
            child: isLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Send link'),
          ),
      ],
    );
  }
}
