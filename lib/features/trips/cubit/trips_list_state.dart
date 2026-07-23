part of 'trips_list_cubit.dart';

/// The filter tabs — confirmed live via the Postman collection: `all` sends
/// no `type` param, `active`/`history` map 1:1 to the backend's `?type=`
/// values ("Watch Active Trips" / "View Trip History").
enum TripFilter {
  all('All', null),
  active('Active', 'active'),
  history('History', 'history');

  const TripFilter(this.label, this.query);
  final String label;
  final String? query;
}

enum ListStatus { loading, ready, error }

class TripsListState extends Equatable {
  const TripsListState({
    this.status = ListStatus.loading,
    this.filter = TripFilter.all,
    this.trips = const [],
    this.page = 1,
    this.pages = 1,
    this.total = 0,
    this.counts = const TripCounts(),
    this.error,
  });

  final ListStatus status;
  final TripFilter filter;
  final List<TripModel> trips;
  final int page;
  final int pages;
  final int total;
  final TripCounts counts;
  final String? error;

  bool get isEmpty => status == ListStatus.ready && trips.isEmpty;
  bool get hasPrev => page > 1;
  bool get hasNext => page < pages;

  int countFor(TripFilter f) => switch (f) {
        TripFilter.all => counts.all,
        TripFilter.active => counts.active,
        TripFilter.history => counts.history,
      };

  TripsListState copyWith({
    ListStatus? status,
    TripFilter? filter,
    List<TripModel>? trips,
    int? page,
    int? pages,
    int? total,
    TripCounts? counts,
    String? error,
    bool clearError = false,
  }) =>
      TripsListState(
        status: status ?? this.status,
        filter: filter ?? this.filter,
        trips: trips ?? this.trips,
        page: page ?? this.page,
        pages: pages ?? this.pages,
        total: total ?? this.total,
        counts: counts ?? this.counts,
        error: clearError ? null : (error ?? this.error),
      );

  @override
  List<Object?> get props =>
      [status, filter, trips, page, pages, total, counts, error];
}
