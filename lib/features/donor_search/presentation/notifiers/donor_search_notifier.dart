import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/blood_group.dart';

import '../../domain/entities/donor_search_result.dart';
import '../../donor_search_providers.dart';

part 'donor_search_notifier.g.dart';

/// State of the donor-search tab. `AsyncData(null)` = no search run yet,
/// `AsyncLoading` = searching, `AsyncData(result)` = done, `AsyncError`
/// = a typed `Failure`.
@riverpod
class DonorSearch extends _$DonorSearch {
  @override
  FutureOr<DonorSearchResult?> build() => null;

  Future<void> search({
    required BloodGroup recipientGroup,
    required String centerLocationId,
    required double radiusKm,
    required String excludeUid,
  }) async {
    state = const AsyncLoading<DonorSearchResult?>();
    final result = await ref
        .read(searchDonorsProvider)
        .call(
          recipientGroup: recipientGroup,
          centerLocationId: centerLocationId,
          radiusKm: radiusKm,
          excludeUid: excludeUid,
        );
    // The user may have left the tab while the search was in flight.
    if (!ref.mounted) return;
    state = switch (result) {
      Success<DonorSearchResult>(:final value) => AsyncData<DonorSearchResult?>(
        value,
      ),
      Err<DonorSearchResult>(:final failure) => AsyncError<DonorSearchResult?>(
        failure,
        StackTrace.current,
      ),
    };
  }
}
