import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/geo/location_catalog.dart';
import 'package:blood_donation_app/core/presentation/failure_ui.dart';
import 'package:blood_donation_app/core/presentation/relative_time.dart';
import 'package:blood_donation_app/core/presentation/widgets/empty_view.dart';
import 'package:blood_donation_app/core/presentation/widgets/message_banner.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/blood_group.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/user_profile.dart';

import '../../domain/entities/donor_search_result.dart';
import '../notifiers/donor_search_notifier.dart';

/// "Find donors": pick the patient's blood group, where to search from and
/// how far, and see which available donors are in range, nearest first.
///
/// Donors' phone numbers are never shown here. The page says so and offers
/// [onPostRequest], because posting a request is how a donor gets in touch.
class DonorSearchTab extends ConsumerStatefulWidget {
  const DonorSearchTab({
    required this.profile,
    required this.onPostRequest,
    super.key,
  });

  final UserProfile profile;
  final VoidCallback onPostRequest;

  static const Key bloodGroupFieldKey = Key('donorSearch.bloodGroup');
  static const Key centerFieldKey = Key('donorSearch.center');
  static const Key searchButtonKey = Key('donorSearch.search');
  static const Key postRequestButtonKey = Key('donorSearch.postRequest');

  static Key radiusKeyFor(int km) => Key('donorSearch.radius.$km');
  static Key resultKeyFor(String uid) => Key('donorSearch.result.$uid');

  static const List<int> radiusOptionsKm = [5, 10, 25, 50];

  @override
  ConsumerState<DonorSearchTab> createState() => _DonorSearchTabState();
}

class _DonorSearchTabState extends ConsumerState<DonorSearchTab> {
  BloodGroup? _recipientGroup;
  late String _centerId = widget.profile.location.id;
  int _radiusKm = 10;
  String? _bloodGroupError;

  void _search() {
    FocusScope.of(context).unfocus();

    final group = _recipientGroup;
    if (group == null) {
      setState(() => _bloodGroupError = "Select the patient's blood group.");
      return;
    }

    unawaited(
      ref
          .read(donorSearchProvider.notifier)
          .search(
            recipientGroup: group,
            centerLocationId: _centerId,
            radiusKm: _radiusKm.toDouble(),
            excludeUid: widget.profile.uid,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(donorSearchProvider);
    final isSearching = state.isLoading;
    final failure = failureOf(state);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Donors\' phone numbers stay private. To get in touch, post a '
          'request: donors who can help will share their number with you.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<BloodGroup>(
          key: DonorSearchTab.bloodGroupFieldKey,
          initialValue: _recipientGroup,
          decoration: InputDecoration(
            labelText: "Patient's blood group",
            border: const OutlineInputBorder(),
            errorText: _bloodGroupError,
          ),
          items: [
            for (final group in BloodGroup.values)
              DropdownMenuItem<BloodGroup>(
                value: group,
                child: Text(group.label),
              ),
          ],
          onChanged: isSearching
              ? null
              : (group) => setState(() {
                  _recipientGroup = group;
                  _bloodGroupError = null;
                }),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          key: DonorSearchTab.centerFieldKey,
          initialValue: _centerId,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Search around',
            border: const OutlineInputBorder(),
            errorText: fieldErrorFor(failure, 'center'),
          ),
          items: [
            for (final place in LocationCatalog.all)
              DropdownMenuItem<String>(
                value: place.id,
                child: Text('${place.name}, ${place.city}'),
              ),
          ],
          onChanged: isSearching
              ? null
              : (id) {
                  if (id != null) setState(() => _centerId = id);
                },
        ),
        const SizedBox(height: 16),
        Text('Within', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final km in DonorSearchTab.radiusOptionsKm)
              ChoiceChip(
                key: DonorSearchTab.radiusKeyFor(km),
                label: Text('$km km'),
                selected: _radiusKm == km,
                onSelected: isSearching
                    ? null
                    : (_) => setState(() => _radiusKm = km),
              ),
          ],
        ),
        const SizedBox(height: 16),
        FilledButton(
          key: DonorSearchTab.searchButtonKey,
          onPressed: isSearching ? null : _search,
          child: isSearching
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Find donors'),
        ),
        const SizedBox(height: 16),
        ..._results(state, failure),
      ],
    );
  }

  List<Widget> _results(
    AsyncValue<DonorSearchResult?> state,
    Failure? failure,
  ) {
    final banner = bannerFailure(failure, const {'center'});
    if (banner != null) return [MessageBanner(message: banner.message)];

    final result = state.value;
    if (result == null) return const [];

    if (result.matches.isEmpty) {
      return [
        const EmptyView(
          icon: Icons.search_off,
          title: 'No matching donors nearby',
          message:
              'Try a larger distance, or post a request so donors can '
              'find you.',
        ),
        _postRequestButton(),
      ];
    }

    return [
      Text(
        '${result.matches.length} '
        '${result.matches.length == 1 ? 'donor' : 'donors'} could help',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 8),
      if (result.mayBeIncomplete) ...[
        const MessageBanner(
          isError: false,
          message:
              'This area has many donors, so some may be missing. '
              'Try a smaller distance.',
        ),
        const SizedBox(height: 8),
      ],
      for (final match in result.matches)
        Card(
          key: DonorSearchTab.resultKeyFor(match.donor.uid),
          child: ListTile(
            title: Text(match.donor.name),
            subtitle: Text(
              '${match.donor.bloodGroup.label} · '
              '${match.donor.location.name}, ${match.donor.location.city}',
            ),
            trailing: Text(formatDistanceKm(match.distanceKm)),
          ),
        ),
      const SizedBox(height: 8),
      _postRequestButton(),
    ];
  }

  Widget _postRequestButton() {
    return OutlinedButton(
      key: DonorSearchTab.postRequestButtonKey,
      onPressed: widget.onPostRequest,
      child: const Text('Post a request'),
    );
  }
}
