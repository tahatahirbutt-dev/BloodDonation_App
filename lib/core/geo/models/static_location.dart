import 'geo_point.dart';

/// What kind of point this is — matters for how the UI groups/filters
/// the catalog (e.g. "pick a hospital" vs "pick your area").
enum LocationCategory { hospital, bloodBank, residentialArea }

/// A predefined, curated point on the map — a hospital, blood bank, or
/// named residential sector within the v1 Islamabad/Rawalpindi scope.
class StaticLocation {
  final String id;
  final String name;
  final String city;
  final LocationCategory category;
  final GeoPoint point;

  StaticLocation({
    required this.id,
    required this.name,
    required this.city,
    required this.category,
    required this.point,
  });
}
