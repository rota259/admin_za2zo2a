import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_error.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/repository_base.dart';
import '../../../../core/services/session_manager.dart';
import '../models/admin_model.dart';

/// Admin authentication against the real backend.
///
/// Contract verified live:
///   POST /api/admin/auth/login  { email, password }
///     200 → { success, message, data: { token, admin } }
///     401 → invalid credentials
///     403 → valid credentials but the user is not an admin
///   GET  /api/admin/auth/me     → { success, message, data: { admin } }
class AuthRepo with RepositoryBase {
  AuthRepo(this._client, this._session);

  final DioClient _client;
  final SessionManager _session;

  /// Sign in and persist the token. Throws [ApiError] on failure.
  Future<AdminModel> login({
    required String email,
    required String password,
  }) async {
    return guard(() async {
      final res = await _client.dio.post(
        ApiEndpoints.adminLogin,
        data: {'email': email.trim(), 'password': password},
      );

      final data = unwrap(res);
      final token = data.str(['token']);
      if (token == null || token.isEmpty) {
        throw const ApiError('Sign-in succeeded but no token was returned.');
      }

      final adminJson = data.mapField(['admin']);
      if (adminJson == null) {
        throw const ApiError('Sign-in succeeded but no profile was returned.');
      }

      final admin = AdminModel.fromJson(adminJson);

      // Order matters: persist the token before anything else fires a
      // request, so the interceptor can attach it.
      await _session.saveToken(token);
      await _session.saveAdmin(admin.toJson());
      return admin;
    });
  }

  /// Restore the session on refresh. Verifies the stored token is still valid
  /// server-side rather than trusting its presence.
  Future<AdminModel> me() async {
    return guard(() async {
      final res = await _client.dio.get(ApiEndpoints.adminMe);
      final adminJson = unwrap(res).mapField(['admin']);
      if (adminJson == null) {
        throw const ApiError('Could not load the admin profile.');
      }
      final admin = AdminModel.fromJson(adminJson);
      await _session.saveAdmin(admin.toJson());
      return admin;
    });
  }

  Future<void> logout() => _session.clear();

  bool get isLoggedIn => _session.isLoggedIn;
}
