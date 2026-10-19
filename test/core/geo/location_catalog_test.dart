import 'package:flutter_test/flutter_test.dart';

// NOTE: adjust this import to match your project's actual package name.
import 'package:blood_donation_app/core/geo/location_catalog.dart';
import 'package:blood_donation_app/core/geo/models/static_location.dart';

void main() {
  group('LocationCatalog', () {
    test('every entry has a unique id', () {
      final ids = LocationCatalog.all.map((l) => l.id).toList();
      expect(
        ids.toSet().length,
        ids.length,
        reason: 'duplicate ids will silently break findById lookups',
      );
    });

    test('findById returns the matching entry', () {
      final result = LocationCatalog.findById('afit_rawalpindi');
      expect(result, isNotNull);
      expect(result!.name, contains('AFIT'));
    });

    test('findById returns null for an unknown id instead of throwing', () {
      expect(LocationCatalog.findById('does_not_exist'), isNull);
    });

    test('byCategory filters correctly', () {
      final hospitals = LocationCatalog.byCategory(LocationCategory.hospital);
      expect(hospitals, isNotEmpty);
      expect(
        hospitals.every((l) => l.category == LocationCategory.hospital),
        isTrue,
      );
    });
  });
}
