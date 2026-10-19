import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/core/presentation/failure_ui.dart';

import '../../blood_request_providers.dart';
import '../../domain/entities/blood_request.dart';
import '../../domain/usecases/post_blood_request.dart';
import 'my_requests.dart';

part 'post_request_notifier.g.dart';

/// State of the "post a request" form: idle (`AsyncData`), posting
/// (`AsyncLoading`) or failed (`AsyncError` carrying a typed `Failure`,
/// possibly a `ValidationFailure` naming the field to highlight).
@riverpod
class PostRequest extends _$PostRequest {
  @override
  FutureOr<void> build() {}

  /// Returns true only when the request was saved, so the page knows it
  /// may close itself.
  Future<bool> submit(PostBloodRequestParams params) async {
    state = const AsyncLoading<void>();
    final result = await ref.read(postBloodRequestProvider).call(params);
    // The user may have left the screen while the post was in flight.
    if (!ref.mounted) return false;
    state = asyncVoidFromResult(result);
    if (result is Success<BloodRequest>) {
      ref.invalidate(myRequestsProvider(params.requesterUid));
      return true;
    }
    return false;
  }
}
