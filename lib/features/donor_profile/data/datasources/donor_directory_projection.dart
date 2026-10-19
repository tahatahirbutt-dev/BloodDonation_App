import 'package:blood_donation_app/features/donor_profile/domain/entities/donation_eligibility.dart';

/// Builds the *public* donor-directory document from a private profile map.
///
/// Why two documents? Firestore security rules work per document, not per
/// field, so a single `users/{uid}` document can't be "name and blood
/// group visible to everyone, phone number visible to nobody". Instead:
///
///   users/{uid}   full profile, readable only by its owner
///   donors/{uid}  this projection, readable by signed-in users, and
///                 present only while the person is visible
///
/// What is deliberately NOT copied: phone number, createdAt, and the exact
/// last-donation date. A donor's number is only shared when they choose to
/// respond to a specific blood request.
///
/// The public location is the catalog's area centroid, never a GPS fix,
/// so the directory can't reveal where someone actually lives.
abstract final class DonorDirectoryProjection {
  /// Returns `null` when the person must not be listed (hidden).
  ///
  /// [profile] is the output of `UserProfileMapper.toMap`.
  static Map<String, dynamic>? fromProfileMap(Map<String, dynamic> profile) {
    if (profile['isVisible'] != true) return null;

    final projection = <String, dynamic>{
      'name': profile['name'],
      'bloodGroup': profile['bloodGroup'],
      'locationId': profile['locationId'],
      'latitude': profile['latitude'],
      'longitude': profile['longitude'],
      'geohash': profile['geohash'],
      'isAvailable': profile['isAvailable'] == true,
    };

    // Publish the date they become eligible again instead of the donation
    // date itself: same usefulness for search, less personal. Computed
    // with the domain's own interval constant so the rule lives in one
    // place. (A stored value goes stale only if that constant changes;
    // the next profile save refreshes it.)
    final lastDonation = profile['lastDonationDate'];
    if (lastDonation is DateTime) {
      projection['eligibleFrom'] = DateTime(
        lastDonation.year,
        lastDonation.month,
        lastDonation.day + DonationEligibility.minimumIntervalDays,
      );
    }
    return projection;
  }
}
