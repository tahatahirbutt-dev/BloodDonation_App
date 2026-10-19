import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donation_app/core/geo/location_catalog.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/blood_group.dart';
import 'package:blood_donation_app/features/donor_search/domain/entities/directory_donor.dart';

DirectoryDonor donor({DateTime? eligibleFrom}) => DirectoryDonor(
  uid: 'bob',
  name: 'Bilal Khan',
  bloodGroup: BloodGroup.oNegative,
  location: LocationCatalog.all.firstWhere((l) => l.id == 'g9_islamabad'),
  isAvailable: true,
  eligibleFrom: eligibleFrom,
);

void main() {
  group('DirectoryDonor.isEligibleOn', () {
    test('a donor with no recent donation is always eligible', () {
      expect(donor().isEligibleOn(DateTime(2026, 3, 1)), isTrue);
    });

    test(
      'is not eligible the day before, and is eligible from the day itself',
      () {
        final bob = donor(eligibleFrom: DateTime(2026, 5, 20));

        expect(bob.isEligibleOn(DateTime(2026, 5, 19, 23, 59)), isFalse);
        expect(bob.isEligibleOn(DateTime(2026, 5, 20)), isTrue);
        expect(bob.isEligibleOn(DateTime(2026, 5, 20, 18, 30)), isTrue);
        expect(bob.isEligibleOn(DateTime(2026, 8, 1)), isTrue);
      },
    );

    test('ignores the time of day stored on eligibleFrom', () {
      final bob = donor(eligibleFrom: DateTime(2026, 5, 20, 19));

      expect(bob.isEligibleOn(DateTime(2026, 5, 20, 8)), isTrue);
    });
  });
}
