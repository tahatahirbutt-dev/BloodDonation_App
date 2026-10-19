import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donation_app/core/presentation/relative_time.dart';

void main() {
  final now = DateTime(2026, 3, 1, 12);

  group('formatTimeLeft', () {
    test('is "Expired" at or after the expiry time', () {
      expect(formatTimeLeft(now, now), 'Expired');
      expect(
        formatTimeLeft(now.subtract(const Duration(hours: 3)), now),
        'Expired',
      );
    });

    test('shows minutes under an hour, at least 1', () {
      expect(
        formatTimeLeft(now.add(const Duration(seconds: 20)), now),
        'Expires in 1 min',
      );
      expect(
        formatTimeLeft(now.add(const Duration(minutes: 45)), now),
        'Expires in 45 min',
      );
    });

    test('shows hours up to two days', () {
      expect(
        formatTimeLeft(now.add(const Duration(hours: 5, minutes: 30)), now),
        'Expires in 5 h',
      );
      expect(
        formatTimeLeft(now.add(const Duration(hours: 47)), now),
        'Expires in 47 h',
      );
    });

    test('shows days beyond that', () {
      expect(
        formatTimeLeft(now.add(const Duration(days: 3)), now),
        'Expires in 3 days',
      );
    });
  });

  group('formatDistanceKm', () {
    test('says "Under 1 km" below a kilometre', () {
      expect(formatDistanceKm(0.4), 'Under 1 km');
      expect(formatDistanceKm(0), 'Under 1 km');
    });

    test('keeps one decimal below 10 km', () {
      expect(formatDistanceKm(4.24), '4.2 km');
    });

    test('rounds to whole kilometres from 10 km', () {
      expect(formatDistanceKm(17.4), '17 km');
      expect(formatDistanceKm(10), '10 km');
    });
  });
}
