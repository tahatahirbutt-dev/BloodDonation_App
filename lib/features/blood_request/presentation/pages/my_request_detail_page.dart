import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/core/platform/phone_dialer_provider.dart';
import 'package:blood_donation_app/core/presentation/failure_ui.dart';
import 'package:blood_donation_app/core/presentation/widgets/empty_view.dart';
import 'package:blood_donation_app/core/presentation/widgets/message_banner.dart';
import 'package:blood_donation_app/core/time/clock_provider.dart';

import '../../domain/entities/blood_request.dart';
import '../../domain/entities/donor_response.dart';
import '../../domain/entities/request_status.dart';
import '../notifiers/close_request_notifier.dart';
import '../notifiers/request_responses.dart';
import '../widgets/request_details_card.dart';

/// The requester's view of their own request: who offered to help (with
/// phone numbers) and the buttons to close the request.
class MyRequestDetailPage extends ConsumerWidget {
  const MyRequestDetailPage({required this.request, super.key});

  final BloodRequest request;

  static const Key fulfilButtonKey = Key('myRequest.fulfil');
  static const Key cancelRequestButtonKey = Key('myRequest.cancel');
  static const Key confirmKey = Key('myRequest.confirm');
  static const Key backKey = Key('myRequest.back');

  static Key copyKeyFor(String donorUid) => Key('myRequest.copy.$donorUid');
  static Key callKeyFor(String donorUid) => Key('myRequest.call.$donorUid');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockProvider).now();
    final responses = ref.watch(requestResponsesProvider(request.id));
    final closing = ref.watch(closeRequestProvider);
    final closeFailure = failureOf(closing);
    final isOpen = request.isOpenAt(now);

    return Scaffold(
      appBar: AppBar(title: const Text('Your request')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _refresh(ref),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              RequestDetailsCard(request: request, showRequester: false),
              const SizedBox(height: 16),
              if (closeFailure != null) ...[
                MessageBanner(message: closeFailure.message),
                const SizedBox(height: 12),
              ],
              if (request.status == RequestStatus.open) ...[
                FilledButton(
                  key: fulfilButtonKey,
                  onPressed: closing.isLoading
                      ? null
                      : () => _close(context, ref, RequestStatus.fulfilled),
                  child: const Text('Mark as fulfilled'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  key: cancelRequestButtonKey,
                  onPressed: closing.isLoading
                      ? null
                      : () => _close(context, ref, RequestStatus.cancelled),
                  child: const Text('Cancel request'),
                ),
                const SizedBox(height: 8),
              ],
              if (request.status == RequestStatus.open && !isOpen)
                const MessageBanner(
                  isError: false,
                  message:
                      'This request has expired, so it no longer '
                      'appears in donors\' feeds.',
                ),
              const SizedBox(height: 16),
              Text(
                'Donors who can help',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              responses.when(
                skipLoadingOnReload: true,
                skipLoadingOnRefresh: true,
                loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => Column(
                  children: [
                    MessageBanner(message: failureFromError(error).message),
                    TextButton(
                      onPressed: () =>
                          ref.invalidate(requestResponsesProvider(request.id)),
                      child: const Text('Try again'),
                    ),
                  ],
                ),
                data: (list) => list.isEmpty
                    ? const EmptyView(
                        icon: Icons.volunteer_activism_outlined,
                        title: 'No responses yet',
                        message:
                            'Donors who can help will appear here with '
                            'their phone number. Pull down to refresh.',
                      )
                    : Column(
                        children: [
                          for (final response in list)
                            _ResponseTile(response: response),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(requestResponsesProvider(request.id));
    try {
      await ref.read(requestResponsesProvider(request.id).future);
    } catch (_) {
      // The error state in the list shows the failure.
    }
  }

  Future<void> _close(
    BuildContext context,
    WidgetRef ref,
    RequestStatus status,
  ) async {
    final isFulfilled = status == RequestStatus.fulfilled;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          isFulfilled ? 'Mark as fulfilled?' : 'Cancel this request?',
        ),
        content: Text(
          isFulfilled
              ? 'Donors will stop seeing this request. Thank everyone who '
                    'offered to help.'
              : 'Donors will stop seeing this request and you will not be '
                    'able to reopen it.',
        ),
        actions: [
          TextButton(
            key: backKey,
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Go back'),
          ),
          FilledButton(
            key: confirmKey,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(isFulfilled ? 'Mark as fulfilled' : 'Cancel request'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final navigator = Navigator.of(context);
    final closed = await ref
        .read(closeRequestProvider.notifier)
        .close(
          requestId: request.id,
          requesterUid: request.requesterUid,
          status: status,
        );
    if (closed && navigator.mounted) navigator.pop();
  }
}

class _ResponseTile extends ConsumerWidget {
  const _ResponseTile({required this.response});

  final DonorResponse response;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        title: Text(response.donorName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${response.bloodGroup.label} · '
              '${response.location.name}, ${response.location.city}',
            ),
            SelectableText(response.phone.e164),
          ],
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              key: MyRequestDetailPage.copyKeyFor(response.donorUid),
              tooltip: 'Copy number',
              icon: const Icon(Icons.copy),
              onPressed: () => unawaited(_copy(context, response.phone.e164)),
            ),
            IconButton(
              key: MyRequestDetailPage.callKeyFor(response.donorUid),
              tooltip: 'Call',
              icon: const Icon(Icons.call),
              onPressed: () =>
                  unawaited(_call(context, ref, response.phone.e164)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _call(BuildContext context, WidgetRef ref, String number) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await ref.read(phoneDialerProvider).dial(number);
    if (result is Err<void>) {
      messenger.showSnackBar(SnackBar(content: Text(result.failure.message)));
    }
  }

  Future<void> _copy(BuildContext context, String number) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await Clipboard.setData(ClipboardData(text: number));
      messenger.showSnackBar(const SnackBar(content: Text('Number copied')));
    } catch (_) {
      // Clipboard is a platform channel; if it fails the number is still
      // on screen and selectable.
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not copy. Press and hold the number instead.'),
        ),
      );
    }
  }
}
