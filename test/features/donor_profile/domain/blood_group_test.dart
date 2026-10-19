import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donation_app/features/donor_profile/domain/entities/blood_group.dart';

void main() {
  group('BloodGroup.compatibleDonorGroups', () {
    // Written out by hand from standard red-cell compatibility so the
    // antigen-based implementation is checked against an independent
    // source, not against itself.
    const expected = <BloodGroup, Set<BloodGroup>>{
      BloodGroup.aPositive: {
        BloodGroup.aPositive,
        BloodGroup.aNegative,
        BloodGroup.oPositive,
        BloodGroup.oNegative,
      },
      BloodGroup.aNegative: {BloodGroup.aNegative, BloodGroup.oNegative},
      BloodGroup.bPositive: {
        BloodGroup.bPositive,
        BloodGroup.bNegative,
        BloodGroup.oPositive,
        BloodGroup.oNegative,
      },
      BloodGroup.bNegative: {BloodGroup.bNegative, BloodGroup.oNegative},
      BloodGroup.abPositive: {
        BloodGroup.aPositive,
        BloodGroup.aNegative,
        BloodGroup.bPositive,
        BloodGroup.bNegative,
        BloodGroup.abPositive,
        BloodGroup.abNegative,
        BloodGroup.oPositive,
        BloodGroup.oNegative,
      },
      BloodGroup.abNegative: {
        BloodGroup.aNegative,
        BloodGroup.bNegative,
        BloodGroup.abNegative,
        BloodGroup.oNegative,
      },
      BloodGroup.oPositive: {BloodGroup.oPositive, BloodGroup.oNegative},
      BloodGroup.oNegative: {BloodGroup.oNegative},
    };

    for (final entry in expected.entries) {
      test('${entry.key.label} can receive from the right groups', () {
        expect(entry.key.compatibleDonorGroups.toSet(), entry.value);
      });
    }

    test('O- is a universal donor', () {
      for (final recipient in BloodGroup.values) {
        expect(BloodGroup.oNegative.canDonateTo(recipient), isTrue);
      }
    });

    test('AB+ can only donate to AB+', () {
      final targets = BloodGroup.values
          .where((r) => BloodGroup.abPositive.canDonateTo(r))
          .toList();
      expect(targets, [BloodGroup.abPositive]);
    });
  });

  group('BloodGroup.tryParse', () {
    test('accepts common spellings', () {
      expect(BloodGroup.tryParse('b+'), BloodGroup.bPositive);
      expect(BloodGroup.tryParse(' AB - '), BloodGroup.abNegative);
      expect(BloodGroup.tryParse('O\u2212'), BloodGroup.oNegative);
    });

    test('returns null for garbage instead of throwing', () {
      expect(BloodGroup.tryParse('C+'), isNull);
      expect(BloodGroup.tryParse(''), isNull);
    });
  });
}
