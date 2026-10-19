import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

/// Converts between the plain-Dart maps the mapper produces and the
/// Firestore-native values stored in documents.
///
/// The only difference today is dates: the mapper deals in `DateTime`,
/// Firestore stores `Timestamp`. Flat maps only — profile documents have
/// no nested structures. If one ever does, extend this class rather than
/// converting in the data source.
abstract final class FirestoreValueConverter {
  static Map<String, dynamic> encode(Map<String, dynamic> map) {
    return <String, dynamic>{
      for (final entry in map.entries) entry.key: _encodeValue(entry.value),
    };
  }

  static Map<String, dynamic> decode(Map<String, dynamic> map) {
    return <String, dynamic>{
      for (final entry in map.entries) entry.key: _decodeValue(entry.value),
    };
  }

  static Object? _encodeValue(Object? value) =>
      value is DateTime ? Timestamp.fromDate(value) : value;

  static Object? _decodeValue(Object? value) =>
      value is Timestamp ? value.toDate() : value;
}
