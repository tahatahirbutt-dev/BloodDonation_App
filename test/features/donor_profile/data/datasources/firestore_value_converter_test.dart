import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donation_app/features/donor_profile/data/datasources/firestore_value_converter.dart';

void main() {
  group('FirestoreValueConverter', () {
    final date = DateTime(2026, 2, 3, 4, 5);

    test('encode turns DateTime into Timestamp and leaves the rest alone', () {
      final encoded = FirestoreValueConverter.encode({
        'createdAt': date,
        'name': 'Taha',
        'isVisible': true,
        'latitude': 33.7,
        'lastDonationDate': null,
      });

      expect(encoded['createdAt'], Timestamp.fromDate(date));
      expect(encoded['name'], 'Taha');
      expect(encoded['isVisible'], true);
      expect(encoded['latitude'], 33.7);
      expect(encoded['lastDonationDate'], isNull);
    });

    test('decode turns Timestamp back into DateTime', () {
      final decoded = FirestoreValueConverter.decode({
        'createdAt': Timestamp.fromDate(date),
        'name': 'Taha',
      });

      expect(decoded['createdAt'], isA<DateTime>());
      expect(decoded['createdAt'], date);
      expect(decoded['name'], 'Taha');
    });

    test('encode then decode round-trips', () {
      final original = {'createdAt': date, 'name': 'Taha', 'x': null};
      final roundTripped = FirestoreValueConverter.decode(
        FirestoreValueConverter.encode(original),
      );
      expect(roundTripped, original);
    });

    test('does not mutate the input map', () {
      final input = {'createdAt': date};
      FirestoreValueConverter.encode(input);
      expect(input['createdAt'], isA<DateTime>());
    });
  });
}
