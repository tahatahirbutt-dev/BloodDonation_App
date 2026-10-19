// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_request_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// State of the "post a request" form: idle (`AsyncData`), posting
/// (`AsyncLoading`) or failed (`AsyncError` carrying a typed `Failure`,
/// possibly a `ValidationFailure` naming the field to highlight).

@ProviderFor(PostRequest)
const postRequestProvider = PostRequestProvider._();

/// State of the "post a request" form: idle (`AsyncData`), posting
/// (`AsyncLoading`) or failed (`AsyncError` carrying a typed `Failure`,
/// possibly a `ValidationFailure` naming the field to highlight).
final class PostRequestProvider
    extends $AsyncNotifierProvider<PostRequest, void> {
  /// State of the "post a request" form: idle (`AsyncData`), posting
  /// (`AsyncLoading`) or failed (`AsyncError` carrying a typed `Failure`,
  /// possibly a `ValidationFailure` naming the field to highlight).
  const PostRequestProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'postRequestProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$postRequestHash();

  @$internal
  @override
  PostRequest create() => PostRequest();
}

String _$postRequestHash() => r'9c04f2a0c867035ca67132d9ff2ea771e8979a2b';

/// State of the "post a request" form: idle (`AsyncData`), posting
/// (`AsyncLoading`) or failed (`AsyncError` carrying a typed `Failure`,
/// possibly a `ValidationFailure` naming the field to highlight).

abstract class _$PostRequest extends $AsyncNotifier<void> {
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
