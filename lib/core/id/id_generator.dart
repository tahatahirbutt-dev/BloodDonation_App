import 'dart:math';

/// Source of new document ids, as an interface so use cases that create
/// things stay deterministic in tests (a fake returns "id-1", "id-2", ...).
abstract interface class IdGenerator {
  String newId();
}

/// 20 random letters and digits from a secure random source: the same
/// shape and collision odds as a Firestore auto-id, but available to the
/// domain layer without importing Firebase.
final class RandomIdGenerator implements IdGenerator {
  RandomIdGenerator({Random? random}) : _random = random ?? Random.secure();

  static const int length = 20;
  static const String _alphabet =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';

  final Random _random;

  @override
  String newId() {
    final buffer = StringBuffer();
    for (var i = 0; i < length; i++) {
      buffer.write(_alphabet[_random.nextInt(_alphabet.length)]);
    }
    return buffer.toString();
  }
}
