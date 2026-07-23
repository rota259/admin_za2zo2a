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

/// Live totals per `type` filter, for the tab counters.
class TripCounts {
  const TripCounts({this.all = 0, this.active = 0, this.history = 0});
  final int all;
  final int active;
  final int history;
}

/// Every admin trip operation, confirmed live via the project's Postman
/// collection ("Watch Active Trips" / "View Trip History" / "View All Trips"
/// / "Get Trip Details"). The list filter is `?type=active|history` (omit for
/// all) — not the `?status=<TripStatus>` shape an earlier internal spec doc
/// assumed. There is no fare-override endpoint.
class TripsRepo with RepositoryBase {
  TripsRepo(this._client);

  final DioClient _client;

  /// `GET /api/admin/trips?type=&page=&limit=`. [type] null → all trips,
  /// `'active'` → in-flight trips, `'history'` → finished trips.
  Future<TripPage> list({
    String? type,
    int page = 1,
    int limit = 20,
  }) async {
    return guard(() async {
      final res = await _client.dio.get(
        ApiEndpoints.adminTrips,
        queryParameters: {
          'type': ?type,
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

  /// Tab counters — a `limit=1` fetch per filter, run in parallel.
  Future<TripCounts> counts() async {
    return guard(() async {
      final results = await Future.wait([
        _total(type: null),
        _total(type: 'active'),
        _total(type: 'history'),
      ]);
      return TripCounts(all: results[0], active: results[1], history: results[2]);
    });
  }

  Future<int> _total({String? type}) async {
    final res = await _client.dio.get(
      ApiEndpoints.adminTrips,
      queryParameters: {'type': ?type, 'limit': 1},
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
}
