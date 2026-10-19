import 'dart:math';

import 'models/geo_point.dart';

/// Great-circle distance between two points using the Haversine formula.
/// Pure Dart, no dependencies — this is what turns "same geohash cell"
/// into an actual "X km away" for the UI, and what filters out the false
/// positives that a geohash bounding-box query always produces near its
/// edges.
class DistanceCalculator {
  DistanceCalculator._();

  static const double _earthRadiusKm = 6371.0;

  static double haversineKm(GeoPoint from, GeoPoint to) {
    final dLat = _degToRad(to.latitude - from.latitude);
    final dLng = _degToRad(to.longitude - from.longitude);
    final lat1 = _degToRad(from.latitude);
    final lat2 = _degToRad(to.latitude);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return _earthRadiusKm * c;
  }

  static double _degToRad(double degrees) => degrees * pi / 180.0;
}
