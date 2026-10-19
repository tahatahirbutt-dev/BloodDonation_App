import 'package:blood_donation_app/core/error/result.dart';

import '../entities/user_profile.dart';
import '../repositories/user_profile_repository.dart';

/// `Success(null)` = signed in but hasn't completed profile setup yet;
/// the router uses this to decide between Home and Profile Setup.
class GetUserProfile {
  const GetUserProfile(this._repository);

  final UserProfileRepository _repository;

  Future<Result<UserProfile?>> call(String uid) => _repository.getProfile(uid);
}
