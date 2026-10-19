// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_setup_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// State of the profile form: idle (`AsyncData`), saving (`AsyncLoading`)
/// or failed (`AsyncError` carrying a typed `Failure`, possibly a
/// `ValidationFailure` that names the field to highlight).

@ProviderFor(ProfileSetup)
const profileSetupProvider = ProfileSetupProvider._();

/// State of the profile form: idle (`AsyncData`), saving (`AsyncLoading`)
/// or failed (`AsyncError` carrying a typed `Failure`, possibly a
/// `ValidationFailure` that names the field to highlight).
final class ProfileSetupProvider
    extends $AsyncNotifierProvider<ProfileSetup, void> {
  /// State of the profile form: idle (`AsyncData`), saving (`AsyncLoading`)
  /// or failed (`AsyncError` carrying a typed `Failure`, possibly a
  /// `ValidationFailure` that names the field to highlight).
  const ProfileSetupProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileSetupProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileSetupHash();

  @$internal
  @override
  ProfileSetup create() => ProfileSetup();
}

String _$profileSetupHash() => r'137bba000d22b0c392c04d2269a8a956f6320210';

/// State of the profile form: idle (`AsyncData`), saving (`AsyncLoading`)
/// or failed (`AsyncError` carrying a typed `Failure`, possibly a
/// `ValidationFailure` that names the field to highlight).

abstract class _$ProfileSetup extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
