/// "Expires in 5 h", "Expires in 2 days", "Expired". Plain Dart, no intl.
String formatTimeLeft(DateTime expiresAt, DateTime now) {
  final left = expiresAt.difference(now);
  if (left <= Duration.zero) return 'Expired';
  if (left.inMinutes < 60) {
    final minutes = left.inMinutes < 1 ? 1 : left.inMinutes;
    return 'Expires in $minutes min';
  }
  if (left.inHours < 48) return 'Expires in ${left.inHours} h';
  return 'Expires in ${left.inDays} days';
}

/// "Under 1 km", "4.2 km", "17 km". One decimal place below 10 km, where
/// it still means something; whole kilometres above that.
String formatDistanceKm(double km) {
  if (km < 1) return 'Under 1 km';
  if (km < 10) return '${km.toStringAsFixed(1)} km';
  return '${km.round()} km';
}
