import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:blood_donation_app/core/presentation/failure_ui.dart';
import 'package:blood_donation_app/core/presentation/widgets/message_banner.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/user_profile.dart';

import '../../blood_request_providers.dart';
import '../../domain/entities/blood_request.dart';
import '../notifiers/my_response.dart';
import '../notifiers/respond_action_notifier.dart';
import '../widgets/request_details_card.dart';

/// A donor's view of one request, with the "I can help" action.
///
/// The donor's phone number leaves their private profile only here, and
/// only after an explicit confirmation naming the number and who will see
/// it.
class RequestDetailPage extends StatelessWidget {
  const RequestDetailPage({
    required this.request,
    required this.donor,
    this.distanceKm,
    super.key,
  });

  final BloodRequest request;
  final UserProfile donor;
  final double? distanceKm;

  static const Key respondButtonKey = Key('requestDetail.respond');
  static const Key confirmShareKey = Key('requestDetail.confirmShare');
  static const Key cancelShareKey = Key('requestDetail.cancelShare');
  static const Key withdrawButtonKey = Key('requestDetail.withdraw');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Blood request')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            RequestDetailsCard(request: request, distanceKm: distanceKm),
            const SizedBox(height: 16),
            _RespondSection(request: request, donor: donor),
            const SizedBox(height: 24),
            const Text(
              'The blood bank always makes the final decision on whether you '
              'can donate. In an emergency, call Rescue 1122.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _RespondSection extends ConsumerWidget {
  const _RespondSection({required this.request, required this.donor});

  final BloodRequest request;
  final UserProfile donor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stored = ref.watch(myResponseProvider(request.id, donor.uid));
    final action = ref.watch(respondActionProvider(request.id));

    return stored.when(
      skipLoadingOnReload: true,
      skipLoadingOnRefresh: true,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Column(
        children: [
          MessageBanner(message: failureFromError(error).message),
          TextButton(
            onPressed: () =>
                ref.invalidate(myResponseProvider(request.id, donor.uid)),
            child: const Text('Try again'),
          ),
        ],
      ),
      data: (response) {
        final isWorking = action.isLoading;
        final actionFailure = failureOf(action);

        if (response != null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (actionFailure != null) ...[
                MessageBanner(message: actionFailure.message),
                const SizedBox(height: 12),
              ],
              MessageBanner(
                isError: false,
                message:
                    'You offered to help. ${request.requesterName} can '
                    'now see your name and phone number.',
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                key: RequestDetailPage.withdrawButtonKey,
                onPressed: isWorking ? null : () => _withdraw(ref),
                child: const Text('Withdraw my offer'),
              ),
            ],
          );
        }

        final blocked = ref
            .watch(respondToRequestProvider)
            .blockReason(request: request, donor: donor);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (actionFailure != null) ...[
              MessageBanner(message: actionFailure.message),
              const SizedBox(height: 12),
            ],
            if (blocked != null)
              MessageBanner(isError: false, message: blocked.message)
            else
              Text(
                'Your name and phone number will be shared with '
                '${request.requesterName} so they can contact you.',
              ),
            const SizedBox(height: 12),
            FilledButton(
              key: RequestDetailPage.respondButtonKey,
              onPressed: blocked != null || isWorking
                  ? null
                  : () => _confirmAndRespond(context, ref),
              child: isWorking
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('I can help'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmAndRespond(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Share your number?'),
        content: Text(
          '${request.requesterName} will see your name and your phone number '
          '(${donor.phone.e164}) so they can contact you. You can withdraw '
          'your offer at any time.',
        ),
        actions: [
          TextButton(
            key: RequestDetailPage.cancelShareKey,
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: RequestDetailPage.confirmShareKey,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Share my number'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await ref
        .read(respondActionProvider(request.id).notifier)
        .respond(request: request, donor: donor);
  }

  void _withdraw(WidgetRef ref) {
    unawaited(
      ref
          .read(respondActionProvider(request.id).notifier)
          .withdraw(donorUid: donor.uid),
    );
  }
}
