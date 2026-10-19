import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:blood_donation_app/core/presentation/date_format.dart';
import 'package:blood_donation_app/core/presentation/failure_ui.dart';
import 'package:blood_donation_app/core/presentation/widgets/empty_view.dart';
import 'package:blood_donation_app/core/presentation/widgets/inline_error_view.dart';
import 'package:blood_donation_app/core/presentation/widgets/inline_loading_view.dart';
import 'package:blood_donation_app/core/presentation/widgets/message_banner.dart';
import 'package:blood_donation_app/core/time/clock_provider.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/donation_eligibility.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/user_profile.dart';

import '../../domain/entities/request_feed_item.dart';
import '../notifiers/nearby_requests.dart';
import '../widgets/request_card.dart';
import 'request_detail_page.dart';

/// The donor's feed: open requests their blood could go to, most urgent
/// then nearest first. Loading, error (with retry) and empty states are
/// all explicit, and pulling down refreshes.
class RequestFeedTab extends ConsumerWidget {
  const RequestFeedTab({required this.profile, super.key});

  final UserProfile profile;

  static const Key listKey = Key('requestFeed.list');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(nearbyRequestsProvider(profile));

    return feed.when(
      skipLoadingOnReload: true,
      skipLoadingOnRefresh: true,
      loading: () => const InlineLoadingView(message: 'Looking for requests…'),
      error: (error, _) => InlineErrorView(
        failure: failureFromError(error),
        onRetry: () => ref.invalidate(nearbyRequestsProvider(profile)),
      ),
      data: (items) {
        final notice = _donorNotice(ref.watch(clockProvider).now());
        return RefreshIndicator(
          onRefresh: () => _refresh(ref),
          child: ListView(
            key: listKey,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              if (notice != null) ...[
                MessageBanner(message: notice, isError: false),
                const SizedBox(height: 12),
              ],
              if (items.isEmpty)
                const EmptyView(
                  icon: Icons.bloodtype_outlined,
                  title: 'No blood requests yet',
                  message:
                      'Requests that match your blood group will appear '
                      'here. Pull down to refresh.',
                )
              else
                for (final item in items)
                  RequestCard(
                    request: item.request,
                    distanceKm: item.distanceKm,
                    onTap: () => _open(context, item),
                  ),
            ],
          ),
        );
      },
    );
  }

  /// Why this donor cannot respond right now, if anything. They can still
  /// read the feed and pass requests on.
  String? _donorNotice(DateTime now) {
    if (!profile.isAvailable) {
      return 'You are set as unavailable, so you cannot respond to requests. '
          'Turn availability on in the Profile tab.';
    }
    return switch (profile.eligibilityAt(now)) {
      NotYetEligible(:final nextEligibleDate, :final daysRemaining) =>
        'You can donate again on ${formatDate(nextEligibleDate)} '
            '($daysRemaining days). You can still see requests.',
      EligibleToDonate() => null,
    };
  }

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(nearbyRequestsProvider(profile));
    try {
      await ref.read(nearbyRequestsProvider(profile).future);
    } catch (_) {
      // The error state above shows the failure; nothing more to do here.
    }
  }

  void _open(BuildContext context, RequestFeedItem item) {
    unawaited(
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => RequestDetailPage(
            request: item.request,
            donor: profile,
            distanceKm: item.distanceKm,
          ),
        ),
      ),
    );
  }
}
