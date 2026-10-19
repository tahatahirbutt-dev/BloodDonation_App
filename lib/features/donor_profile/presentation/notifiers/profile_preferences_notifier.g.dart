// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_preferences_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The two switches on the profile tab: "available to donate" and
/// "show me in donor search". Saves through the same `SaveUserProfile`
/// use case as the setup form, so there is still one set of rules. Idle
/// (`AsyncData`), saving (`AsyncLoading`) or failed (`AsyncError` with a
/// typed `Failure`).

@ProviderFor(ProfilePreferences)
const profilePreferencesProvider = ProfilePreferencesProvider._();

/// The two switches on the profile tab: "available to donate" and
/// "show me in donor search". Saves through the same `SaveUserProfile`
/// use case as the setup form, so there is still one set of rules. Idle
/// (`AsyncData`), saving (`AsyncLoading`) or failed (`AsyncError` with a
/// typed `Failure`).
final class ProfilePreferencesProvider
    extends $AsyncNotifierProvider<ProfilePreferences, void> {
  /// The two switches on the profile tab: "available to donate" and
  /// "show me in donor search". Saves through the same `SaveUserProfile`
  /// use case as the setup form, so there is still one set of rules. Idle
  /// (`AsyncData`), saving (`AsyncLoading`) or failed (`AsyncError` with a
  /// typed `Failure`).
  const ProfilePreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profilePreferencesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profilePreferencesHash();

  @$internal
  @override
  ProfilePreferences create() => ProfilePreferences();
}

String _$profilePreferencesHash() =>
    r'c3e9f5820ce4035e583612a9b630b629cd35960f';

/// The two switches on the profile tab: "available to donate" and
/// "show me in donor search". Saves through the same `SaveUserProfile`
/// use case as the setup form, so there is still one set of rules. Idle
/// (`AsyncData`), saving (`AsyncLoading`) or failed (`AsyncError` with a
/// typed `Failure`).

abstract class _$ProfilePreferences extends $AsyncNotifier<void> {
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
