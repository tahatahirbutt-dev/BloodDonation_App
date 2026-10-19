import 'package:equatable/equatable.dart';

import 'donor_match.dart';

/// The final answer to a donor search: matches nearest first.
final class DonorSearchResult extends Equatable {
  const DonorSearchResult({
    required this.matches,
    required this.mayBeIncomplete,
  });

  final List<DonorMatch> matches;
  final bool mayBeIncomplete;

  @override
  List<Object?> get props => [matches, mayBeIncomplete];
}
