import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donation_app/core/id/id_generator.dart';

void main() {
  group('RandomIdGenerator', () {
    test('produces 20 letters and digits', () {
      final id = RandomIdGenerator().newId();

      expect(id, hasLength(RandomIdGenerator.length));
      expect(id, matches(RegExp(r'^[A-Za-z0-9]{20}$')));
    });

    test('produces a different id every time', () {
      final generator = RandomIdGenerator();

      final ids = {for (var i = 0; i < 500; i++) generator.newId()};

      expect(ids, hasLength(500));
    });

    test('is deterministic for a seeded Random (so tests can rely on it)', () {
      final a = RandomIdGenerator(random: Random(7)).newId();
      final b = RandomIdGenerator(random: Random(7)).newId();

      expect(a, b);
    });
  });
}
