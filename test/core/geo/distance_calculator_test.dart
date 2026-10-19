import 'package:flutter_test/flutter_test.dart';

// NOTE: adjust this import to match your project's actual package name.
import 'package:blood_donation_app/core/geo/distance_calculator.dart';
import 'package:blood_donation_app/core/geo/models/geo_point.dart';

void main() {
  group('DistanceCalculator.haversineKm', () {
    test('distance from a point to itself is zero', () {
      final point = GeoPoint(latitude: 33.5910, longitude: 73.0480);
      expect(DistanceCalculator.haversineKm(point, point), closeTo(0, 0.0001));
    });

    test('distance is symmetric', () {
      final a = GeoPoint(latitude: 33.5910, longitude: 73.0480);
      final b = GeoPoint(latitude: 33.7180, longitude: 73.0620);

      final ab = DistanceCalculator.haversineKm(a, b);
      final ba = DistanceCalculator.haversineKm(b, a);

      expect(ab, closeTo(ba, 0.0001));
    });

    test('AFIT to F-7 Islamabad is a plausible twin-cities distance', () {
      final afit = GeoPoint(latitude: 33.5910, longitude: 73.0480);
      final f7 = GeoPoint(latitude: 33.7180, longitude: 73.0620);

      final distance = DistanceCalculator.haversineKm(afit, f7);

      // Loose bounds on purpose — this checks the formula is in the
      // right ballpark for two points genuinely across the twin cities,
      // not an exact figure. Tighten once real coordinates are verified.
      expect(distance, greaterThan(5));
      expect(distance, lessThan(30));
    });
  });
}
