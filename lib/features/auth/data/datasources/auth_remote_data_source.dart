import '../../domain/entities/auth_user.dart';

/// Raw authentication calls. Implementations (Firebase, in-memory) must
/// convert every SDK exception into a `DataSourceException` before it
/// escapes. [AuthUser] is a tiny value object, so it is used directly
/// instead of inventing a parallel DTO.
abstract interface class AuthRemoteDataSource {
  Stream<AuthUser?> userChanges();

  Future<AuthUser> signUp({required String email, required String password});

  Future<AuthUser> signIn({required String email, required String password});

  Future<void> sendVerificationEmail();

  /// Reload the account and force-refresh its ID token.
  Future<AuthUser> reload();

  Future<void> sendPasswordReset(String email);

  Future<void> signOut();
}
