import 'package:equatable/equatable.dart';

import 'package:blood_donation_app/core/geo/geohash.dart';
import 'package:blood_donation_app/core/geo/models/static_location.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/blood_group.dart';

import 'request_status.dart';
import 'request_urgency.dart';

/// A request for blood at a specific hospital or blood bank. Pure Dart.
///
/// The requester's phone number is deliberately NOT part of this entity:
/// requests are visible to every signed-in user, and a donor's number goes
/// to the requester only when the donor chooses to respond (see
/// `DonorResponse`).
final class BloodRequest extends Equatable {
  const BloodRequest({
    required this.id,
    required this.requesterUid,
    required this.requesterName,
    required this.bloodGroup,
    required this.unitsNeeded,
    required this.urgency,
    required this.hospital,
    required this.note,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
  });

  static const int minUnits = 1;
  static const int maxUnits = 10;
  static const int maxNoteLength = 200;

  /// How many open requests one person may have at once. A client-side
  /// guard against accidental duplicates; it is not a security control.
  static const int maxOpenPerRequester = 3;

  final String id;
  final String requesterUid;
  final String requesterName;

  /// The *patient's* blood group, not necessarily the requester's own.
  final BloodGroup bloodGroup;
  final int unitsNeeded;
  final RequestUrgency urgency;

  /// Always a catalog hospital or blood bank, never a free-text address.
  final StaticLocation hospital;

  /// Optional free text, already trimmed. Empty string when absent.
  final String note;
  final RequestStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;

  /// Derived from [hospital] so it can never drift from it; written to
  /// storage for geographic queries.
  String get geohash =>
      Geohash.encode(hospital.point.latitude, hospital.point.longitude);

  bool isExpiredAt(DateTime now) => !now.isBefore(expiresAt);

  /// Open *and* not past its expiry. The one definition of "still
  /// accepting help", used by the feed, the respond button and the rules'
  /// mirror image on the server.
  bool isOpenAt(DateTime now) =>
      status == RequestStatus.open && !isExpiredAt(now);

  BloodRequest copyWith({RequestStatus? status}) {
    return BloodRequest(
      id: id,
      requesterUid: requesterUid,
      requesterName: requesterName,
      bloodGroup: bloodGroup,
      unitsNeeded: unitsNeeded,
      urgency: urgency,
      hospital: hospital,
      note: note,
      status: status ?? this.status,
      createdAt: createdAt,
      expiresAt: expiresAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    requesterUid,
    requesterName,
    bloodGroup,
    unitsNeeded,
    urgency,
    hospital.id,
    note,
    status,
    createdAt,
    expiresAt,
  ];
}
