import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_error.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/repository_base.dart';
import '../models/trip_model.dart';

/// One page of the trip list plus its pagination.
class TripPage {
  const TripPage({
    required this.trips,
    required this.page,
    required this.pages,
    required this.total,
  });

  final List<TripModel> trips;
  final int page;
  final int pages;
  final int total;
}

/// Live totals per status filter, for the tab counters. Each maps to one
/// genuine backend `?status=` value — no client-side combining of statuses.
class TripCounts {
  const TripCounts({
    this.all = 0,
    this.requested = 0,
    this.accepted = 0,
    this.inProgress = 0,
    this.completed = 0,
    this.cancelled = 0,
  });
  final int all;
  final int requested;
  final int accepted;
  final int inProgress;
  final int completed;
  final int cancelled;
}

/// Every admin trip operation, per `docs/backend-admin-api-spec.md` §2.
class TripsRepo with RepositoryBase {
  TripsRepo(this._client);

  final DioClient _client;

  /// `GET /api/admin/trips?status=&page=&limit=`. [status] null → all trips.
  Future<TripPage> list({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    return guard(() async {
      final res = await _client.dio.get(
        ApiEndpoints.adminTrips,
        queryParameters: {
          'status': ?status,
          'page': page,
          'limit': limit,
        },
      );
      final data = unwrap(res);
      final pagination = data.mapField(['pagination']) ?? const {};
      final list = (data['trips'] as List?) ?? const [];
      return TripPage(
        trips: [
          for (final t in list)
            TripModel.fromJson(Map<String, dynamic>.from(t as Map)),
        ],
        page: pagination.integer(['page']) ?? page,
        pages: pagination.integer(['pages']) ?? 1,
        total: pagination.integer(['total']) ?? list.length,
      );
    });
  }

  /// Tab counters — a `limit=1` fetch per filter, run in parallel so we pay
  /// for the totals, not the rows.
  Future<TripCounts> counts() async {
    return guard(() async {
      final results = await Future.wait([
        _total(status: null),
        _total(status: 'requested'),
        _total(status: 'accepted'),
        _total(status: 'in_progress'),
        _total(status: 'completed'),
        _total(status: 'cancelled'),
      ]);
      return TripCounts(
        all: results[0],
        requested: results[1],
        accepted: results[2],
        inProgress: results[3],
        completed: results[4],
        cancelled: results[5],
      );
    });
  }

  Future<int> _total({String? status}) async {
    final res = await _client.dio.get(
      ApiEndpoints.adminTrips,
      queryParameters: {'status': ?status, 'limit': 1},
    );
    return unwrap(res).integer(['pagination.total']) ?? 0;
  }

  /// `GET /api/admin/trips/:id` → the full trip (not owner-scoped).
  Future<TripModel> detail(String id) async {
    return guard(() async {
      final res = await _client.dio.get(ApiEndpoints.adminTrip(id));
      final data = unwrap(res);
      final trip = data.mapField(['trip']);
      if (trip == null) {
        throw const ApiError('Trip not found.', statusCode: 404);
      }
      return TripModel.fromJson(trip);
    });
  }

  /// `PATCH /api/admin/trips/:id/fare` — manual fare override. `409` if the
  /// trip is cancelled.
  Future<TripModel> overrideFare({
    required String id,
    required double total,
    required String reason,
  }) async {
    return guard(() async {
      final res = await _client.dio.patch(
        ApiEndpoints.adminTripFare(id),
        data: {'total': total, 'reason': reason},
      );
      final data = unwrap(res);
      final trip = data.mapField(['trip']);
      return trip == null ? await detail(id) : TripModel.fromJson(trip);
    });
  }
}
