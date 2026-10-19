import 'package:equatable/equatable.dart';

import 'directory_donor.dart';

/// A donor found by a search, with their distance from the search centre.
final class DonorMatch extends Equatable {
  const DonorMatch({required this.donor, required this.distanceKm});

  final DirectoryDonor donor;

  /// Straight-line distance, not road distance.
  final double distanceKm;

  @override
  List<Object?> get props => [donor, distanceKm];
}
