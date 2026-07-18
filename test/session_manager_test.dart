import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:za2zo2a_admin/core/services/session_manager.dart';

/// Regression cover for a real failure found while testing Stage 1 by hand:
/// a corrupt secure-storage payload made `read` throw, the exception escaped
/// `main()`, and the app booted to a blank page instead of the login screen.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  void mockStorage({required bool throwOnRead}) {
    final store = <String, String>{};
    messenger.setMockMethodCallHandler(channel, (call) async {
      switch (call.method) {
        case 'read':
          if (throwOnRead) {
            throw PlatformException(code: 'DecryptError', message: 'corrupt');
          }
          return store[call.arguments['key']];
        case 'write':
          store[call.arguments['key'] as String] =
              call.arguments['value'] as String;
          return null;
        case 'delete':
          store.remove(call.arguments['key']);
          return null;
        case 'readAll':
          return store;
        default:
          return null;
      }
    });
  }

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  group('bootstrap', () {
    test('reads a stored token', () async {
      mockStorage(throwOnRead: false);
      final session = SessionManager();
      await session.saveToken('abc123');
      await session.bootstrap();

      expect(session.isLoggedIn, isTrue);
      expect(session.cachedToken, 'abc123');
    });

    test('treats a corrupt store as no session instead of throwing', () async {
      mockStorage(throwOnRead: true);
      final session = SessionManager();

      await expectLater(session.bootstrap(), completes);
      expect(session.isLoggedIn, isFalse);
      expect(session.cachedToken, isNull);
    });

    test('readToken returns null on a corrupt store', () async {
      mockStorage(throwOnRead: true);
      final session = SessionManager();

      expect(await session.readToken(), isNull);
    });

    test('readDarkMode falls back to light on a corrupt store', () async {
      mockStorage(throwOnRead: true);
      final session = SessionManager();

      expect(await session.readDarkMode(), isFalse);
    });
  });

  test('clear wipes the in-memory token', () async {
    mockStorage(throwOnRead: false);
    final session = SessionManager();
    await session.saveToken('abc123');
    expect(session.isLoggedIn, isTrue);

    await session.clear();
    expect(session.isLoggedIn, isFalse);
  });
}
