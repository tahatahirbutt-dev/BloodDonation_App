/// The most documents any single list query may ask for.
///
/// The Firestore security rules reject a list query whose `limit` is
/// missing or above 50, so every data source uses this one constant. If
/// it ever changes, change the `request.query.limit <= 50` checks in
/// `firestore.rules` to match.
const int maxQueryLimit = 50;
