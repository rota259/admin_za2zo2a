import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/repository_base.dart';
import '../models/selfie_check.dart';

/// Admin selfie-review operations, wired to the real backend
/// (`adminRoutes.ts` — verified live).
class SelfieRepo with RepositoryBase {
  SelfieRepo(this._client);

  final DioClient _client;

  /// `GET /api/admin/selfie-checks?status=pending_review` (the default).
  Future<List<SelfieCheck>> pending() async {
    return guard(() async {
      final res = await _client.dio.get(
        ApiEndpoints.adminSelfieChecks,
        queryParameters: {'status': 'pending_review', 'limit': 50},
      );
      final list = (unwrap(res)['selfies'] as List?) ?? const [];
      return [
        for (final s in list)
          SelfieCheck.fromJson(Map<String, dynamic>.from(s as Map)),
      ];
    });
  }

  /// `PATCH /api/admin/selfie-checks/:id/review` — `status` approved|rejected;
  /// a reason is required to reject.
  Future<void> review({
    required String id,
    required bool approve,
    String? reason,
  }) async {
    return guard(() async {
      await _client.dio.patch(
        ApiEndpoints.adminSelfieCheckReview(id),
        data: {
          'status': approve ? 'approved' : 'rejected',
          if (reason != null && reason.isNotEmpty) 'reason': reason,
        },
      );
    });
  }
}
