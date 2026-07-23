import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_error.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/repository_base.dart';
import '../models/rider_model.dart';

/// A rider's full detail: the rider plus wallet and trip stats.
class RiderDetailData {
  const RiderDetailData({
    required this.rider,
    required this.wallet,
    required this.stats,
  });
  final RiderModel rider;
  final RiderWallet wallet;
  final RiderStats stats;
}

/// One page of the rider list plus its pagination.
class RiderPage {
  const RiderPage({
    required this.riders,
    required this.page,
    required this.pages,
    required this.total,
  });

  final List<RiderModel> riders;
  final int page;
  final int pages;
  final int total;
}

/// Live totals per filter, for the tab counters.
class RiderCounts {
  const RiderCounts({this.all = 0, this.blocked = 0});
  final int all;
  final int blocked;
}

/// Every admin rider operation, per `docs/backend-admin-api-spec.md` §1.
class RidersRepo with RepositoryBase {
  RidersRepo(this._client);

  final DioClient _client;

  /// `GET /api/admin/riders?status=&page=&limit=`
  /// [status] null → all riders. Values: active | blocked.
  Future<RiderPage> list({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    return guard(() async {
      final res = await _client.dio.get(
        ApiEndpoints.adminRiders,
        queryParameters: {
          'status': ?status,
          'page': page,
          'limit': limit,
        },
      );
      final data = unwrap(res);
      final pagination = data.mapField(['pagination']) ?? const {};
      final list = (data['riders'] as List?) ?? const [];
      return RiderPage(
        riders: [
          for (final r in list)
            RiderModel.fromJson(Map<String, dynamic>.from(r as Map)),
        ],
        page: pagination.integer(['page']) ?? page,
        pages: pagination.integer(['pages']) ?? 1,
        total: pagination.integer(['total']) ?? list.length,
      );
    });
  }

  /// Tab counters — a `limit=1` fetch per filter, run in parallel.
  Future<RiderCounts> counts() async {
    return guard(() async {
      final results = await Future.wait([
        _total(status: null),
        _total(status: 'blocked'),
      ]);
      return RiderCounts(all: results[0], blocked: results[1]);
    });
  }

  Future<int> _total({String? status}) async {
    final res = await _client.dio.get(
      ApiEndpoints.adminRiders,
      queryParameters: {'status': ?status, 'limit': 1},
    );
    return unwrap(res).integer(['pagination.total']) ?? 0;
  }

  /// `GET /api/admin/riders/:id` → rider + wallet + stats.
  Future<RiderDetailData> detail(String id) async {
    return guard(() async {
      final res = await _client.dio.get(ApiEndpoints.adminRider(id));
      final data = unwrap(res);
      final rider = data.mapField(['rider']);
      if (rider == null) {
        throw const ApiError('Rider not found.', statusCode: 404);
      }
      return RiderDetailData(
        rider: RiderModel.fromJson(rider),
        wallet: RiderWallet.fromJson(data.mapField(['wallet'])),
        stats: RiderStats.fromJson(data.mapField(['stats'])),
      );
    });
  }

  /// `PATCH /api/admin/riders/:id/block`. A reason is required to block.
  Future<void> setBlocked({
    required String id,
    required bool blocked,
    String? reason,
  }) async {
    return guard(() async {
      await _client.dio.patch(
        ApiEndpoints.adminRiderBlock(id),
        data: {
          'blocked': blocked,
          if (reason != null && reason.isNotEmpty) 'reason': reason,
        },
      );
    });
  }
}
