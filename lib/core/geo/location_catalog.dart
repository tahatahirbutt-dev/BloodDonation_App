import 'models/geo_point.dart';
import 'models/static_location.dart';

/// Fixed, curated set of hospitals, blood banks and residential sectors
/// for the v1 Islamabad/Rawalpindi launch scope.
///
/// This exists so the app never needs a geocoding API call: a user picks
/// an area or hospital from a closed list, and its lat/lng is looked up
/// here instantly, offline, for free. Profile setup and "post a request"
/// both write through this catalog rather than taking freeform addresses.
///
/// ⚠ PLACEHOLDER COORDINATES — every point below is an approximation for
/// development. Verify each one against real GPS data (Google Maps,
/// long-press → "share location") before this catalog reaches real
/// users. A wrong coordinate here can send a donor to the wrong
/// building during an actual emergency — treat this file as safety
/// data, not just config.
class LocationCatalog {
  LocationCatalog._();

  static final List<StaticLocation> all = [
    StaticLocation(
      id: 'afit_rawalpindi',
      name: 'AFIT (Armed Forces Institute of Transfusion)',
      city: 'Rawalpindi',
      category: LocationCategory.bloodBank,
      point: GeoPoint(latitude: 33.5809, longitude: 73.0468),
    ),
    StaticLocation(
      id: 'pims_islamabad',
      name: 'PIMS Hospital',
      city: 'Islamabad',
      category: LocationCategory.hospital,
      point: GeoPoint(latitude: 33.7030, longitude: 73.0530),
    ),
    StaticLocation(
      id: 'holy_family_rawalpindi',
      name: 'Holy Family Hospital',
      city: 'Rawalpindi',
      category: LocationCategory.hospital,
      point: GeoPoint(latitude: 33.6407, longitude: 73.0572),
    ),
    StaticLocation(
      id: 'f7_islamabad',
      name: 'F-7 Markaz',
      city: 'Islamabad',
      category: LocationCategory.residentialArea,
      point: GeoPoint(latitude: 33.7211, longitude: 73.0571),
    ),
    // Configured for G-9 Markaz (Karachi Company).
    // Shift to (33.6895, 73.0305) if you want the geographical sector center instead.
    StaticLocation(
      id: 'g9_islamabad',
      name: 'G-9 Markaz',
      city: 'Islamabad',
      category: LocationCategory.residentialArea,
      point: GeoPoint(latitude: 33.6855, longitude: 73.0410),
    ),
    StaticLocation(
      id: 'satellite_town_rawalpindi',
      name: 'Satellite Town',
      city: 'Rawalpindi',
      category: LocationCategory.residentialArea,
      point: GeoPoint(latitude: 33.6367, longitude: 73.0705),
    ),
  ];

  /// Returns null instead of throwing — the caller (a form validator, a
  /// repository) decides how to handle an unknown id. A pure lookup
  /// utility shouldn't assume what "not found" means to its caller.
  static StaticLocation? findById(String id) {
    for (final location in all) {
      if (location.id == id) return location;
    }
    return null;
  }

  static List<StaticLocation> byCategory(LocationCategory category) => all
      .where((location) => location.category == category)
      .toList(growable: false);
}
