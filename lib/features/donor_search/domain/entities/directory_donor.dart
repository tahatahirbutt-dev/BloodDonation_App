import 'package:equatable/equatable.dart';

import 'package:blood_donation_app/core/geo/models/static_location.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/blood_group.dart';

/// One entry of the public donor directory: only what a donor chose to
/// make visible to other signed-in users. No phone number, no exact
/// donation date. Pure Dart.
final class DirectoryDonor extends Equatable {
  const DirectoryDonor({
    required this.uid,
    required this.name,
    required this.bloodGroup,
    required this.location,
    required this.isAvailable,
    required this.eligibleFrom,
  });

  final String uid;
  final String name;
  final BloodGroup bloodGroup;
  final StaticLocation location;
  final bool isAvailable;

  /// The first day this donor may donate again; null = no recent donation.
  final DateTime? eligibleFrom;

  /// Calendar-day comparison (time of day ignored), same convention as
  /// `DonationEligibility`.
  bool isEligibleOn(DateTime now) {
    final from = eligibleFrom;
    if (from == null) return true;
    final today = DateTime(now.year, now.month, now.day);
    final firstDay = DateTime(from.year, from.month, from.day);
    return !today.isBefore(firstDay);
  }

  @override
  List<Object?> get props => [
    uid,
    name,
    bloodGroup,
    location.id,
    isAvailable,
    eligibleFrom,
  ];
}
