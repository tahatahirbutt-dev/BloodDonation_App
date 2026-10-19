// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nearby_requests.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The donor's feed. A failure becomes an `AsyncError` carrying the typed
/// `Failure`, so the screen can show a real message and a retry button.
/// Keyed by the profile, so changing availability or blood group
/// naturally produces a fresh feed.

@ProviderFor(nearbyRequests)
const nearbyRequestsProvider = NearbyRequestsFamily._();

/// The donor's feed. A failure becomes an `AsyncError` carrying the typed
/// `Failure`, so the screen can show a real message and a retry button.
/// Keyed by the profile, so changing availability or blood group
/// naturally produces a fresh feed.

final class NearbyRequestsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RequestFeedItem>>,
          List<RequestFeedItem>,
          FutureOr<List<RequestFeedItem>>
        >
    with
        $FutureModifier<List<RequestFeedItem>>,
        $FutureProvider<List<RequestFeedItem>> {
  /// The donor's feed. A failure becomes an `AsyncError` carrying the typed
  /// `Failure`, so the screen can show a real message and a retry button.
  /// Keyed by the profile, so changing availability or blood group
  /// naturally produces a fresh feed.
  const NearbyRequestsProvider._({
    required NearbyRequestsFamily super.from,
    required UserProfile super.argument,
  }) : super(
         retry: null,
         name: r'nearbyRequestsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$nearbyRequestsHash();

  @override
  String toString() {
    return r'nearbyRequestsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<RequestFeedItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<RequestFeedItem>> create(Ref ref) {
    final argument = this.argument as UserProfile;
    return nearbyRequests(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is NearbyRequestsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$nearbyRequestsHash() => r'ca1e0166398a13e7249923997485e2bacf0c51af';

/// The donor's feed. A failure becomes an `AsyncError` carrying the typed
/// `Failure`, so the screen can show a real message and a retry button.
/// Keyed by the profile, so changing availability or blood group
/// naturally produces a fresh feed.

final class NearbyRequestsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<RequestFeedItem>>,
          UserProfile
        > {
  const NearbyRequestsFamily._()
    : super(
        retry: null,
        name: r'nearbyRequestsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The donor's feed. A failure becomes an `AsyncError` carrying the typed
  /// `Failure`, so the screen can show a real message and a retry button.
  /// Keyed by the profile, so changing availability or blood group
  /// naturally produces a fresh feed.

  NearbyRequestsProvider call(UserProfile donor) =>
      NearbyRequestsProvider._(argument: donor, from: this);

  @override
  String toString() => r'nearbyRequestsProvider';
}
