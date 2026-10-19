// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blood_request_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// No default on purpose: `bootstrap()` overrides it with the Firestore
/// implementation and tests override it with the in-memory one. Forgetting
/// fails loudly at startup instead of silently using the wrong store.

@ProviderFor(bloodRequestRemoteDataSource)
const bloodRequestRemoteDataSourceProvider =
    BloodRequestRemoteDataSourceProvider._();

/// No default on purpose: `bootstrap()` overrides it with the Firestore
/// implementation and tests override it with the in-memory one. Forgetting
/// fails loudly at startup instead of silently using the wrong store.

final class BloodRequestRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          BloodRequestRemoteDataSource,
          BloodRequestRemoteDataSource,
          BloodRequestRemoteDataSource
        >
    with $Provider<BloodRequestRemoteDataSource> {
  /// No default on purpose: `bootstrap()` overrides it with the Firestore
  /// implementation and tests override it with the in-memory one. Forgetting
  /// fails loudly at startup instead of silently using the wrong store.
  const BloodRequestRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bloodRequestRemoteDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bloodRequestRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<BloodRequestRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BloodRequestRemoteDataSource create(Ref ref) {
    return bloodRequestRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BloodRequestRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BloodRequestRemoteDataSource>(value),
    );
  }
}

String _$bloodRequestRemoteDataSourceHash() =>
    r'a67a8f7909593ad1aab932cbd48fe5d05b1203d4';

@ProviderFor(requestResponseRemoteDataSource)
const requestResponseRemoteDataSourceProvider =
    RequestResponseRemoteDataSourceProvider._();

final class RequestResponseRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          RequestResponseRemoteDataSource,
          RequestResponseRemoteDataSource,
          RequestResponseRemoteDataSource
        >
    with $Provider<RequestResponseRemoteDataSource> {
  const RequestResponseRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'requestResponseRemoteDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$requestResponseRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<RequestResponseRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RequestResponseRemoteDataSource create(Ref ref) {
    return requestResponseRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RequestResponseRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RequestResponseRemoteDataSource>(
        value,
      ),
    );
  }
}

String _$requestResponseRemoteDataSourceHash() =>
    r'e77606b69b0ee7cb96f8be6bfe52d08f19967dbc';

@ProviderFor(bloodRequestRepository)
const bloodRequestRepositoryProvider = BloodRequestRepositoryProvider._();

final class BloodRequestRepositoryProvider
    extends
        $FunctionalProvider<
          BloodRequestRepository,
          BloodRequestRepository,
          BloodRequestRepository
        >
    with $Provider<BloodRequestRepository> {
  const BloodRequestRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bloodRequestRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bloodRequestRepositoryHash();

  @$internal
  @override
  $ProviderElement<BloodRequestRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BloodRequestRepository create(Ref ref) {
    return bloodRequestRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BloodRequestRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BloodRequestRepository>(value),
    );
  }
}

String _$bloodRequestRepositoryHash() =>
    r'4fa22c56ce81424f3bb93a284304dcfe75cf3934';

@ProviderFor(requestResponseRepository)
const requestResponseRepositoryProvider = RequestResponseRepositoryProvider._();

final class RequestResponseRepositoryProvider
    extends
        $FunctionalProvider<
          RequestResponseRepository,
          RequestResponseRepository,
          RequestResponseRepository
        >
    with $Provider<RequestResponseRepository> {
  const RequestResponseRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'requestResponseRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$requestResponseRepositoryHash();

  @$internal
  @override
  $ProviderElement<RequestResponseRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RequestResponseRepository create(Ref ref) {
    return requestResponseRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RequestResponseRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RequestResponseRepository>(value),
    );
  }
}

String _$requestResponseRepositoryHash() =>
    r'17e447e6bbccab9a2c6380f59d70e1b2ee16dcd7';

@ProviderFor(postBloodRequest)
const postBloodRequestProvider = PostBloodRequestProvider._();

final class PostBloodRequestProvider
    extends
        $FunctionalProvider<
          PostBloodRequest,
          PostBloodRequest,
          PostBloodRequest
        >
    with $Provider<PostBloodRequest> {
  const PostBloodRequestProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'postBloodRequestProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$postBloodRequestHash();

  @$internal
  @override
  $ProviderElement<PostBloodRequest> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PostBloodRequest create(Ref ref) {
    return postBloodRequest(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PostBloodRequest value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PostBloodRequest>(value),
    );
  }
}

String _$postBloodRequestHash() => r'f8d1299804a2e320a7db0d666b47eba87540f33a';

@ProviderFor(getNearbyRequests)
const getNearbyRequestsProvider = GetNearbyRequestsProvider._();

final class GetNearbyRequestsProvider
    extends
        $FunctionalProvider<
          GetNearbyRequests,
          GetNearbyRequests,
          GetNearbyRequests
        >
    with $Provider<GetNearbyRequests> {
  const GetNearbyRequestsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getNearbyRequestsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getNearbyRequestsHash();

  @$internal
  @override
  $ProviderElement<GetNearbyRequests> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetNearbyRequests create(Ref ref) {
    return getNearbyRequests(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetNearbyRequests value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetNearbyRequests>(value),
    );
  }
}

String _$getNearbyRequestsHash() => r'5b931e73aa810cc0e67e1cdeb60d59a05b15a347';

@ProviderFor(getMyRequests)
const getMyRequestsProvider = GetMyRequestsProvider._();

final class GetMyRequestsProvider
    extends $FunctionalProvider<GetMyRequests, GetMyRequests, GetMyRequests>
    with $Provider<GetMyRequests> {
  const GetMyRequestsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getMyRequestsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getMyRequestsHash();

  @$internal
  @override
  $ProviderElement<GetMyRequests> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetMyRequests create(Ref ref) {
    return getMyRequests(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetMyRequests value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetMyRequests>(value),
    );
  }
}

String _$getMyRequestsHash() => r'964bb4a0b549f344f6bae0460deb767ef26ba186';

@ProviderFor(closeBloodRequest)
const closeBloodRequestProvider = CloseBloodRequestProvider._();

final class CloseBloodRequestProvider
    extends
        $FunctionalProvider<
          CloseBloodRequest,
          CloseBloodRequest,
          CloseBloodRequest
        >
    with $Provider<CloseBloodRequest> {
  const CloseBloodRequestProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'closeBloodRequestProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$closeBloodRequestHash();

  @$internal
  @override
  $ProviderElement<CloseBloodRequest> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CloseBloodRequest create(Ref ref) {
    return closeBloodRequest(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CloseBloodRequest value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CloseBloodRequest>(value),
    );
  }
}

String _$closeBloodRequestHash() => r'fffdb3a7be7e0b712c93a9bcc8c5f297e1f9e150';

@ProviderFor(respondToRequest)
const respondToRequestProvider = RespondToRequestProvider._();

final class RespondToRequestProvider
    extends
        $FunctionalProvider<
          RespondToRequest,
          RespondToRequest,
          RespondToRequest
        >
    with $Provider<RespondToRequest> {
  const RespondToRequestProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'respondToRequestProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$respondToRequestHash();

  @$internal
  @override
  $ProviderElement<RespondToRequest> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RespondToRequest create(Ref ref) {
    return respondToRequest(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RespondToRequest value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RespondToRequest>(value),
    );
  }
}

String _$respondToRequestHash() => r'129b8e5d68f680d8a2192ec9c7a4ab222007ecc5';

@ProviderFor(withdrawResponse)
const withdrawResponseProvider = WithdrawResponseProvider._();

final class WithdrawResponseProvider
    extends
        $FunctionalProvider<
          WithdrawResponse,
          WithdrawResponse,
          WithdrawResponse
        >
    with $Provider<WithdrawResponse> {
  const WithdrawResponseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'withdrawResponseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$withdrawResponseHash();

  @$internal
  @override
  $ProviderElement<WithdrawResponse> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WithdrawResponse create(Ref ref) {
    return withdrawResponse(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WithdrawResponse value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WithdrawResponse>(value),
    );
  }
}

String _$withdrawResponseHash() => r'4e12f0b5e559b19d20b174f17f077cc9a876a8aa';

@ProviderFor(getMyResponse)
const getMyResponseProvider = GetMyResponseProvider._();

final class GetMyResponseProvider
    extends $FunctionalProvider<GetMyResponse, GetMyResponse, GetMyResponse>
    with $Provider<GetMyResponse> {
  const GetMyResponseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getMyResponseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getMyResponseHash();

  @$internal
  @override
  $ProviderElement<GetMyResponse> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetMyResponse create(Ref ref) {
    return getMyResponse(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetMyResponse value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetMyResponse>(value),
    );
  }
}

String _$getMyResponseHash() => r'aa02036025caca73856132064be105af754191c3';

@ProviderFor(getRequestResponses)
const getRequestResponsesProvider = GetRequestResponsesProvider._();

final class GetRequestResponsesProvider
    extends
        $FunctionalProvider<
          GetRequestResponses,
          GetRequestResponses,
          GetRequestResponses
        >
    with $Provider<GetRequestResponses> {
  const GetRequestResponsesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getRequestResponsesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getRequestResponsesHash();

  @$internal
  @override
  $ProviderElement<GetRequestResponses> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetRequestResponses create(Ref ref) {
    return getRequestResponses(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetRequestResponses value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetRequestResponses>(value),
    );
  }
}

String _$getRequestResponsesHash() =>
    r'e84fa7bff9aed3cb56b872da09ce1e72e2b37335';
