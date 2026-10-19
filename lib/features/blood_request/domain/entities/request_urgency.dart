/// How soon the blood is needed. Declared most urgent first, so
/// `index` doubles as sort priority (0 = most urgent).
///
/// Persist [name], never [label]. [validFor] is how long a request stays
/// open before it expires on its own, so stale emergencies never linger
/// in other people's feeds.
enum RequestUrgency {
  critical(
    label: 'Critical',
    description: 'Needed within hours',
    validFor: Duration(hours: 24),
  ),
  urgent(
    label: 'Urgent',
    description: 'Needed within a day or two',
    validFor: Duration(hours: 72),
  ),
  planned(
    label: 'Planned',
    description: 'Needed within the week',
    validFor: Duration(days: 7),
  );

  const RequestUrgency({
    required this.label,
    required this.description,
    required this.validFor,
  });

  final String label;
  final String description;
  final Duration validFor;
}
