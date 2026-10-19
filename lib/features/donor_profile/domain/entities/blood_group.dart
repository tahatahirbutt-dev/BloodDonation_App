/// The eight ABO/Rh blood groups.
///
/// Compatibility is derived from antigens instead of a hand-typed table,
/// so there is no 8x8 matrix to get wrong: a donor can give red cells to
/// a recipient only if the recipient already carries every antigen the
/// donor has (A, B, Rh-D).
///
/// Scope: whole-blood / red-cell compatibility only. Plasma and platelet
/// rules differ, and the blood bank has the final say on every donation.
enum BloodGroup {
  aPositive('A+', hasA: true, hasB: false, rhPositive: true),
  aNegative('A-', hasA: true, hasB: false, rhPositive: false),
  bPositive('B+', hasA: false, hasB: true, rhPositive: true),
  bNegative('B-', hasA: false, hasB: true, rhPositive: false),
  abPositive('AB+', hasA: true, hasB: true, rhPositive: true),
  abNegative('AB-', hasA: true, hasB: true, rhPositive: false),
  oPositive('O+', hasA: false, hasB: false, rhPositive: true),
  oNegative('O-', hasA: false, hasB: false, rhPositive: false);

  const BloodGroup(
    this.label, {
    required this.hasA,
    required this.hasB,
    required this.rhPositive,
  });

  /// What the user sees, e.g. "B+". Display only — persist [name], not
  /// this, so renaming a label never corrupts stored data.
  final String label;
  final bool hasA;
  final bool hasB;
  final bool rhPositive;

  bool canDonateTo(BloodGroup recipient) =>
      (!hasA || recipient.hasA) &&
      (!hasB || recipient.hasB) &&
      (!rhPositive || recipient.rhPositive);

  /// Every group that can safely donate to this one, including itself.
  List<BloodGroup> get compatibleDonorGroups => BloodGroup.values
      .where((donor) => donor.canDonateTo(this))
      .toList(growable: false);

  /// Every group this donor's blood can safely go to, including their own.
  /// The mirror image of [compatibleDonorGroups].
  List<BloodGroup> get compatibleRecipientGroups => BloodGroup.values
      .where((recipient) => canDonateTo(recipient))
      .toList(growable: false);

  /// Forgiving parse for user-typed or scanned text ("ab +", "O−").
  /// Returns null instead of throwing; the caller owns the error message.
  static BloodGroup? tryParse(String raw) {
    final normalized = raw
        .trim()
        .toUpperCase()
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll('\u2212', '-');
    for (final group in values) {
      if (group.label == normalized) return group;
    }
    return null;
  }
}
