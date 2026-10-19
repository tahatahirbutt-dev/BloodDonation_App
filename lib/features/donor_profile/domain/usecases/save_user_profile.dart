import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/core/geo/location_catalog.dart';
import 'package:blood_donation_app/core/geo/models/static_location.dart';

import '../entities/blood_group.dart';
import '../entities/phone_number.dart';
import '../entities/user_profile.dart';
import '../repositories/user_profile_repository.dart';

/// Raw, unvalidated input straight from the profile form.
final class SaveUserProfileParams {
  const SaveUserProfileParams({
    required this.uid,
    required this.name,
    required this.rawPhone,
    required this.bloodGroup,
    required this.locationId,
    this.lastDonationDate,
    this.isAvailable = true,
    this.isVisible = true,
  });

  final String uid;
  final String name;
  final String rawPhone;
  final BloodGroup bloodGroup;
  final String locationId;
  final DateTime? lastDonationDate;
  final bool isAvailable;
  final bool isVisible;
}

/// Validates form input, builds a [UserProfile], and saves it. Used for
/// both first-time setup and later edits; an edit keeps the original
/// `createdAt`.
class SaveUserProfile {
  SaveUserProfile(this._repository, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final UserProfileRepository _repository;
  final DateTime Function() _clock;

  static const int _minNameLength = 2;
  static const int _maxNameLength = 60;

  Future<Result<UserProfile>> call(SaveUserProfileParams params) async {
    final now = _clock();

    final name = params.name.trim();
    if (name.length < _minNameLength || name.length > _maxNameLength) {
      return const Err<UserProfile>(
        ValidationFailure(
          'Name must be between 2 and 60 characters.',
          field: 'name',
        ),
      );
    }

    final PhoneNumber phone;
    switch (PhoneNumber.parse(params.rawPhone)) {
      case Success<PhoneNumber>(:final value):
        phone = value;
      case Err<PhoneNumber>(:final failure):
        return Err<UserProfile>(failure);
    }

    final location = LocationCatalog.findById(params.locationId);
    if (location == null ||
        location.category != LocationCategory.residentialArea) {
      return const Err<UserProfile>(
        ValidationFailure(
          'Please choose your area from the list.',
          field: 'location',
        ),
      );
    }

    final lastDonation = params.lastDonationDate;
    DateTime? lastDonationDay;
    if (lastDonation != null) {
      lastDonationDay = DateTime(
        lastDonation.year,
        lastDonation.month,
        lastDonation.day,
      );
      final today = DateTime(now.year, now.month, now.day);
      if (lastDonationDay.isAfter(today)) {
        return const Err<UserProfile>(
          ValidationFailure(
            'Last donation date cannot be in the future.',
            field: 'lastDonationDate',
          ),
        );
      }
    }

    // Keep the original createdAt when editing an existing profile.
    final DateTime createdAt;
    switch (await _repository.getProfile(params.uid)) {
      case Success<UserProfile?>(:final value):
        createdAt = value?.createdAt ?? now;
      case Err<UserProfile?>(:final failure):
        return Err<UserProfile>(failure);
    }

    final profile = UserProfile(
      uid: params.uid,
      name: name,
      phone: phone,
      bloodGroup: params.bloodGroup,
      location: location,
      lastDonationDate: lastDonationDay,
      isAvailable: params.isAvailable,
      isVisible: params.isVisible,
      createdAt: createdAt,
    );

    return switch (await _repository.saveProfile(profile)) {
      Success<void>() => Success<UserProfile>(profile),
      Err<void>(:final failure) => Err<UserProfile>(failure),
    };
  }
}
