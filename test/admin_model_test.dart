import 'package:flutter_test/flutter_test.dart';
import 'package:za2zo2a_admin/features/auth/data/models/admin_model.dart';

void main() {
  group('AdminModel.fromJson', () {
    // Captured from the live backend, POST /api/admin/auth/login.
    test('parses the login shape (no role field)', () {
      final admin = AdminModel.fromJson({
        'id': '6a5517048b362575a4309c12',
        'name': 'System Admin',
        'email': 'admin@za2zoo2a.com',
      });

      expect(admin.id, '6a5517048b362575a4309c12');
      expect(admin.name, 'System Admin');
      expect(admin.email, 'admin@za2zoo2a.com');
      expect(admin.role, isNull);
    });

    // Captured from the live backend, GET /api/admin/auth/me.
    test('parses the me shape (includes role)', () {
      final admin = AdminModel.fromJson({
        'id': '6a5517048b362575a4309c12',
        'name': 'System Admin',
        'email': 'admin@za2zoo2a.com',
        'role': 'admin',
      });

      expect(admin.role, 'admin');
    });

    test('falls back to Mongo _id / fullName keys', () {
      final admin = AdminModel.fromJson({
        '_id': 'abc123',
        'fullName': 'Someone Else',
        'email': 'x@y.com',
      });

      expect(admin.id, 'abc123');
      expect(admin.name, 'Someone Else');
    });

    test('survives a missing/empty payload without throwing', () {
      final admin = AdminModel.fromJson({});
      expect(admin.id, '');
      expect(admin.initials, '?');
    });
  });

  group('initials', () {
    test('takes first and last initial', () {
      const a = AdminModel(id: '1', name: 'System Admin', email: 'a@b.c');
      expect(a.initials, 'SA');
    });

    test('handles a single name', () {
      const a = AdminModel(id: '1', name: 'Anas', email: 'a@b.c');
      expect(a.initials, 'A');
    });

    test('ignores extra whitespace', () {
      const a = AdminModel(id: '1', name: '  Mostafa   Adel  ', email: 'a@b.c');
      expect(a.initials, 'MA');
    });
  });
}
