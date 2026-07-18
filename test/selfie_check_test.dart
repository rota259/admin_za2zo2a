import 'package:flutter_test/flutter_test.dart';
import 'package:za2zo2a_admin/features/selfie/data/models/selfie_check.dart';

/// Captured from the live backend `GET /api/admin/selfie-checks`.
Map<String, dynamic> _selfie() => {
      '_id': '6a5771c36b80a7aa4aedc2f6',
      'driver': {
        '_id': '6a3e793153548ef08d288906',
        'fullName': 'Amr Wael',
        'email': 'rotawael222@gmail.com',
        'phone': '01551335599',
        'profilePhoto': 'https://res.cloudinary.com/dmsfxoble/image/upload/v1/p.jpg',
      },
      'photoUrl': 'https://res.cloudinary.com/x/image/upload/v1/selfie.jpg',
      'status': 'rejected',
      'createdAt': '2026-07-15T11:40:51.450Z',
      'reviewedAt': '2026-07-15T11:48:25.842Z',
      'rejectionReason': "Photo doesn't match the profile",
    };

void main() {
  group('SelfieCheck.fromJson', () {
    test('parses the real shape', () {
      final s = SelfieCheck.fromJson(_selfie());
      expect(s.id, '6a5771c36b80a7aa4aedc2f6');
      expect(s.driverName, 'Amr Wael');
      expect(s.driverPhone, '01551335599');
      expect(s.profilePhoto, contains('cloudinary'));
      expect(s.photoUrl, contains('selfie.jpg'));
      expect(s.status, 'rejected');
      expect(s.rejectionReason, "Photo doesn't match the profile");
      expect(s.submittedAt, isNotNull);
      expect(s.initials, 'AW');
    });

    test('handles a driver with no profile photo on file', () {
      final json = _selfie();
      (json['driver'] as Map).remove('profilePhoto');
      final s = SelfieCheck.fromJson(json);
      expect(s.profilePhoto, isNull);
      expect(s.photoUrl, isNotEmpty);
    });

    test('survives a sparse payload', () {
      final s = SelfieCheck.fromJson({'_id': 'x', 'photoUrl': 'u'});
      expect(s.driverName, '—');
      expect(s.status, 'pending_review');
      expect(s.photoUrl, 'u');
    });

    test('initials falls back to ? for a truly empty name', () {
      final s = SelfieCheck.fromJson({
        '_id': 'x',
        'driver': {'fullName': ''},
      });
      expect(s.initials, '?');
    });
  });
}
