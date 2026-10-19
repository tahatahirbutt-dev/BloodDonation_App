import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:blood_donation_app/core/presentation/date_format.dart';
import 'package:blood_donation_app/core/presentation/relative_time.dart';
import 'package:blood_donation_app/core/time/clock_provider.dart';

import '../../domain/entities/blood_request.dart';
import '../../domain/entities/request_status.dart';
import 'urgency_chip.dart';

/// Everything about a request, for both detail pages (the donor's view
/// and the requester's view).
class RequestDetailsCard extends ConsumerWidget {
  const RequestDetailsCard({
    required this.request,
    this.distanceKm,
    this.showRequester = true,
    super.key,
  });

  final BloodRequest request;
  final double? distanceKm;

  /// Hidden on the requester's own page ("Requested by you" is noise).
  final bool showRequester;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockProvider).now();
    final theme = Theme.of(context);
    final distance = distanceKm;
    final units = request.unitsNeeded;

    final String statusText;
    if (request.status != RequestStatus.open) {
      statusText = request.status.label;
    } else if (request.isExpiredAt(now)) {
      statusText = 'Expired';
    } else {
      statusText = formatTimeLeft(request.expiresAt, now);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  request.bloodGroup.label,
                  style: theme.textTheme.displaySmall,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '$units ${units == 1 ? 'unit' : 'units'} needed',
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                UrgencyChip(urgency: request.urgency),
              ],
            ),
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.local_hospital_outlined,
              text: '${request.hospital.name}, ${request.hospital.city}',
            ),
            if (distance != null)
              _DetailRow(
                icon: Icons.near_me_outlined,
                text:
                    'About ${formatDistanceKm(distance)} away '
                    '(in a straight line; the road is usually longer)',
              ),
            if (showRequester)
              _DetailRow(
                icon: Icons.person_outline,
                text: 'Requested by ${request.requesterName}',
              ),
            _DetailRow(
              icon: Icons.schedule,
              text: 'Posted ${formatDate(request.createdAt)} · $statusText',
            ),
            if (request.note.isNotEmpty)
              _DetailRow(icon: Icons.notes, text: request.note),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
