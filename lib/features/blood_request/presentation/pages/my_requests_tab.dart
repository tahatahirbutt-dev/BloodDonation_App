import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:blood_donation_app/core/presentation/failure_ui.dart';
import 'package:blood_donation_app/core/presentation/widgets/empty_view.dart';
import 'package:blood_donation_app/core/presentation/widgets/inline_error_view.dart';
import 'package:blood_donation_app/core/presentation/widgets/inline_loading_view.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/user_profile.dart';

import '../../domain/entities/blood_request.dart';
import '../notifiers/my_requests.dart';
import '../widgets/request_card.dart';
import 'my_request_detail_page.dart';

/// Requests the signed-in user has posted, newest first.
class MyRequestsTab extends ConsumerWidget {
  const MyRequestsTab({required this.profile, super.key});

  final UserProfile profile;

  static const Key listKey = Key('myRequests.list');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(myRequestsProvider(profile.uid));

    return requests.when(
      skipLoadingOnReload: true,
      skipLoadingOnRefresh: true,
      loading: () => const InlineLoadingView(message: 'Loading your requests…'),
      error: (error, _) => InlineErrorView(
        failure: failureFromError(error),
        onRetry: () => ref.invalidate(myRequestsProvider(profile.uid)),
      ),
      data: (items) => RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: ListView(
          key: listKey,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            if (items.isEmpty)
              const EmptyView(
                icon: Icons.inbox_outlined,
                title: 'You have not posted any requests',
                message: 'Tap "Request blood" to ask nearby donors for help.',
              )
            else
              for (final request in items)
                RequestCard(
                  request: request,
                  showStatus: true,
                  onTap: () => _open(context, request),
                ),
          ],
        ),
      ),
    );
  }

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(myRequestsProvider(profile.uid));
    try {
      await ref.read(myRequestsProvider(profile.uid).future);
    } catch (_) {
      // The error state above shows the failure; nothing more to do here.
    }
  }

  void _open(BuildContext context, BloodRequest request) {
    unawaited(
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => MyRequestDetailPage(request: request),
        ),
      ),
    );
  }
}
