import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:blood_donation_app/core/presentation/failure_ui.dart';
import 'package:blood_donation_app/core/presentation/widgets/message_banner.dart';
import 'package:blood_donation_app/core/time/clock_provider.dart';

import '../../domain/entities/auth_user.dart';
import '../notifiers/email_verification_notifier.dart';
import '../sign_out_action.dart';

/// Shown to a signed-in user whose email is not verified yet. Security
/// rules ignore unverified accounts, so the app must not go further.
class VerifyEmailPage extends ConsumerStatefulWidget {
  const VerifyEmailPage({required this.user, super.key});

  final AuthUser user;

  static const Key checkButtonKey = Key('verifyEmail.check');
  static const Key resendButtonKey = Key('verifyEmail.resend');
  static const Key signOutButtonKey = Key('verifyEmail.signOut');

  @override
  ConsumerState<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends ConsumerState<VerifyEmailPage> {
  /// Firebase rate-limits verification emails; this stops rapid re-taps
  /// from running into "too many requests".
  static const Duration _resendCooldown = Duration(seconds: 60);

  Timer? _ticker;
  DateTime? _resendAvailableAt;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  int get _secondsUntilResend {
    final availableAt = _resendAvailableAt;
    if (availableAt == null) return 0;
    final remaining = availableAt.difference(ref.read(clockProvider).now());
    return remaining.isNegative ? 0 : remaining.inSeconds + 1;
  }

  void _resend() {
    _resendAvailableAt = ref.read(clockProvider).now().add(_resendCooldown);
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _secondsUntilResend == 0) timer.cancel();
      if (mounted) setState(() {});
    });
    setState(() {});
    unawaited(ref.read(emailVerificationProvider.notifier).resend());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(emailVerificationProvider);
    final isLoading = state.isLoading;
    final failure = failureOf(state);
    final info = failure == null ? state.value : null;
    final secondsLeft = _secondsUntilResend;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.mark_email_unread_outlined,
                    size: 56,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Verify your email',
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'We sent a link to ${widget.user.email}. Open it, then '
                    'come back and tap the button below.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (failure != null) ...[
                    MessageBanner(message: failure.message),
                    const SizedBox(height: 16),
                  ] else if (info != null) ...[
                    MessageBanner(message: info, isError: false),
                    const SizedBox(height: 16),
                  ],
                  FilledButton(
                    key: VerifyEmailPage.checkButtonKey,
                    onPressed: isLoading
                        ? null
                        : () => unawaited(
                            ref
                                .read(emailVerificationProvider.notifier)
                                .check(),
                          ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text("I've verified my email"),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    key: VerifyEmailPage.resendButtonKey,
                    onPressed: isLoading || secondsLeft > 0 ? null : _resend,
                    child: Text(
                      secondsLeft > 0
                          ? 'Resend email in ${secondsLeft}s'
                          : 'Resend email',
                    ),
                  ),
                  TextButton(
                    key: VerifyEmailPage.signOutButtonKey,
                    onPressed: () =>
                        unawaited(signOutWithFeedback(context, ref)),
                    child: const Text('Use a different account'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
