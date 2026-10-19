import 'package:equatable/equatable.dart';

import 'directory_donor.dart';

/// What the directory returned for one search, before exact filtering.
final class DonorDirectoryPage extends Equatable {
  const DonorDirectoryPage({
    required this.donors,
    required this.mayBeIncomplete,
  });

  final List<DirectoryDonor> donors;

  /// True when at least one area query hit its result cap, so some donors
  /// in range may be missing. The UI should suggest a smaller radius.
  final bool mayBeIncomplete;

  @override
  List<Object?> get props => [donors, mayBeIncomplete];
}
