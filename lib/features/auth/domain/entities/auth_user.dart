import 'package:equatable/equatable.dart';

/// The signed-in account, as the rest of the app sees it. Pure Dart: no
/// Firebase `User` ever leaves the data layer.
final class AuthUser extends Equatable {
  const AuthUser({
    required this.uid,
    required this.email,
    required this.isEmailVerified,
  });

  final String uid;
  final String email;

  /// Security rules only trust verified accounts (the stand-in for phone
  /// OTP on the free plan), so the UI must not go past the verification
  /// screen until this is true.
  final bool isEmailVerified;

  @override
  List<Object?> get props => [uid, email, isEmailVerified];
}
