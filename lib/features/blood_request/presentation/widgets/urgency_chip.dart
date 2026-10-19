import 'package:flutter/material.dart';

import '../../domain/entities/request_urgency.dart';

/// Small coloured label: Critical / Urgent / Planned. The text carries the
/// meaning; colour only reinforces it.
class UrgencyChip extends StatelessWidget {
  const UrgencyChip({required this.urgency, super.key});

  final RequestUrgency urgency;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (background, foreground) = switch (urgency) {
      RequestUrgency.critical => (
        scheme.errorContainer,
        scheme.onErrorContainer,
      ),
      RequestUrgency.urgent => (
        scheme.tertiaryContainer,
        scheme.onTertiaryContainer,
      ),
      RequestUrgency.planned => (
        scheme.secondaryContainer,
        scheme.onSecondaryContainer,
      ),
    };

    return Chip(
      label: Text(urgency.label),
      labelStyle: TextStyle(color: foreground),
      backgroundColor: background,
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
