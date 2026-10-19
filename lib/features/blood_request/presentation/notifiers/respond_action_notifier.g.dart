// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'respond_action_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The donor's "I can help" and "withdraw" actions on one request.
/// Idle (`AsyncData`), working (`AsyncLoading`) or failed (`AsyncError`
/// with a typed `Failure`). On success the donor's stored response is
/// re-read so the detail page flips between its two states.

@ProviderFor(RespondAction)
const respondActionProvider = RespondActionFamily._();

/// The donor's "I can help" and "withdraw" actions on one request.
/// Idle (`AsyncData`), working (`AsyncLoading`) or failed (`AsyncError`
/// with a typed `Failure`). On success the donor's stored response is
/// re-read so the detail page flips between its two states.
final class RespondActionProvider
    extends $AsyncNotifierProvider<RespondAction, void> {
  /// The donor's "I can help" and "withdraw" actions on one request.
  /// Idle (`AsyncData`), working (`AsyncLoading`) or failed (`AsyncError`
  /// with a typed `Failure`). On success the donor's stored response is
  /// re-read so the detail page flips between its two states.
  const RespondActionProvider._({
    required RespondActionFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'respondActionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$respondActionHash();

  @override
  String toString() {
    return r'respondActionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  RespondAction create() => RespondAction();

  @override
  bool operator ==(Object other) {
    return other is RespondActionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$respondActionHash() => r'e0794b783b0acf04115000d248f4e22ba21d2387';

/// The donor's "I can help" and "withdraw" actions on one request.
/// Idle (`AsyncData`), working (`AsyncLoading`) or failed (`AsyncError`
/// with a typed `Failure`). On success the donor's stored response is
/// re-read so the detail page flips between its two states.

final class RespondActionFamily extends $Family
    with
        $ClassFamilyOverride<
          RespondAction,
          AsyncValue<void>,
          void,
          FutureOr<void>,
          String
        > {
  const RespondActionFamily._()
    : super(
        retry: null,
        name: r'respondActionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The donor's "I can help" and "withdraw" actions on one request.
  /// Idle (`AsyncData`), working (`AsyncLoading`) or failed (`AsyncError`
  /// with a typed `Failure`). On success the donor's stored response is
  /// re-read so the detail page flips between its two states.

  RespondActionProvider call(String requestId) =>
      RespondActionProvider._(argument: requestId, from: this);

  @override
  String toString() => r'respondActionProvider';
}

/// The donor's "I can help" and "withdraw" actions on one request.
/// Idle (`AsyncData`), working (`AsyncLoading`) or failed (`AsyncError`
/// with a typed `Failure`). On success the donor's stored response is
/// re-read so the detail page flips between its two states.

abstract class _$RespondAction extends $AsyncNotifier<void> {
  late final _$args = ref.$arg as String;
  String get requestId => _$args;

  FutureOr<void> build(String requestId);
  @$mustCallSuper
  @override
  void runBuild() {
    build(_$args);
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
