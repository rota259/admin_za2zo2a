part of 'drivers_list_cubit.dart';

/// The filter tabs. `all` sends no status param; the rest map 1:1 to the
/// backend's `?status=` values.
enum DriverFilter {
  all('All', null),
  pending('Pending', 'pending'),
  approved('Approved', 'approved'),
  blocked('Blocked', 'blocked');

  const DriverFilter(this.label, this.query);
  final String label;
  final String? query;
}

enum ListStatus { loading, ready, error }

class DriversListState extends Equatable {
  const DriversListState({
    this.status = ListStatus.loading,
    this.filter = DriverFilter.all,
    this.drivers = const [],
    this.page = 1,
    this.pages = 1,
    this.total = 0,
    this.counts = const DriverCounts(),
    this.error,
  });

  final ListStatus status;
  final DriverFilter filter;
  final List<DriverModel> drivers;
  final int page;
  final int pages;
  final int total;
  final DriverCounts counts;
  final String? error;

  bool get isEmpty => status == ListStatus.ready && drivers.isEmpty;
  bool get hasPrev => page > 1;
  bool get hasNext => page < pages;

  int countFor(DriverFilter f) => switch (f) {
        DriverFilter.all => counts.all,
        DriverFilter.pending => counts.pending,
        DriverFilter.blocked => counts.blocked,
        // The backend's "approved" filter returns all drivers (no doc filter),
        // so its live count equals the total.
        DriverFilter.approved => counts.all,
      };

  DriversListState copyWith({
    ListStatus? status,
    DriverFilter? filter,
    List<DriverModel>? drivers,
    int? page,
    int? pages,
    int? total,
    DriverCounts? counts,
    String? error,
    bool clearError = false,
  }) =>
      DriversListState(
        status: status ?? this.status,
        filter: filter ?? this.filter,
        drivers: drivers ?? this.drivers,
        page: page ?? this.page,
        pages: pages ?? this.pages,
        total: total ?? this.total,
        counts: counts ?? this.counts,
        error: clearError ? null : (error ?? this.error),
      );

  @override
  List<Object?> get props =>
      [status, filter, drivers, page, pages, total, counts, error];
}
