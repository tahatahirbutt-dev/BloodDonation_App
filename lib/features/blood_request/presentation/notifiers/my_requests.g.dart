// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_requests.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Everything [uid] has posted, newest first.

@ProviderFor(myRequests)
const myRequestsProvider = MyRequestsFamily._();

/// Everything [uid] has posted, newest first.

final class MyRequestsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BloodRequest>>,
          List<BloodRequest>,
          FutureOr<List<BloodRequest>>
        >
    with
        $FutureModifier<List<BloodRequest>>,
        $FutureProvider<List<BloodRequest>> {
  /// Everything [uid] has posted, newest first.
  const MyRequestsProvider._({
    required MyRequestsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'myRequestsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$myRequestsHash();

  @override
  String toString() {
    return r'myRequestsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<BloodRequest>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BloodRequest>> create(Ref ref) {
    final argument = this.argument as String;
    return myRequests(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MyRequestsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$myRequestsHash() => r'2ff37f263a1708ebcff8adbcf77e1f0d3b25d021';

/// Everything [uid] has posted, newest first.

final class MyRequestsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<BloodRequest>>, String> {
  const MyRequestsFamily._()
    : super(
        retry: null,
        name: r'myRequestsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Everything [uid] has posted, newest first.

  MyRequestsProvider call(String uid) =>
      MyRequestsProvider._(argument: uid, from: this);

  @override
  String toString() => r'myRequestsProvider';
}
