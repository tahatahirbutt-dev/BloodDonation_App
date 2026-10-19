import 'package:equatable/equatable.dart';

import 'package:blood_donation_app/core/geo/geohash.dart';
import 'package:blood_donation_app/core/geo/models/static_location.dart';

import 'blood_group.dart';
import 'donation_eligibility.dart';
import 'phone_number.dart';

/// One account = one person who can both donate and request blood
/// (unified roles). Pure Dart: no Flutter, no Firebase.
///
/// [location] is a [StaticLocation] from the catalog, never a free-text
/// address, so a profile can't exist with a place the app can't map.
final class UserProfile extends Equatable {
  const UserProfile({
    required this.uid,
    required this.name,
    required this.phone,
    required this.bloodGroup,
    required this.location,
    required this.lastDonationDate,
    required this.isAvailable,
    required this.isVisible,
    required this.createdAt,
  });

  final String uid;
  final String name;
  final PhoneNumber phone;
  final BloodGroup bloodGroup;
  final StaticLocation location;

  /// Date-only. Null = has never donated (or chose not to say).
  final DateTime? lastDonationDate;

  /// "I'm up for donating right now" — the donor's own quick toggle.
  final bool isAvailable;

  /// Master privacy switch. False = hidden from every search and
  /// notification, without deleting the profile.
  final bool isVisible;

  final DateTime createdAt;

  /// Derived, never stored on the entity, so it can't drift from
  /// [location]. The data layer writes it to Firestore for range queries.
  String get geohash =>
      Geohash.encode(location.point.latitude, location.point.longitude);

  DonationEligibility eligibilityAt(DateTime now) =>
      DonationEligibility.evaluate(
        lastDonationDate: lastDonationDate,
        now: now,
      );

  /// Single source of truth for "may this person appear in search results
  /// and receive request notifications right now?".
  bool isDiscoverableAt(DateTime now) =>
      isVisible && isAvailable && eligibilityAt(now) is EligibleToDonate;

  /// [lastDonationDate] can be replaced but not cleared: a donation can't
  /// be un-done, so there is deliberately no "set back to null" path.
  UserProfile copyWith({
    String? name,
    BloodGroup? bloodGroup,
    StaticLocation? location,
    DateTime? lastDonationDate,
    bool? isAvailable,
    bool? isVisible,
  }) {
    return UserProfile(
      uid: uid,
      name: name ?? this.name,
      phone: phone,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      location: location ?? this.location,
      lastDonationDate: lastDonationDate ?? this.lastDonationDate,
      isAvailable: isAvailable ?? this.isAvailable,
      isVisible: isVisible ?? this.isVisible,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
    uid,
    name,
    phone,
    bloodGroup,
    location.id,
    lastDonationDate,
    isAvailable,
    isVisible,
    createdAt,
  ];
}
