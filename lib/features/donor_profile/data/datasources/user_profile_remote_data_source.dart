/// Raw document access, with no knowledge of entities or failures' meaning.
/// Maps in, maps out. Implementations (Firestore, in-memory) must convert
/// every SDK exception into a `DataSourceException` before it escapes.
///
/// Values in the maps are plain Dart types — `DateTime`, not Firestore's
/// `Timestamp` — so the mapper above this stays free of Firebase imports.
/// The Firestore implementation converts Timestamp <-> DateTime itself.
abstract interface class UserProfileRemoteDataSource {
  /// `null` = no document for this uid.
  Future<Map<String, dynamic>?> fetch(String uid);

  Future<void> upsert(String uid, Map<String, dynamic> data);
}
