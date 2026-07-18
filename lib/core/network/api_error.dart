import 'package:dio/dio.dart';

/// A typed, presentable error surfaced by every repository.
///
/// Adapted from the mobile app's `core/network/api_error.dart`. Repos never
/// throw raw [DioException]s and never swallow errors — they convert via
/// [ApiError.fromDio] so ViewModels get a clean message plus the status code.
///
/// The rider-only 402 "wallet blocked" case is dropped; the admin console has
/// no wallet. 403 matters more here — it's what the backend returns when a
/// valid non-admin token hits an /api/admin route.
class ApiError implements Exception {
  /// Human-readable message, safe to show inline.
  final String message;

  /// HTTP status code, or null for connectivity/timeout errors.
  final int? statusCode;

  /// True when there was no server response (network/timeout), so the UI can
  /// offer a retry affordance rather than a validation message.
  final bool isNetwork;

  /// Raw response body, for structured fields the message string doesn't carry.
  final dynamic data;

  const ApiError(
    this.message, {
    this.statusCode,
    this.isNetwork = false,
    this.data,
  });

  /// Token missing/expired/invalid — the router bounces to login.
  bool get isUnauthorized => statusCode == 401;

  /// Authenticated but not an admin (backend's `restrictTo(ADMIN)`).
  bool get isForbidden => statusCode == 403;

  bool get isValidation => statusCode == 400 || statusCode == 422;

  factory ApiError.network([String? message]) => ApiError(
        message ?? 'No connection. Check your network and try again.',
        isNetwork: true,
      );

  factory ApiError.fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return ApiError.network('The server took too long to respond.');
      case DioExceptionType.connectionError:
        return ApiError.network();
      case DioExceptionType.cancel:
        return const ApiError('Request cancelled.');
      case DioExceptionType.badCertificate:
        return const ApiError('Could not establish a secure connection.');
      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
        final status = e.response?.statusCode;
        final data = e.response?.data;
        return ApiError(
          _extractMessage(data) ?? _defaultForStatus(status),
          statusCode: status,
          isNetwork: e.type == DioExceptionType.unknown && e.response == null,
          data: data,
        );
    }
  }

  /// The backend's `sendSuccess`/`ApiError` shape is `{ success, message }`,
  /// but express-validator failures come back as `{ errors: [{ msg }] }`.
  /// Pull whatever human text exists without hard-failing.
  static String? _extractMessage(dynamic data) {
    if (data == null) return null;
    if (data is String && data.trim().isNotEmpty) return data;
    if (data is Map) {
      for (final key in const ['message', 'error', 'msg', 'detail']) {
        final v = data[key];
        if (v is String && v.trim().isNotEmpty) return v;
        if (v is Map && v['message'] is String) return v['message'] as String;
      }
      final errors = data['errors'];
      if (errors is List && errors.isNotEmpty) {
        final first = errors.first;
        if (first is Map && first['msg'] is String) {
          return first['msg'] as String;
        }
        if (first is String) return first;
      }
    }
    return null;
  }

  static String _defaultForStatus(int? status) {
    switch (status) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Your session has expired. Please sign in again.';
      case 403:
        return 'Access denied — admin only.';
      case 404:
        return 'Not found.';
      case 409:
        return 'Conflict — this action could not be completed.';
      case 422:
        return 'Validation failed. Please check your input.';
      case 429:
        return 'Too many attempts. Please wait a moment and try again.';
      case 500:
      case 502:
      case 503:
        return 'Server error. Please try again shortly.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  @override
  String toString() => 'ApiError($statusCode): $message';
}
