/// One stored document as the data layer sees it: its id plus a plain map
/// of fields (`DateTime`, not Firestore's `Timestamp`). Lets list queries
/// return ids alongside data without importing any SDK type.
final class RawDocument {
  const RawDocument(this.id, this.data);

  final String id;
  final Map<String, dynamic> data;
}
