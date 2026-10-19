import 'dart:math' as math;

import 'geohash.dart';
import 'models/geo_point.dart';

/// The rectangle a geohash cell covers.
final class GeohashCell {
  const GeohashCell({
    required this.minLatitude,
    required this.maxLatitude,
    required this.minLongitude,
    required this.maxLongitude,
  });

  final double minLatitude;
  final double maxLatitude;
  final double minLongitude;
  final double maxLongitude;

  double get latitudeSpan => maxLatitude - minLatitude;
  double get longitudeSpan => maxLongitude - minLongitude;
  double get centerLatitude => (minLatitude + maxLatitude) / 2;
  double get centerLongitude => (minLongitude + maxLongitude) / 2;

  bool contains(double latitude, double longitude) =>
      latitude >= minLatitude &&
      latitude <= maxLatitude &&
      longitude >= minLongitude &&
      longitude <= maxLongitude;
}

/// Turns "everything within X km of this point" into the small set of
/// geohash prefixes a Firestore range query can ask for.
///
/// How it works: pick the finest precision whose cells are still bigger
/// than the radius, then take the cell containing the centre plus its 8
/// neighbours. Because a cell is larger than the radius, the whole circle
/// is guaranteed to fall inside those 9 cells. The result over-fetches
/// (a 3x3 block is much bigger than the circle), so callers must still
/// filter by exact distance with `DistanceCalculator`.
abstract final class GeohashCover {
  static const String _base32 = '0123456789bcdefghjkmnpqrstuvwxyz';

  /// 2 * pi * 6371 km / 360 degrees.
  static const double _kmPerDegree = 111.195;

  /// Extra room so the guarantee survives the small errors of treating the
  /// Earth as a sphere and the circle's width as constant.
  static const double _safetyFactor = 1.25;

  /// Inverse of `Geohash.encode`. Throws [ArgumentError] on an empty hash
  /// or a character outside the geohash alphabet.
  static GeohashCell decode(String hash) {
    if (hash.isEmpty) {
      throw ArgumentError.value(hash, 'hash', 'must not be empty');
    }

    var minLat = -90.0;
    var maxLat = 90.0;
    var minLng = -180.0;
    var maxLng = 180.0;
    var isLongitudeBit = true;

    for (final char in hash.split('')) {
      final value = _base32.indexOf(char);
      if (value < 0) {
        throw ArgumentError.value(
          hash,
          'hash',
          'contains "$char", which is not a geohash character',
        );
      }
      for (var bit = 4; bit >= 0; bit--) {
        final isSet = ((value >> bit) & 1) == 1;
        if (isLongitudeBit) {
          final mid = (minLng + maxLng) / 2;
          if (isSet) {
            minLng = mid;
          } else {
            maxLng = mid;
          }
        } else {
          final mid = (minLat + maxLat) / 2;
          if (isSet) {
            minLat = mid;
          } else {
            maxLat = mid;
          }
        }
        isLongitudeBit = !isLongitudeBit;
      }
    }

    return GeohashCell(
      minLatitude: minLat,
      maxLatitude: maxLat,
      minLongitude: minLng,
      maxLongitude: maxLng,
    );
  }

  /// Approximate size of a cell of [precision] characters at [latitude].
  static ({double heightKm, double widthKm}) cellSizeKm(
    int precision,
    double latitude,
  ) {
    final totalBits = precision * 5;
    // Bits alternate longitude, latitude, longitude, ... so longitude
    // gets the extra bit when the total is odd.
    final longitudeBits = (totalBits + 1) ~/ 2;
    final latitudeBits = totalBits ~/ 2;

    final heightKm = 180 / math.pow(2, latitudeBits) * _kmPerDegree;
    final widthKm =
        360 /
        math.pow(2, longitudeBits) *
        _kmPerDegree *
        math.cos(latitude * math.pi / 180);
    return (heightKm: heightKm, widthKm: widthKm);
  }

  /// Prefixes (all the same length) whose cells together contain every
  /// point within [radiusKm] of [center]. Unique, with the centre cell
  /// among them.
  static List<String> prefixesFor(
    GeoPoint center,
    double radiusKm, {
    int maxPrecision = 8,
  }) {
    if (radiusKm.isNaN || radiusKm <= 0) {
      throw ArgumentError.value(radiusKm, 'radiusKm', 'must be positive');
    }

    final needed = radiusKm * _safetyFactor;
    var precision = 1;
    for (var p = maxPrecision; p >= 1; p--) {
      final size = cellSizeKm(p, center.latitude);
      if (math.min(size.heightKm, size.widthKm) >= needed) {
        precision = p;
        break;
      }
    }

    final home = decode(
      Geohash.encode(center.latitude, center.longitude, precision: precision),
    );

    final prefixes = <String>{};
    for (final dLat in const [-1, 0, 1]) {
      for (final dLng in const [-1, 0, 1]) {
        final latitude = home.centerLatitude + dLat * home.latitudeSpan;
        if (latitude < -90 || latitude > 90) continue;

        var longitude = home.centerLongitude + dLng * home.longitudeSpan;
        if (longitude < -180) longitude += 360;
        if (longitude > 180) longitude -= 360;

        prefixes.add(Geohash.encode(latitude, longitude, precision: precision));
      }
    }
    return prefixes.toList(growable: false);
  }
}
