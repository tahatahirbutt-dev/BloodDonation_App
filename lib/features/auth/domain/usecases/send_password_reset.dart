import 'package:blood_donation_app/core/error/result.dart';

import '../entities/email_address.dart';
import '../repositories/auth_repository.dart';

class SendPasswordReset {
  const SendPasswordReset(this._repository);

  final AuthRepository _repository;

  Future<Result<void>> call(String email) async {
    switch (EmailAddress.parse(email)) {
      case Success<EmailAddress>(:final value):
        return _repository.sendPasswordReset(value);
      case Err<EmailAddress>(:final failure):
        return Err<void>(failure);
    }
  }
}
