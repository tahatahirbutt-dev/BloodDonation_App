/// A pure geographic coordinate. No Flutter or Firebase dependency —
/// this type is safe to use from the domain layer of any feature.
class GeoPoint {
  final double latitude;
  final double longitude;

  /// Deliberately not a `const` constructor: validation has to run in
  /// every build mode (assert-based checks are stripped out of release
  /// builds, and this is a blood-donation app — a bad coordinate here is
  /// a safety bug, not a cosmetic one). These values also almost always
  /// come from runtime data (user location, catalog lookups), so losing
  /// const-ability costs nothing in practice.
  GeoPoint({required this.latitude, required this.longitude}) {
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
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeoPoint &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() => 'GeoPoint($latitude, $longitude)';
}
