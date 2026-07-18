import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/repository_base.dart';

/// Live counts behind the sidebar badges. Real data — no placeholders.
///
/// Both totals come from the `pagination.total` of the existing admin list
/// endpoints, fetched with `limit=1` so we pay for the count, not the rows:
///   GET /api/admin/drivers?status=pending&limit=1
///   GET /api/admin/selfie-checks?status=pending_review&limit=1
class NavCountsRepo with RepositoryBase {
  NavCountsRepo(this._client);

  final DioClient _client;

  Future<NavCounts> fetch() async {
    return guard(() async {
      final results = await Future.wait([
        _total(ApiEndpoints.adminDrivers, {'status': 'pending', 'limit': 1}),
        _total(ApiEndpoints.adminSelfieChecks,
            {'status': 'pending_review', 'limit': 1}),
      ]);
      return NavCounts(
        pendingDrivers: results[0],
        pendingSelfies: results[1],
      );
    });
  }

  Future<int> _total(String path, Map<String, dynamic> query) async {
    final res = await _client.dio.get(path, queryParameters: query);
    return unwrap(res).integer(['pagination.total']) ?? 0;
  }
}

class NavCounts {
  const NavCounts({this.pendingDrivers = 0, this.pendingSelfies = 0});

  final int pendingDrivers;
  final int pendingSelfies;

  /// Badge for a nav path, or 0 when that section has no counter.
  int forPath(String path) => switch (path) {
        '/approval' => pendingDrivers,
        '/selfie' => pendingSelfies,
        _ => 0,
      };
}
