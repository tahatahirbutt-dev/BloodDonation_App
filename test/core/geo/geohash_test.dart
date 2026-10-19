// Uses flutter_test's bundled matchers (test/group/expect are the same
// API as package:test) so this runs with plain `flutter test`, no new
// dependency needed. Swap to package:test later if you want these pure
// Dart files running under `dart test` for faster CI feedback.
import 'package:flutter_test/flutter_test.dart';

// NOTE: adjust this import to match your project's actual package name
// (see the `name:` field in your pubspec.yaml) before running.
import 'package:blood_donation_app/core/geo/geohash.dart';

void main() {
  group('Geohash.encode', () {
    test('matches the well-known reference value for (42.6, -5.6)', () {
      // Canonical example used to explain geohash encoding (see the
      // Geohash Wikipedia article). If this fails, the bit-ordering in
      // the encode loop is broken — fix that before trusting anything
      // else built on top of this file.
      expect(Geohash.encode(42.6, -5.6, precision: 5), 'ezs42');
    });

    test('longer precision starts with the shorter-precision hash', () {
      final short = Geohash.encode(33.5910, 73.0480, precision: 5);
      final long = Geohash.encode(33.5910, 73.0480, precision: 9);
      expect(long.startsWith(short), isTrue);
    });

    test('nearby points share a longer common prefix than far points', () {
      // AFIT and a point a few km away, both in Rawalpindi.
      final afit = Geohash.encode(33.5910, 73.0480, precision: 9);
      final nearby = Geohash.encode(33.6000, 73.0500, precision: 9);
      // F-7 Islamabad — genuinely far from AFIT within the twin cities.
      final far = Geohash.encode(33.7180, 73.0620, precision: 9);

      int commonPrefixLength(String a, String b) {
        var i = 0;
        while (i < a.length && i < b.length && a[i] == b[i]) {
          i++;
        }
        return i;
      }

      final nearbyPrefix = commonPrefixLength(afit, nearby);
      final farPrefix = commonPrefixLength(afit, far);

      expect(nearbyPrefix, greaterThan(farPrefix));
    });

    test('rejects out-of-range latitude and longitude', () {
      expect(() => Geohash.encode(91, 0), throwsArgumentError);
      expect(() => Geohash.encode(0, 181), throwsArgumentError);
    });

    test('rejects zero or negative precision', () {
      expect(() => Geohash.encode(0, 0, precision: 0), throwsArgumentError);
    });
  });
}
