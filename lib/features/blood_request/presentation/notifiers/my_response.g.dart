// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_response.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// This donor's own response to [requestId]; `null` data = none yet.

@ProviderFor(myResponse)
const myResponseProvider = MyResponseFamily._();

/// This donor's own response to [requestId]; `null` data = none yet.

final class MyResponseProvider
    extends
        $FunctionalProvider<
          AsyncValue<DonorResponse?>,
          DonorResponse?,
          FutureOr<DonorResponse?>
        >
    with $FutureModifier<DonorResponse?>, $FutureProvider<DonorResponse?> {
  /// This donor's own response to [requestId]; `null` data = none yet.
  const MyResponseProvider._({
    required MyResponseFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'myResponseProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$myResponseHash();

  @override
  String toString() {
    return r'myResponseProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<DonorResponse?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DonorResponse?> create(Ref ref) {
    final argument = this.argument as (String, String);
    return myResponse(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is MyResponseProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$myResponseHash() => r'dd12e95c6d50b3a1f683317217dec04791598aac';

/// This donor's own response to [requestId]; `null` data = none yet.

final class MyResponseFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<DonorResponse?>, (String, String)> {
  const MyResponseFamily._()
    : super(
        retry: null,
        name: r'myResponseProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// This donor's own response to [requestId]; `null` data = none yet.

  MyResponseProvider call(String requestId, String donorUid) =>
      MyResponseProvider._(argument: (requestId, donorUid), from: this);

  @override
  String toString() => r'myResponseProvider';
}
