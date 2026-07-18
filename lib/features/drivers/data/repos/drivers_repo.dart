import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_error.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/repository_base.dart';
import '../models/driver_model.dart';

/// One page of the driver list plus its pagination.
class DriverPage {
  const DriverPage({
    required this.drivers,
    required this.page,
    required this.pages,
    required this.total,
  });

  final List<DriverModel> drivers;
  final int page;
  final int pages;
  final int total;
}

/// Live totals per filter, for the tab counters.
class DriverCounts {
  const DriverCounts({this.all = 0, this.pending = 0, this.blocked = 0});
  final int all;
  final int pending;
  final int blocked;
}

/// Every admin driver operation, wired to the real backend
/// (`adminRoutes.ts` — all verified live in Stage 0).
class DriversRepo with RepositoryBase {
  DriversRepo(this._client);

  final DioClient _client;

  /// `GET /api/admin/drivers?status=&page=&limit=`
  /// [status] null → all drivers. Values: pending | approved | blocked.
  Future<DriverPage> list({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    return guard(() async {
      final res = await _client.dio.get(
        ApiEndpoints.adminDrivers,
        queryParameters: {
          'status': ?status,
          'page': page,
          'limit': limit,
        },
      );
      final data = unwrap(res);
      final pagination = data.mapField(['pagination']) ?? const {};
      final list = (data['drivers'] as List?) ?? const [];
      return DriverPage(
        drivers: [
          for (final d in list)
            DriverModel.fromJson(Map<String, dynamic>.from(d as Map)),
        ],
        page: pagination.integer(['page']) ?? page,
        pages: pagination.integer(['pages']) ?? 1,
        total: pagination.integer(['total']) ?? list.length,
      );
    });
  }

  /// Tab counters — a `limit=1` fetch per filter, run in parallel so we pay for
  /// the totals, not the rows. (The backend has no dedicated count endpoint.)
  Future<DriverCounts> counts() async {
    return guard(() async {
      final results = await Future.wait([
        _total(status: null),
        _total(status: 'pending'),
        _total(status: 'blocked'),
      ]);
      return DriverCounts(
        all: results[0],
        pending: results[1],
        blocked: results[2],
      );
    });
  }

  Future<int> _total({String? status}) async {
    final res = await _client.dio.get(
      ApiEndpoints.adminDrivers,
      queryParameters: {'status': ?status, 'limit': 1},
    );
    return unwrap(res).integer(['pagination.total']) ?? 0;
  }

  /// `GET /api/admin/drivers/:id` → the full driver (latestSelfie handled by
  /// the selfie feature, ignored here).
  Future<DriverModel> detail(String id) async {
    return guard(() async {
      final res = await _client.dio.get(ApiEndpoints.adminDriver(id));
      final driver = unwrap(res).mapField(['driver']);
      if (driver == null) {
        throw const ApiError('Driver not found.', statusCode: 404);
      }
      return DriverModel.fromJson(driver);
    });
  }

  /// `PATCH /api/admin/drivers/:id/documents/:docType/review`
  /// [reason] is required by the backend when rejecting.
  Future<void> reviewDocument({
    required String driverId,
    required String docType,
    required bool approve,
    String? reason,
  }) async {
    return guard(() async {
      await _client.dio.patch(
        ApiEndpoints.adminDriverDocumentReview(driverId, docType),
        data: {
          'status': approve ? 'approved' : 'rejected',
          if (reason != null && reason.isNotEmpty) 'reason': reason,
        },
      );
    });
  }

  /// `PATCH /api/admin/drivers/:id/approve` — approves all documents and marks
  /// the driver verified.
  Future<void> approveDriver(String id) async {
    return guard(() async {
      await _client.dio.patch(ApiEndpoints.adminDriverApprove(id));
    });
  }

  /// `PATCH /api/admin/drivers/:id/block` — `blocked: true` deactivates and
  /// forces offline; `false` reactivates. A reason is required to block.
  Future<void> setBlocked({
    required String id,
    required bool blocked,
    String? reason,
  }) async {
    return guard(() async {
      await _client.dio.patch(
        ApiEndpoints.adminDriverBlock(id),
        data: {
          'blocked': blocked,
          if (reason != null && reason.isNotEmpty) 'reason': reason,
        },
      );
    });
  }
}
