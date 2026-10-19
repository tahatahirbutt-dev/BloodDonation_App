// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'close_request_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The requester marking their request fulfilled or cancelled.

@ProviderFor(CloseRequest)
const closeRequestProvider = CloseRequestProvider._();

/// The requester marking their request fulfilled or cancelled.
final class CloseRequestProvider
    extends $AsyncNotifierProvider<CloseRequest, void> {
  /// The requester marking their request fulfilled or cancelled.
  const CloseRequestProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'closeRequestProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$closeRequestHash();

  @$internal
  @override
  CloseRequest create() => CloseRequest();
}

String _$closeRequestHash() => r'5e805dd9395401ec9b25b2cd0797398b749540f2';

/// The requester marking their request fulfilled or cancelled.

abstract class _$CloseRequest extends $AsyncNotifier<void> {
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
