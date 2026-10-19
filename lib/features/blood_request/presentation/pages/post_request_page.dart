import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:blood_donation_app/core/geo/location_catalog.dart';
import 'package:blood_donation_app/core/geo/models/static_location.dart';
import 'package:blood_donation_app/core/presentation/failure_ui.dart';
import 'package:blood_donation_app/core/presentation/widgets/message_banner.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/blood_group.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/user_profile.dart';

import '../../domain/entities/blood_request.dart';
import '../../domain/entities/request_urgency.dart';
import '../../domain/usecases/post_blood_request.dart';
import '../notifiers/post_request_notifier.dart';

/// "Request blood" form. Every rule (units, hospital from the catalog,
/// note length, open-request limit) lives in `PostBloodRequest`; this page
/// collects input and shows what the use case reports, under the matching
/// field. Pops with `true` once the request is saved.
class PostRequestPage extends ConsumerStatefulWidget {
  const PostRequestPage({required this.profile, super.key});

  final UserProfile profile;

  static const Key bloodGroupFieldKey = Key('postRequest.bloodGroup');
  static const Key unitsFieldKey = Key('postRequest.units');
  static const Key urgencyKey = Key('postRequest.urgency');
  static const Key hospitalFieldKey = Key('postRequest.hospital');
  static const Key noteFieldKey = Key('postRequest.note');
  static const Key submitButtonKey = Key('postRequest.submit');

  @override
  ConsumerState<PostRequestPage> createState() => _PostRequestPageState();
}

class _PostRequestPageState extends ConsumerState<PostRequestPage> {
  static const Set<String> _inlineFields = {'units', 'hospital', 'note'};

  final TextEditingController _note = TextEditingController();

  BloodGroup? _bloodGroup;
  int _units = BloodRequest.minUnits;
  RequestUrgency _urgency = RequestUrgency.urgent;
  String? _hospitalId;
  String? _bloodGroupError;

  late final List<StaticLocation> _hospitals = [
    ...LocationCatalog.byCategory(LocationCategory.hospital),
    ...LocationCatalog.byCategory(LocationCategory.bloodBank),
  ];

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    // The use case needs a real BloodGroup, so this one check lives here.
    final group = _bloodGroup;
    if (group == null) {
      setState(() => _bloodGroupError = "Select the patient's blood group.");
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final saved = await ref
        .read(postRequestProvider.notifier)
        .submit(
          PostBloodRequestParams(
            requesterUid: widget.profile.uid,
            requesterName: widget.profile.name,
            bloodGroup: group,
            unitsNeeded: _units,
            urgency: _urgency,
            // Empty string fails the use case's "choose the hospital from
            // the list" check, so the message appears under the field.
            hospitalId: _hospitalId ?? '',
            note: _note.text,
          ),
        );
    if (!saved) return;

    messenger.showSnackBar(
      const SnackBar(
        content: Text('Request posted. Donors who can help will respond.'),
      ),
    );
    if (navigator.mounted) navigator.pop(true);
  }

  String _validityText(RequestUrgency urgency) {
    final hours = urgency.validFor.inHours;
    final span = hours >= 48
        ? '${urgency.validFor.inDays} days'
        : '$hours hours';
    return '${urgency.description}. Stays open for $span.';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postRequestProvider);
    final isPosting = state.isLoading;
    final failure = failureOf(state);
    final banner = bannerFailure(failure, _inlineFields);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Request blood')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Your name and the hospital are shown to every signed-in donor. '
              'Your phone number is not shown: donors who can help will share '
              'theirs with you.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'In an emergency, call Rescue 1122 first.',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (banner != null) ...[
              MessageBanner(message: banner.message),
              const SizedBox(height: 16),
            ],
            DropdownButtonFormField<BloodGroup>(
              key: PostRequestPage.bloodGroupFieldKey,
              initialValue: _bloodGroup,
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
              onChanged: isPosting
                  ? null
                  : (group) => setState(() {
                      _bloodGroup = group;
                      _bloodGroupError = null;
                    }),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              key: PostRequestPage.unitsFieldKey,
              initialValue: _units,
              decoration: InputDecoration(
                labelText: 'Units of blood needed',
                border: const OutlineInputBorder(),
                errorText: fieldErrorFor(failure, 'units'),
              ),
              items: [
                for (
                  var units = BloodRequest.minUnits;
                  units <= BloodRequest.maxUnits;
                  units++
                )
                  DropdownMenuItem<int>(value: units, child: Text('$units')),
              ],
              onChanged: isPosting
                  ? null
                  : (units) {
                      if (units != null) setState(() => _units = units);
                    },
            ),
            const SizedBox(height: 16),
            Text('How urgent is it?', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<RequestUrgency>(
              key: PostRequestPage.urgencyKey,
              showSelectedIcon: false,
              segments: [
                for (final urgency in RequestUrgency.values)
                  ButtonSegment<RequestUrgency>(
                    value: urgency,
                    label: Text(urgency.label),
                  ),
              ],
              selected: {_urgency},
              onSelectionChanged: isPosting
                  ? null
                  : (selection) => setState(() => _urgency = selection.first),
            ),
            const SizedBox(height: 4),
            Text(_validityText(_urgency), style: theme.textTheme.bodySmall),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: PostRequestPage.hospitalFieldKey,
              initialValue: _hospitalId,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Hospital or blood bank',
                border: const OutlineInputBorder(),
                errorText: fieldErrorFor(failure, 'hospital'),
              ),
              items: [
                for (final hospital in _hospitals)
                  DropdownMenuItem<String>(
                    value: hospital.id,
                    child: Text('${hospital.name}, ${hospital.city}'),
                  ),
              ],
              onChanged: isPosting
                  ? null
                  : (id) => setState(() => _hospitalId = id),
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: PostRequestPage.noteFieldKey,
              controller: _note,
              enabled: !isPosting,
              maxLines: 3,
              maxLength: BloodRequest.maxNoteLength,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Note for donors (optional)',
                hintText: 'Ward, bed number, who to ask for…',
                border: const OutlineInputBorder(),
                errorText: fieldErrorFor(failure, 'note'),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              key: PostRequestPage.submitButtonKey,
              onPressed: isPosting ? null : _submit,
              child: isPosting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Post request'),
            ),
          ],
        ),
      ),
    );
  }
}
