import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/core/geo/location_catalog.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/blood_group.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/phone_number.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/user_profile.dart';

UserProfile sampleProfile({DateTime? lastDonationDate}) {
  final phone =
      (PhoneNumber.parse('03001234567') as Success<PhoneNumber>).value;
  return UserProfile(
    uid: 'uid-1',
    name: 'Taha Tahir',
    phone: phone,
    bloodGroup: BloodGroup.bPositive,
    location: LocationCatalog.all.firstWhere((l) => l.id == 'g9_islamabad'),
    lastDonationDate: lastDonationDate,
    isAvailable: true,
    isVisible: true,
    createdAt: DateTime(2026, 2, 3, 4, 5),
  );
}
