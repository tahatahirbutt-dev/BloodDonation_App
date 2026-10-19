import 'package:equatable/equatable.dart';

import 'package:blood_donation_app/core/geo/models/static_location.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/blood_group.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/phone_number.dart';

/// "I can help": a donor's offer on one request. This is the ONLY place a
/// donor's phone number leaves their private profile, and only the
/// requester (and the donor) can read it.
///
/// One response per donor per request: the storage key is
/// (requestId, donorUid), so tapping twice can never create duplicates.
final class DonorResponse extends Equatable {
  const DonorResponse({
    required this.requestId,
    required this.donorUid,
    required this.donorName,
    required this.phone,
    required this.bloodGroup,
    required this.location,
    required this.respondedAt,
  });

  final String requestId;
  final String donorUid;
  final String donorName;
  final PhoneNumber phone;
  final BloodGroup bloodGroup;

  /// The donor's own area, from the catalog.
  final StaticLocation location;
  final DateTime respondedAt;

  @override
  List<Object?> get props => [
    requestId,
    donorUid,
    donorName,
    phone,
    bloodGroup,
    location.id,
    respondedAt,
  ];
}
