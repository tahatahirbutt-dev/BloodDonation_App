// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'email_verification_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives the "verify your email" screen. The data value is an optional
/// info message for the user (null = nothing to say).

@ProviderFor(EmailVerification)
const emailVerificationProvider = EmailVerificationProvider._();

/// Drives the "verify your email" screen. The data value is an optional
/// info message for the user (null = nothing to say).
final class EmailVerificationProvider
    extends $AsyncNotifierProvider<EmailVerification, String?> {
  /// Drives the "verify your email" screen. The data value is an optional
  /// info message for the user (null = nothing to say).
  const EmailVerificationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'emailVerificationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$emailVerificationHash();

  @$internal
  @override
  EmailVerification create() => EmailVerification();
}

String _$emailVerificationHash() => r'8544fa98e10d91fc4ad96d8fe331b501f9c0ba70';

/// Drives the "verify your email" screen. The data value is an optional
/// info message for the user (null = nothing to say).

abstract class _$EmailVerification extends $AsyncNotifier<String?> {
  FutureOr<String?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<String?>, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String?>, String?>,
              AsyncValue<String?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
