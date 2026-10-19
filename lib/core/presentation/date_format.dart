const List<String> _months = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// "10 Jan 2026". No intl dependency for a single fixed format.
String formatDate(DateTime date) =>
    '${date.day} ${_months[date.month - 1]} ${date.year}';
