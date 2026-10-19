import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donation_app/features/donor_profile/domain/entities/blood_group.dart';

void main() {
  group('BloodGroup.compatibleRecipientGroups', () {
    // Written out by hand (standard red-cell compatibility), independent
    // of the antigen logic under test.
    const expected = <BloodGroup, Set<BloodGroup>>{
      BloodGroup.oNegative: {
        BloodGroup.oNegative,
        BloodGroup.oPositive,
        BloodGroup.aNegative,
        BloodGroup.aPositive,
        BloodGroup.bNegative,
        BloodGroup.bPositive,
        BloodGroup.abNegative,
        BloodGroup.abPositive,
      },
      BloodGroup.oPositive: {
        BloodGroup.oPositive,
        BloodGroup.aPositive,
        BloodGroup.bPositive,
        BloodGroup.abPositive,
      },
      BloodGroup.aNegative: {
        BloodGroup.aNegative,
        BloodGroup.aPositive,
        BloodGroup.abNegative,
        BloodGroup.abPositive,
      },
      BloodGroup.aPositive: {BloodGroup.aPositive, BloodGroup.abPositive},
      BloodGroup.bNegative: {
        BloodGroup.bNegative,
        BloodGroup.bPositive,
        BloodGroup.abNegative,
        BloodGroup.abPositive,
      },
      BloodGroup.bPositive: {BloodGroup.bPositive, BloodGroup.abPositive},
      BloodGroup.abNegative: {BloodGroup.abNegative, BloodGroup.abPositive},
      BloodGroup.abPositive: {BloodGroup.abPositive},
    };

    for (final entry in expected.entries) {
      test(
        '${entry.key.label} can give to exactly ${entry.value.length} groups',
        () {
          expect(entry.key.compatibleRecipientGroups.toSet(), entry.value);
        },
      );
    }

    test('is the mirror image of compatibleDonorGroups', () {
      for (final donor in BloodGroup.values) {
        for (final recipient in BloodGroup.values) {
          expect(
            donor.compatibleRecipientGroups.contains(recipient),
            recipient.compatibleDonorGroups.contains(donor),
            reason: '${donor.label} -> ${recipient.label}',
          );
        }
      }
    });
  });
}
