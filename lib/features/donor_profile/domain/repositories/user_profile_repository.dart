import 'package:blood_donation_app/core/error/result.dart';

import '../entities/user_profile.dart';

/// What the domain needs from storage, and nothing more. The Firestore
/// implementation lives in the data layer; a fake lives in tests. Any
/// implementation must be a drop-in replacement for any other.
abstract interface class UserProfileRepository {
  /// `Success(null)` means "no profile yet" (a brand-new user) — that is
  /// a normal state, not a failure.
  Future<Result<UserProfile?>> getProfile(String uid);

  /// Create-or-overwrite. Implementations must catch their own I/O
  /// errors and return a typed failure instead of throwing.
  Future<Result<void>> saveProfile(UserProfile profile);
}
