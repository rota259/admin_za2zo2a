import 'package:dio/dio.dart';

import 'api_error.dart';

/// Mixin for repositories: runs a dio call and converts any failure into a
/// typed [ApiError]. Errors are never swallowed — they propagate so ViewModels
/// can render message / retry / redirect.
///
/// Ported from the mobile app's `core/network/repository_base.dart`.
mixin RepositoryBase {
  Future<T> guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on ApiError {
      rethrow;
    } on DioException catch (e) {
      throw ApiError.fromDio(e);
    } catch (e) {
      throw ApiError('Unexpected error: $e');
    }
  }

  /// Unwrap the backend's `{ success, message, data }` envelope.
  ///
  /// Verified uniform across every admin controller — they all return via
  /// `utils/apiResponse.ts#sendSuccess`. Falls back to the raw body if a
  /// response ever arrives unenveloped, rather than throwing.
  Map<String, dynamic> unwrap(Response<dynamic> res) {
    final body = res.data;
    if (body is! Map) {
      throw ApiError(
        'Unexpected response format from the server.',
        statusCode: res.statusCode,
        data: body,
      );
    }
    final data = body['data'];
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data == null && body.containsKey('data')) return <String, dynamic>{};
    return Map<String, dynamic>.from(body);
  }
}

/// Tolerant JSON access for variant response shapes.
/// Ported from the mobile app — Mongo documents surface `_id`, populated refs
/// arrive as either an id string or a nested object, so readers stay lenient.
extension JsonReader on Map<String, dynamic> {
  /// First non-null value among [keys]. Supports dotted paths ("user.fullName").
  dynamic pick(List<String> keys) {
    for (final key in keys) {
      final value = _dig(key);
      if (value != null) return value;
    }
    return null;
  }

  dynamic _dig(String key) {
    if (!key.contains('.')) return this[key];
    dynamic current = this;
    for (final part in key.split('.')) {
      if (current is Map && current.containsKey(part)) {
        current = current[part];
      } else {
        return null;
      }
    }
    return current;
  }

  String? str(List<String> keys) => pick(keys)?.toString();

  double? dbl(List<String> keys) {
    final v = pick(keys);
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  int? integer(List<String> keys) {
    final v = pick(keys);
    if (v == null) return null;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  bool? boolean(List<String> keys) {
    final v = pick(keys);
    if (v == null) return null;
    if (v is bool) return v;
    final s = v.toString().toLowerCase();
    if (s == 'true' || s == '1') return true;
    if (s == 'false' || s == '0') return false;
    return null;
  }

  Map<String, dynamic>? mapField(List<String> keys) {
    final v = pick(keys);
    return v is Map<String, dynamic>
        ? v
        : (v is Map ? Map<String, dynamic>.from(v) : null);
  }

  DateTime? date(List<String> keys) {
    final v = pick(keys);
    if (v == null) return null;
    return DateTime.tryParse(v.toString())?.toLocal();
  }
}
