import 'package:blood_donation_app/core/geo/geohash.dart';
import 'package:blood_donation_app/core/geo/location_catalog.dart';
import 'package:blood_donation_app/core/id/id_generator.dart';
import 'package:blood_donation_app/features/blood_request/data/datasources/blood_request_remote_data_source.dart';
import 'package:blood_donation_app/features/blood_request/data/mappers/blood_request_mapper.dart';
import 'package:blood_donation_app/features/blood_request/domain/entities/blood_request.dart';
import 'package:blood_donation_app/features/blood_request/domain/entities/request_status.dart';
import 'package:blood_donation_app/features/blood_request/domain/entities/request_urgency.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/blood_group.dart';

/// The instant most request tests treat as "now".
final DateTime testNow = DateTime(2026, 3, 1, 12);

/// A valid open request posted one hour before [testNow] by somebody
/// other than the default test user ('uid-1'). Locations come from the
/// real catalog.
BloodRequest sampleRequest({
  String id = 'req-1',
  String requesterUid = 'other-uid',
  String requesterName = 'Ayesha Khan',
  BloodGroup bloodGroup = BloodGroup.bPositive,
  int unitsNeeded = 2,
  RequestUrgency urgency = RequestUrgency.urgent,
  String hospitalId = 'pims_islamabad',
  String note = '',
  RequestStatus status = RequestStatus.open,
  DateTime? createdAt,
  DateTime? expiresAt,
}) {
  final created = createdAt ?? testNow.subtract(const Duration(hours: 1));
  return BloodRequest(
    id: id,
    requesterUid: requesterUid,
    requesterName: requesterName,
    bloodGroup: bloodGroup,
    unitsNeeded: unitsNeeded,
    urgency: urgency,
    hospital: LocationCatalog.all.firstWhere((l) => l.id == hospitalId),
    note: note,
    status: status,
    createdAt: created,
    expiresAt: expiresAt ?? created.add(urgency.validFor),
  );
}

/// Stores [request] in a request data source, the way the app would.
Future<void> seedRequest(
  BloodRequestRemoteDataSource dataSource,
  BloodRequest request,
) =>
    dataSource.create(request.id, BloodRequestMapper.toMap(request));

/// A donor-directory document for a donor living at a catalog location.
Map<String, dynamic> directoryEntry({
  required String name,
  required BloodGroup bloodGroup,
  required String locationId,
  bool isAvailable = true,
  DateTime? eligibleFrom,
}) {
  final location = LocationCatalog.all.firstWhere((l) => l.id == locationId);
  return <String, dynamic>{
    'name': name,
    'bloodGroup': bloodGroup.name,
    'locationId': location.id,
    'latitude': location.point.latitude,
    'longitude': location.point.longitude,
    'geohash': Geohash.encode(
      location.point.latitude,
      location.point.longitude,
    ),
    'isAvailable': isAvailable,
    'eligibleFrom': ?eligibleFrom,
  };
}

/// Returns "id-1", "id-2", ... so tests know the id a use case will pick.
final class SequentialIdGenerator implements IdGenerator {
  int _count = 0;

  @override
  String newId() => 'id-${++_count}';
}
