import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:blood_donation_app/core/presentation/date_format.dart';
import 'package:blood_donation_app/core/presentation/failure_ui.dart';
import 'package:blood_donation_app/core/presentation/widgets/message_banner.dart';
import 'package:blood_donation_app/core/time/clock_provider.dart';

import '../../domain/entities/donation_eligibility.dart';
import '../../domain/entities/user_profile.dart';
import '../notifiers/profile_preferences_notifier.dart';

/// The signed-in user's profile summary and their two privacy switches.
class ProfileTab extends ConsumerWidget {
  const ProfileTab({required this.profile, super.key});

  final UserProfile profile;

  static const Key availableSwitchKey = Key('profileTab.available');
  static const Key visibleSwitchKey = Key('profileTab.visible');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockProvider).now();
    final state = ref.watch(profilePreferencesProvider);
    final isSaving = state.isLoading;
    final failure = failureOf(state);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile.name, style: theme.textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  '${profile.bloodGroup.label} · '
                  '${profile.location.name}, ${profile.location.city}',
                ),
                const SizedBox(height: 12),
                Text(_eligibilityText(profile.eligibilityAt(now))),
                if (!profile.isVisible) ...[
                  const SizedBox(height: 8),
                  const Text('You are hidden from donor search.'),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (failure != null) ...[
          MessageBanner(message: failure.message),
          const SizedBox(height: 12),
        ],
        SwitchListTile(
          key: availableSwitchKey,
          contentPadding: EdgeInsets.zero,
          title: const Text('I am available to donate'),
          subtitle: const Text('Turn off when you cannot donate for now.'),
          value: profile.isAvailable,
          onChanged: isSaving
              ? null
              : (value) => unawaited(
                  ref
                      .read(profilePreferencesProvider.notifier)
                      .updatePreferences(profile, isAvailable: value),
                ),
        ),
        SwitchListTile(
          key: visibleSwitchKey,
          contentPadding: EdgeInsets.zero,
          title: const Text('Show me in donor search'),
          subtitle: const Text('Turn off to hide your profile completely.'),
          value: profile.isVisible,
          onChanged: isSaving
              ? null
              : (value) => unawaited(
                  ref
                      .read(profilePreferencesProvider.notifier)
                      .updatePreferences(profile, isVisible: value),
                ),
        ),
      ],
    );
  }

  String _eligibilityText(DonationEligibility eligibility) {
    return switch (eligibility) {
      EligibleToDonate() =>
        'Eligible to donate by interval. The blood bank makes the final call.',
      NotYetEligible(:final nextEligibleDate, :final daysRemaining) =>
        'Eligible again on ${formatDate(nextEligibleDate)} '
            '($daysRemaining days).',
    };
  }
}
