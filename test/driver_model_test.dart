import 'package:flutter_test/flutter_test.dart';
import 'package:za2zo2a_admin/features/drivers/data/models/driver_document.dart';
import 'package:za2zo2a_admin/features/drivers/data/models/driver_model.dart';

/// Captured from the live backend `GET /api/admin/drivers`.
Map<String, dynamic> _driver({
  bool active = true,
  String licenseStatus = 'approved',
}) =>
    {
      '_id': '6a516f5a81838877e0c3346a',
      'tier': 'standard',
      'isOnline': true,
      'vehicle': {
        'make': 'Toyota',
        'model': 'Corolla',
        'color': 'White',
        'plateNumber': 'XYG-999',
        'year': 2020,
        'seats': 4,
      },
      'documents': {
        'drivingLicense': {'status': licenseStatus},
        'carLicense': {'status': 'approved'},
        'nationalId': {'status': 'approved'},
        'criminalRecord': {'status': 'approved'},
        'profilePhoto': {'status': 'approved'},
      },
      'earnings': {'totalLifetime': 44.43, 'pendingBalance': 44.43},
      'stats': {'totalTrips': 12, 'acceptanceRate': 100},
      'user': {
        '_id': '6a516f5981838877e0c33466',
        'fullName': 'Ahmed Driver',
        'email': 'driver6@test.com',
        'phone': '01035599526',
        'rating': 4.8,
        'isVerified': true,
        'isActive': active,
        'createdAt': '2026-07-10T22:16:57.189Z',
      },
    };

void main() {
  group('DriverModel.fromJson', () {
    test('parses the real list shape', () {
      final d = DriverModel.fromJson(_driver());
      expect(d.id, '6a516f5a81838877e0c3346a');
      expect(d.userId, '6a516f5981838877e0c33466');
      expect(d.fullName, 'Ahmed Driver');
      expect(d.phone, '01035599526');
      expect(d.rating, 4.8);
      expect(d.tier, 'standard');
      expect(d.totalTrips, 12);
      expect(d.acceptanceRate, 100);
      expect(d.earningsLifetime, 44.43);
      expect(d.vehicle.display, 'Toyota Corolla');
      expect(d.vehicle.plateNumber, 'XYG-999');
      expect(d.documents.length, 5);
      expect(d.initials, 'AD');
    });

    test('derives status: all approved + active → approved', () {
      expect(DriverModel.fromJson(_driver()).status, DriverStatus.approved);
    });

    test('derives status: a non-approved document → pending', () {
      final d = DriverModel.fromJson(_driver(licenseStatus: 'pending'));
      expect(d.status, DriverStatus.pending);
    });

    test('derives status: inactive user → blocked (overrides docs)', () {
      final d = DriverModel.fromJson(_driver(active: false));
      expect(d.status, DriverStatus.blocked);
    });

    test('documents are ordered by DocType and typed', () {
      final d = DriverModel.fromJson(_driver(licenseStatus: 'rejected'));
      expect(d.documents.map((x) => x.type).toList(), DocType.values);
      final lic = d.doc(DocType.drivingLicense);
      expect(lic.isRejected, isTrue);
      expect(lic.hasImage, isFalse);
    });

    test('survives a sparse payload without throwing', () {
      final d = DriverModel.fromJson({'_id': 'x'});
      expect(d.fullName, '—');
      expect(d.documents.length, 5);
      expect(d.documents.first.status, 'pending');
      expect(d.status, DriverStatus.pending);
    });
  });

  group('DriverDocument', () {
    test('hasImage reflects a Cloudinary url', () {
      final withUrl = DriverDocument.fromJson(
        DocType.nationalId,
        {'status': 'submitted', 'url': 'https://res.cloudinary.com/x.jpg'},
      );
      expect(withUrl.hasImage, isTrue);
      expect(withUrl.url, contains('cloudinary'));
    });
  });
}
