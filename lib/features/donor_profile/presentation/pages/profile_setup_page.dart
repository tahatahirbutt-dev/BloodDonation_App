import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:blood_donation_app/core/geo/location_catalog.dart';
import 'package:blood_donation_app/core/geo/models/static_location.dart';
import 'package:blood_donation_app/core/presentation/date_format.dart';
import 'package:blood_donation_app/core/presentation/failure_ui.dart';
import 'package:blood_donation_app/core/presentation/widgets/message_banner.dart';
import 'package:blood_donation_app/core/time/clock_provider.dart';

import '../../domain/entities/blood_group.dart';
import '../../domain/usecases/save_user_profile.dart';
import '../notifiers/profile_setup_notifier.dart';

/// First-run profile form. Every rule (name length, phone format, area
/// from the catalog, date not in the future) lives in `SaveUserProfile`;
/// this page only collects input and shows what the use case reports,
/// under the matching field.
class ProfileSetupPage extends ConsumerStatefulWidget {
  const ProfileSetupPage({
    required this.uid,
    required this.onSignOut,
    super.key,
  });

  final String uid;
  final VoidCallback onSignOut;

  static const Key nameFieldKey = Key('profileSetup.name');
  static const Key phoneFieldKey = Key('profileSetup.phone');
  static const Key bloodGroupFieldKey = Key('profileSetup.bloodGroup');
  static const Key areaFieldKey = Key('profileSetup.area');
  static const Key lastDonationButtonKey = Key('profileSetup.lastDonation');
  static const Key clearLastDonationButtonKey = Key(
    'profileSetup.clearLastDonation',
  );
  static const Key availableSwitchKey = Key('profileSetup.available');
  static const Key visibleSwitchKey = Key('profileSetup.visible');
  static const Key saveButtonKey = Key('profileSetup.save');
  static const Key signOutButtonKey = Key('profileSetup.signOut');

  @override
  ConsumerState<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends ConsumerState<ProfileSetupPage> {
  static const Set<String> _inlineFields = {
    'name',
    'phone',
    'location',
    'lastDonationDate',
  };

  final TextEditingController _name = TextEditingController();
  final TextEditingController _phone = TextEditingController();

  BloodGroup? _bloodGroup;
  String? _locationId;
  DateTime? _lastDonation;
  bool _isAvailable = true;
  bool _isVisible = true;
  String? _bloodGroupError;

  late final List<StaticLocation> _areas = LocationCatalog.byCategory(
    LocationCategory.residentialArea,
  );

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _pickLastDonation() async {
    final now = ref.read(clockProvider).now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _lastDonation ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      helpText: 'Date of your last donation',
    );
    if (picked != null && mounted) setState(() => _lastDonation = picked);
  }

  void _save() {
    FocusScope.of(context).unfocus();

    // The use case needs a real BloodGroup, so this one check lives here.
    final group = _bloodGroup;
    if (group == null) {
      setState(() => _bloodGroupError = 'Select your blood group.');
      return;
    }

    unawaited(
      ref
          .read(profileSetupProvider.notifier)
          .save(
            SaveUserProfileParams(
              uid: widget.uid,
              name: _name.text,
              rawPhone: _phone.text,
              bloodGroup: group,
              // Empty string fails the use case's "choose your area from
              // the list" check, so the message appears under the field.
              locationId: _locationId ?? '',
              lastDonationDate: _lastDonation,
              isAvailable: _isAvailable,
              isVisible: _isVisible,
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileSetupProvider);
    final isSaving = state.isLoading;
    final failure = failureOf(state);
    final banner = bannerFailure(failure, _inlineFields);
    final theme = Theme.of(context);
    final lastDonation = _lastDonation;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set up your profile'),
        actions: [
          TextButton(
            key: ProfileSetupPage.signOutButtonKey,
            onPressed: isSaving ? null : widget.onSignOut,
            child: const Text('Sign out'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Your name, blood group and area can be seen by other signed-in '
              'users. Your phone number is never shown in search results.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (banner != null) ...[
              MessageBanner(message: banner.message),
              const SizedBox(height: 16),
            ],
            TextFormField(
              key: ProfileSetupPage.nameFieldKey,
              controller: _name,
              enabled: !isSaving,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Full name',
                border: const OutlineInputBorder(),
                errorText: fieldErrorFor(failure, 'name'),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: ProfileSetupPage.phoneFieldKey,
              controller: _phone,
              enabled: !isSaving,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Mobile number',
                hintText: '0300 1234567',
                border: const OutlineInputBorder(),
                errorText: fieldErrorFor(failure, 'phone'),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<BloodGroup>(
              key: ProfileSetupPage.bloodGroupFieldKey,
              initialValue: _bloodGroup,
              decoration: InputDecoration(
                labelText: 'Blood group',
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
              onChanged: isSaving
                  ? null
                  : (group) => setState(() {
                      _bloodGroup = group;
                      _bloodGroupError = null;
                    }),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: ProfileSetupPage.areaFieldKey,
              initialValue: _locationId,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Your area',
                border: const OutlineInputBorder(),
                errorText: fieldErrorFor(failure, 'location'),
              ),
              items: [
                for (final area in _areas)
                  DropdownMenuItem<String>(
                    value: area.id,
                    child: Text('${area.name}, ${area.city}'),
                  ),
              ],
              onChanged: isSaving
                  ? null
                  : (id) => setState(() => _locationId = id),
            ),
            const SizedBox(height: 16),
            InputDecorator(
              decoration: InputDecoration(
                labelText: 'Last donation (optional)',
                border: const OutlineInputBorder(),
                errorText: fieldErrorFor(failure, 'lastDonationDate'),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      lastDonation == null
                          ? 'Never / not sure'
                          : formatDate(lastDonation),
                    ),
                  ),
                  if (lastDonation != null)
                    IconButton(
                      key: ProfileSetupPage.clearLastDonationButtonKey,
                      tooltip: 'Clear date',
                      icon: const Icon(Icons.clear),
                      onPressed: isSaving
                          ? null
                          : () => setState(() => _lastDonation = null),
                    ),
                  TextButton(
                    key: ProfileSetupPage.lastDonationButtonKey,
                    onPressed: isSaving ? null : _pickLastDonation,
                    child: const Text('Choose date'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              key: ProfileSetupPage.availableSwitchKey,
              contentPadding: EdgeInsets.zero,
              title: const Text('I am available to donate'),
              value: _isAvailable,
              onChanged: isSaving
                  ? null
                  : (value) => setState(() => _isAvailable = value),
            ),
            SwitchListTile(
              key: ProfileSetupPage.visibleSwitchKey,
              contentPadding: EdgeInsets.zero,
              title: const Text('Show me in donor search'),
              subtitle: const Text('Turn off to hide your profile completely.'),
              value: _isVisible,
              onChanged: isSaving
                  ? null
                  : (value) => setState(() => _isVisible = value),
            ),
            const SizedBox(height: 16),
            FilledButton(
              key: ProfileSetupPage.saveButtonKey,
              onPressed: isSaving ? null : _save,
              child: isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save and continue'),
            ),
          ],
        ),
      ),
    );
  }
}
