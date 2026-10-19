import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:blood_donation_app/core/presentation/relative_time.dart';
import 'package:blood_donation_app/core/time/clock_provider.dart';

import '../../domain/entities/blood_request.dart';
import '../../domain/entities/request_status.dart';
import 'urgency_chip.dart';

/// One request in a list. Used in the donor feed (with a distance) and in
/// "My requests" (with its status).
class RequestCard extends ConsumerWidget {
  const RequestCard({
    required this.request,
    required this.onTap,
    this.distanceKm,
    this.showStatus = false,
    super.key,
  });

  final BloodRequest request;
  final VoidCallback onTap;

  /// Shown as "About N km away" when given.
  final double? distanceKm;

  /// In "My requests": show Open / Expired / Fulfilled / Cancelled
  /// instead of just the time left.
  final bool showStatus;

  static Key keyFor(String requestId) => Key('requestCard.$requestId');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockProvider).now();
    final theme = Theme.of(context);
    final distance = distanceKm;
    final units = request.unitsNeeded;

    return Card(
      child: InkWell(
        key: keyFor(request.id),
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    request.bloodGroup.label,
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '$units ${units == 1 ? 'unit' : 'units'} needed',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  UrgencyChip(urgency: request.urgency),
                ],
              ),
              const SizedBox(height: 8),
              Text('${request.hospital.name}, ${request.hospital.city}'),
              if (distance != null)
                Text('About ${formatDistanceKm(distance)} away'),
              const SizedBox(height: 4),
              Text(_statusText(now), style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }

  String _statusText(DateTime now) {
    if (!showStatus) return formatTimeLeft(request.expiresAt, now);
    if (request.status == RequestStatus.open) {
      return request.isExpiredAt(now)
          ? 'Expired'
          : 'Open · ${formatTimeLeft(request.expiresAt, now)}';
    }
    return request.status.label;
  }
}
