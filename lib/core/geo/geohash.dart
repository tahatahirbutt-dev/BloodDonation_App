/// Standard geohash encoding (Gustavo Niemeyer's public-domain
/// algorithm), implemented with zero external dependencies so it can be
/// unit tested in pure Dart with no Flutter/Firebase bootstrapping.
///
/// Firestore has no native "within X km" query. The pattern this app
/// uses instead: store a geohash string on every document with a
/// location, then query a bounding box of geohash prefixes around a
/// search point, and filter exact distance client-side with
/// [DistanceCalculator]. That bounding-box query logic belongs in the
/// data layer (it's Firestore-specific) — this file only does encoding.
class Geohash {
  Geohash._();

  static const String _base32 = '0123456789bcdefghjkmnpqrstuvwxyz';

  /// Encodes [latitude]/[longitude] into a geohash string of [precision]
  /// characters. Precision 9 (~4.8m resolution) is what gets stored on
  /// documents; shorter prefixes are used for bounding-box queries.
  static String encode(double latitude, double longitude, {int precision = 9}) {
    if (precision <= 0) {
      throw ArgumentError.value(precision, 'precision', 'must be positive');
    }
    if (latitude < -90 || latitude > 90) {
      throw ArgumentError.value(
        latitude,
        'latitude',
        'must be between -90 and 90',
      );
    }
    if (longitude < -180 || longitude > 180) {
      throw ArgumentError.value(
        longitude,
        'longitude',
        'must be between -180 and 180',
      );
    }

    final latRange = [-90.0, 90.0];
    final lngRange = [-180.0, 180.0];
    final buffer = StringBuffer();

    var isEvenBit = true;
    var bit = 0;
    var charIndex = 0;

    while (buffer.length < precision) {
      if (isEvenBit) {
        final mid = (lngRange[0] + lngRange[1]) / 2;
        if (longitude > mid) {
          charIndex |= (1 << (4 - bit));
          lngRange[0] = mid;
        } else {
          lngRange[1] = mid;
        }
      } else {
        final mid = (latRange[0] + latRange[1]) / 2;
        if (latitude > mid) {
          charIndex |= (1 << (4 - bit));
          latRange[0] = mid;
        } else {
          latRange[1] = mid;
        }
      }

      isEvenBit = !isEvenBit;

      if (bit < 4) {
        bit++;
      } else {
        buffer.write(_base32[charIndex]);
        bit = 0;
        charIndex = 0;
      }
    }

    return buffer.toString();
  }
}
