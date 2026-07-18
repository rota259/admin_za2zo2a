import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:za2zo2a_admin/core/network/dio_client.dart';
import 'package:za2zo2a_admin/core/services/session_manager.dart';

/// A dio adapter that returns a fixed status for every request — lets us feed
/// a real 401 through DioClient's interceptor without a server.
class _StatusAdapter implements HttpClientAdapter {
  _StatusAdapter(this.status);
  final int status;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString('{"success":false,"message":"expired"}',
        status, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Stub secure storage so SessionManager can read/write in the harness.
    final store = <String, String>{};
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (call) async {
        switch (call.method) {
          case 'write':
            store[call.arguments['key'] as String] =
                call.arguments['value'] as String;
            return null;
          case 'read':
            return store[call.arguments['key']];
          case 'delete':
            store.remove(call.arguments['key']);
            return null;
          case 'readAll':
            return store;
          default:
            return null;
        }
      },
    );
  });

  test(
    'a mid-session 401 clears the session and fires onUnauthorized',
    () async {
      final session = SessionManager();
      await session.saveToken('valid-looking-but-server-rejects');
      expect(session.isLoggedIn, isTrue);

      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'))
        ..httpClientAdapter = _StatusAdapter(401);
      DioClient(session, dio: dio); // wires the 401 interceptor onto `dio`

      var unauthorizedCalled = false;
      DioClient.onUnauthorized = () => unauthorizedCalled = true;

      // Any authenticated request that the server rejects with 401.
      await expectLater(
        dio.get('/api/admin/drivers'),
        throwsA(isA<DioException>()),
      );

      // The interceptor must have wiped the session and signalled the app.
      expect(session.isLoggedIn, isFalse,
          reason: '401 should clear the stored token');
      expect(await session.readToken(), isNull);
      expect(unauthorizedCalled, isTrue,
          reason: 'onUnauthorized drives AuthCubit.onSessionExpired → guard '
              '→ /login');
    },
  );

  test('a non-401 error leaves the session intact', () async {
    final session = SessionManager();
    await session.saveToken('still-valid');

    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'))
      ..httpClientAdapter = _StatusAdapter(500);
    DioClient(session, dio: dio);
    DioClient.onUnauthorized = () {};

    await expectLater(
      dio.get('/api/admin/drivers'),
      throwsA(isA<DioException>()),
    );

    expect(session.isLoggedIn, isTrue,
        reason: 'a 500 is not an auth failure — session must survive');
  });
}
