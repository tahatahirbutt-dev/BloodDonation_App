import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donation_app/core/geo/distance_calculator.dart';
import 'package:blood_donation_app/core/geo/geohash.dart';
import 'package:blood_donation_app/core/geo/geohash_cover.dart';
import 'package:blood_donation_app/core/geo/models/geo_point.dart';

/// The point [distanceKm] from [from] along [bearingRad] (great circle).
GeoPoint destination(GeoPoint from, double bearingRad, double distanceKm) {
  const earthRadiusKm = 6371.0;
  final delta = distanceKm / earthRadiusKm;
  final lat1 = from.latitude * math.pi / 180;
  final lng1 = from.longitude * math.pi / 180;
  final lat2 = math.asin(
    math.sin(lat1) * math.cos(delta) +
        math.cos(lat1) * math.sin(delta) * math.cos(bearingRad),
  );
  final lng2 =
      lng1 +
      math.atan2(
        math.sin(bearingRad) * math.sin(delta) * math.cos(lat1),
        math.cos(delta) - math.sin(lat1) * math.sin(lat2),
      );
  return GeoPoint(
    latitude: lat2 * 180 / math.pi,
    longitude: lng2 * 180 / math.pi,
  );
}

void main() {
  group('GeohashCover.decode', () {
    test('returns a cell that contains the point it was encoded from', () {
      for (final precision in [1, 3, 5, 7, 9]) {
        final hash = Geohash.encode(33.694, 73.033, precision: precision);

        final cell = GeohashCover.decode(hash);

        expect(
          cell.contains(33.694, 73.033),
          isTrue,
          reason: 'precision $precision',
        );
      }
    });

    test('matches the well-known cell of "ezs42"', () {
      final cell = GeohashCover.decode('ezs42');

      expect(cell.contains(42.6, -5.6), isTrue);
      expect(cell.latitudeSpan, closeTo(180 / 4096, 1e-9)); // 12 latitude bits
      expect(
        cell.longitudeSpan,
        closeTo(360 / 8192, 1e-9),
      ); // 13 longitude bits
    });

    test('rejects an empty hash and characters outside the alphabet', () {
      expect(() => GeohashCover.decode(''), throwsArgumentError);
      expect(
        () => GeohashCover.decode('abc'),
        throwsArgumentError,
      ); // 'a' is not used
    });
  });

  group('GeohashCover.cellSizeKm', () {
    test('cells shrink as precision grows', () {
      var previous = double.infinity;
      for (var precision = 1; precision <= 9; precision++) {
        final size = GeohashCover.cellSizeKm(precision, 33.7);
        final smaller = math.min(size.heightKm, size.widthKm);
        expect(smaller, lessThan(previous));
        previous = smaller;
      }
    });

    test('a 5-character cell is roughly 5 km tall', () {
      final size = GeohashCover.cellSizeKm(5, 0);

      expect(size.heightKm, closeTo(4.89, 0.05));
      expect(size.widthKm, closeTo(4.89, 0.05));
    });
  });

  group('GeohashCover.prefixesFor', () {
    final islamabad = GeoPoint(latitude: 33.694, longitude: 73.033);

    test('returns unique prefixes that all have the same length', () {
      for (final radius in [1.0, 5.0, 10.0, 25.0, 50.0, 100.0]) {
        final prefixes = GeohashCover.prefixesFor(islamabad, radius);

        expect(
          prefixes.toSet(),
          hasLength(prefixes.length),
          reason: '$radius km',
        );
        expect(prefixes.map((p) => p.length).toSet(), hasLength(1));
        expect(prefixes.length, lessThanOrEqualTo(9));
      }
    });

    test('always includes the cell of the centre itself', () {
      for (final radius in [1.0, 10.0, 50.0]) {
        final prefixes = GeohashCover.prefixesFor(islamabad, radius);
        final length = prefixes.first.length;

        expect(
          prefixes,
          contains(Geohash.encode(33.694, 73.033, precision: length)),
        );
      }
    });

    test('a larger radius never uses a longer (finer) prefix', () {
      var previousLength = 99;
      for (final radius in [1.0, 5.0, 10.0, 25.0, 50.0, 100.0]) {
        final length = GeohashCover.prefixesFor(islamabad, radius).first.length;

        expect(length, lessThanOrEqualTo(previousLength));
        previousLength = length;
      }
    });

    test('covers every point inside the radius (property test)', () {
      final random = math.Random(42);
      final centers = [
        islamabad,
        GeoPoint(latitude: 33.591, longitude: 73.048),
        GeoPoint(latitude: 33.718, longitude: 73.062),
      ];

      for (final center in centers) {
        for (final radius in [1.0, 3.0, 5.0, 10.0, 25.0, 50.0]) {
          final prefixes = GeohashCover.prefixesFor(center, radius);
          final length = prefixes.first.length;

          for (var i = 0; i < 300; i++) {
            // sqrt() spreads the samples evenly over the disc's area.
            final distance = radius * math.sqrt(random.nextDouble());
            final bearing = random.nextDouble() * 2 * math.pi;
            final point = destination(center, bearing, distance);
            expect(
              DistanceCalculator.haversineKm(center, point),
              lessThanOrEqualTo(radius + 1e-6),
            );

            final hash = Geohash.encode(
              point.latitude,
              point.longitude,
              precision: length,
            );
            expect(
              prefixes,
              contains(hash),
              reason:
                  '$distance km at bearing $bearing from $center '
                  '(radius $radius)',
            );
          }
        }
      }
    });

    test('rejects a zero, negative or NaN radius', () {
      expect(() => GeohashCover.prefixesFor(islamabad, 0), throwsArgumentError);
      expect(
        () => GeohashCover.prefixesFor(islamabad, -5),
        throwsArgumentError,
      );
      expect(
        () => GeohashCover.prefixesFor(islamabad, double.nan),
        throwsArgumentError,
      );
    });

    test('works at the date line and near the poles without throwing', () {
      expect(
        GeohashCover.prefixesFor(GeoPoint(latitude: 0, longitude: 179.99), 10),
        isNotEmpty,
      );
      expect(
        GeohashCover.prefixesFor(GeoPoint(latitude: 89.99, longitude: 10), 10),
        isNotEmpty,
      );
      expect(
        GeohashCover.prefixesFor(
          GeoPoint(latitude: -89.99, longitude: -180),
          10,
        ),
        isNotEmpty,
      );
    });
  });
}
