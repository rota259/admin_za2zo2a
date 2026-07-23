part of 'trips_list_cubit.dart';

/// The filter tabs. `all` sends no status param; the rest map 1:1 to real
/// `TripStatus` enum values the backend accepts.
enum TripFilter {
  all('All', null),
  requested('Requested', 'requested'),
  accepted('Accepted', 'accepted'),
  inProgress('In progress', 'in_progress'),
  completed('Completed', 'completed'),
  cancelled('Cancelled', 'cancelled');

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
        TripFilter.requested => counts.requested,
        TripFilter.accepted => counts.accepted,
        TripFilter.inProgress => counts.inProgress,
        TripFilter.completed => counts.completed,
        TripFilter.cancelled => counts.cancelled,
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
