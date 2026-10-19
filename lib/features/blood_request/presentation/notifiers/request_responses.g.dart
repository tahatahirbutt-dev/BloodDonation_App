// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_responses.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The donors who offered to help with [requestId] (requester's view).

@ProviderFor(requestResponses)
const requestResponsesProvider = RequestResponsesFamily._();

/// The donors who offered to help with [requestId] (requester's view).

final class RequestResponsesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DonorResponse>>,
          List<DonorResponse>,
          FutureOr<List<DonorResponse>>
        >
    with
        $FutureModifier<List<DonorResponse>>,
        $FutureProvider<List<DonorResponse>> {
  /// The donors who offered to help with [requestId] (requester's view).
  const RequestResponsesProvider._({
    required RequestResponsesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'requestResponsesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$requestResponsesHash();

  @override
  String toString() {
    return r'requestResponsesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<DonorResponse>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DonorResponse>> create(Ref ref) {
    final argument = this.argument as String;
    return requestResponses(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RequestResponsesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$requestResponsesHash() => r'bc8038bae9315a35dd312b2d5c6b11b3cebc0d76';

/// The donors who offered to help with [requestId] (requester's view).

final class RequestResponsesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<DonorResponse>>, String> {
  const RequestResponsesFamily._()
    : super(
        retry: null,
        name: r'requestResponsesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The donors who offered to help with [requestId] (requester's view).

  RequestResponsesProvider call(String requestId) =>
      RequestResponsesProvider._(argument: requestId, from: this);

  @override
  String toString() => r'requestResponsesProvider';
}
