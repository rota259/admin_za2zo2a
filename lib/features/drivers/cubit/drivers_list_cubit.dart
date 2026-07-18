import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_error.dart';
import '../data/models/driver_model.dart';
import '../data/repos/drivers_repo.dart';

part 'drivers_list_state.dart';

/// Owns the drivers-list screen: current filter, page, rows and tab counts.
class DriversListCubit extends Cubit<DriversListState> {
  DriversListCubit(this._repo) : super(const DriversListState());

  final DriversRepo _repo;

  /// Initial load (and retry): fetch page 1 for the current filter plus the
  /// live tab counts. Counts failing must not blank the list, so they load
  /// independently.
  Future<void> load() async {
    emit(state.copyWith(status: ListStatus.loading, clearError: true));
    try {
      final page = await _repo.list(status: state.filter.query, page: 1);
      emit(state.copyWith(
        status: ListStatus.ready,
        drivers: page.drivers,
        page: page.page,
        pages: page.pages,
        total: page.total,
      ));
    } on ApiError catch (e) {
      emit(state.copyWith(status: ListStatus.error, error: e.message));
    }
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    try {
      emit(state.copyWith(counts: await _repo.counts()));
    } on ApiError {
      // Leave counts at their last value; the tabs still work.
    }
  }

  Future<void> selectFilter(DriverFilter filter) async {
    if (filter == state.filter) return;
    emit(state.copyWith(filter: filter, page: 1));
    await _fetchPage(1);
  }

  Future<void> nextPage() async {
    if (state.hasNext) await _fetchPage(state.page + 1);
  }

  Future<void> prevPage() async {
    if (state.hasPrev) await _fetchPage(state.page - 1);
  }

  Future<void> _fetchPage(int page) async {
    emit(state.copyWith(status: ListStatus.loading, clearError: true));
    try {
      final result =
          await _repo.list(status: state.filter.query, page: page);
      emit(state.copyWith(
        status: ListStatus.ready,
        drivers: result.drivers,
        page: result.page,
        pages: result.pages,
        total: result.total,
      ));
    } on ApiError catch (e) {
      emit(state.copyWith(status: ListStatus.error, error: e.message));
    }
  }

  /// Called after an action on the detail screen changed a driver, so the list
  /// and counts stay truthful when the operator returns.
  Future<void> refresh() => _fetchPage(state.page).then((_) => _loadCounts());
}
