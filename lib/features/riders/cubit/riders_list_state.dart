part of 'riders_list_cubit.dart';

/// The filter tabs. `all` sends no status param; the rest map 1:1 to the
/// backend's `?status=` values.
enum RiderFilter {
  all('All', null),
  active('Active', 'active'),
  blocked('Blocked', 'blocked');

  const RiderFilter(this.label, this.query);
  final String label;
  final String? query;
}

enum ListStatus { loading, ready, error }

class RidersListState extends Equatable {
  const RidersListState({
    this.status = ListStatus.loading,
    this.filter = RiderFilter.all,
    this.riders = const [],
    this.page = 1,
    this.pages = 1,
    this.total = 0,
    this.counts = const RiderCounts(),
    this.error,
  });

  final ListStatus status;
  final RiderFilter filter;
  final List<RiderModel> riders;
  final int page;
  final int pages;
  final int total;
  final RiderCounts counts;
  final String? error;

  bool get isEmpty => status == ListStatus.ready && riders.isEmpty;
  bool get hasPrev => page > 1;
  bool get hasNext => page < pages;

  int countFor(RiderFilter f) => switch (f) {
        RiderFilter.all => counts.all,
        RiderFilter.blocked => counts.blocked,
        RiderFilter.active => counts.all - counts.blocked,
      };

  RidersListState copyWith({
    ListStatus? status,
    RiderFilter? filter,
    List<RiderModel>? riders,
    int? page,
    int? pages,
    int? total,
    RiderCounts? counts,
    String? error,
    bool clearError = false,
  }) =>
      RidersListState(
        status: status ?? this.status,
        filter: filter ?? this.filter,
        riders: riders ?? this.riders,
        page: page ?? this.page,
        pages: pages ?? this.pages,
        total: total ?? this.total,
        counts: counts ?? this.counts,
        error: clearError ? null : (error ?? this.error),
      );

  @override
  List<Object?> get props =>
      [status, filter, riders, page, pages, total, counts, error];
}
