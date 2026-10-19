// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_profile.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The signed-in user's profile. `null` data means "signed in but has not
/// completed profile setup yet", which the gate turns into the setup
/// screen. A failure becomes an `AsyncError` carrying the typed `Failure`
/// so the screen can show a real message and a retry button.

@ProviderFor(currentProfile)
const currentProfileProvider = CurrentProfileFamily._();

/// The signed-in user's profile. `null` data means "signed in but has not
/// completed profile setup yet", which the gate turns into the setup
/// screen. A failure becomes an `AsyncError` carrying the typed `Failure`
/// so the screen can show a real message and a retry button.

final class CurrentProfileProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserProfile?>,
          UserProfile?,
          FutureOr<UserProfile?>
        >
    with $FutureModifier<UserProfile?>, $FutureProvider<UserProfile?> {
  /// The signed-in user's profile. `null` data means "signed in but has not
  /// completed profile setup yet", which the gate turns into the setup
  /// screen. A failure becomes an `AsyncError` carrying the typed `Failure`
  /// so the screen can show a real message and a retry button.
  const CurrentProfileProvider._({
    required CurrentProfileFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'currentProfileProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$currentProfileHash();

  @override
  String toString() {
    return r'currentProfileProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<UserProfile?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<UserProfile?> create(Ref ref) {
    final argument = this.argument as String;
    return currentProfile(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CurrentProfileProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$currentProfileHash() => r'bd55cd59636b42116c7c0dacb1c6172eae6fe7a1';

/// The signed-in user's profile. `null` data means "signed in but has not
/// completed profile setup yet", which the gate turns into the setup
/// screen. A failure becomes an `AsyncError` carrying the typed `Failure`
/// so the screen can show a real message and a retry button.

final class CurrentProfileFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<UserProfile?>, String> {
  const CurrentProfileFamily._()
    : super(
        retry: null,
        name: r'currentProfileProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The signed-in user's profile. `null` data means "signed in but has not
  /// completed profile setup yet", which the gate turns into the setup
  /// screen. A failure becomes an `AsyncError` carrying the typed `Failure`
  /// so the screen can show a real message and a retry button.

  CurrentProfileProvider call(String uid) =>
      CurrentProfileProvider._(argument: uid, from: this);

  @override
  String toString() => r'currentProfileProvider';
}
