import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../services/session_manager.dart';
import 'api_endpoints.dart';

/// Configured dio for the Za2zo2a backend.
///
/// Ported from the mobile app's `DioClient`, keeping both of its hard-won
/// properties:
///  - the JWT is attached only to OUR host, never to absolute third-party URLs
///    (Cloudinary image hosts are hit directly by the browser for driver docs);
///  - retries run on a SEPARATE interceptor-free dio. Re-entering the main dio
///    from inside its own `onError` deadlocks the request — do not "simplify"
///    this into a single dio.
class DioClient {
  /// Wired by `main()` to clear state and route to /login on 401.
  static FutureOr<void> Function()? onUnauthorized;

  static const int _maxRetries = 2;

  // All three timeouts MUST be set; an unreachable host otherwise hangs forever.
  static const Duration _connectTimeout = Duration(seconds: 15);
  static const Duration _sendTimeout = Duration(seconds: 15);
  static const Duration _receiveTimeout = Duration(seconds: 20);

  final SessionManager _session;
  late final Dio _dio;

  /// Interceptor-free dio, used only to re-issue a request during retry.
  late final Dio _retryDio;

  Dio get dio => _dio;

  DioClient(this._session, {Dio? dio}) {
    final baseOptions = BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: _connectTimeout,
      sendTimeout: _sendTimeout,
      receiveTimeout: _receiveTimeout,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    _dio = dio ?? Dio(baseOptions);
    _retryDio = Dio(baseOptions);

    if (kDebugMode) {
      debugPrint('[DioClient] BASE_URL: ${ApiEndpoints.baseUrl}');
    }

    // Plain InterceptorsWrapper (NOT Queued*) — queuing deadlocks the retry path.
    _dio.interceptors.add(
      InterceptorsWrapper(onRequest: _onRequest, onError: _onError),
    );
  }

  bool _isBackendRequest(RequestOptions options) {
    final uri = options.uri;
    final base = Uri.parse(ApiEndpoints.baseUrl);
    return uri.host == base.host || !uri.hasScheme;
  }

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_isBackendRequest(options)) {
      final token = await _session.readToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  Future<void> _onError(
    DioException e,
    ErrorInterceptorHandler handler,
  ) async {
    // 401 → session is dead: wipe and bounce to login.
    if (e.response?.statusCode == 401) {
      await _session.clear();
      try {
        await onUnauthorized?.call();
      } catch (err) {
        if (kDebugMode) debugPrint('onUnauthorized handler failed: $err');
      }
      return handler.next(e);
    }

    if (_shouldRetry(e)) {
      final attempt = (e.requestOptions.extra['retry_attempt'] as int?) ?? 0;
      if (attempt < _maxRetries) {
        await Future.delayed(Duration(milliseconds: 400 * (1 << attempt)));
        for (var next = attempt + 1; next <= _maxRetries; next++) {
          e.requestOptions.extra['retry_attempt'] = next;
          try {
            final response = await _retryDio.fetch(e.requestOptions);
            return handler.resolve(response);
          } on DioException catch (retryErr) {
            if (next >= _maxRetries || !_shouldRetry(retryErr)) {
              return handler.next(retryErr);
            }
            await Future.delayed(Duration(milliseconds: 400 * (1 << next)));
          }
        }
      }
    }

    handler.next(e);
  }

  bool _shouldRetry(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.unknown:
        return e.response == null; // socket-level failure, no HTTP response
      default:
        return false;
    }
  }
}
