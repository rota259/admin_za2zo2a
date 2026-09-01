import 'api_endpoints.dart';

/// Resolves a media path returned by the backend into an absolute URL.
///
/// Absolute URLs (Cloudinary, any http/https) pass through unchanged.
/// Relative paths — e.g. `/uploads/nationalId/…png`, which the backend serves
/// from its own host — get the API base URL prepended, so the admin (served
/// from a different origin) can actually load them.
String? mediaUrl(String? path) {
  if (path == null || path.isEmpty) return null;
  if (path.startsWith('http://') || path.startsWith('https://')) return path;
  final base = ApiEndpoints.baseUrl.replaceAll(RegExp(r'/+$'), '');
  final rel = path.startsWith('/') ? path : '/$path';
  return '$base$rel';
}
