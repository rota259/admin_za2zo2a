import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_error.dart';
import '../data/models/trip_model.dart';
import '../data/repos/trips_repo.dart';

part 'trips_list_state.dart';

/// Owns the trips-list screen: current status filter, page, rows and counts.
class TripsListCubit extends Cubit<TripsListState> {
  TripsListCubit(this._repo) : super(const TripsListState());

  final TripsRepo _repo;

  Future<void> load() async {
    emit(state.copyWith(status: ListStatus.loading, clearError: true));
    try {
      final page = await _repo.list(status: state.filter.query, page: 1);
      emit(state.copyWith(
        status: ListStatus.ready,
        trips: page.trips,
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

  Future<void> selectFilter(TripFilter filter) async {
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
      final result = await _repo.list(status: state.filter.query, page: page);
      emit(state.copyWith(
        status: ListStatus.ready,
        trips: result.trips,
        page: result.page,
        pages: result.pages,
        total: result.total,
      ));
    } on ApiError catch (e) {
      emit(state.copyWith(status: ListStatus.error, error: e.message));
    }
  }

  Future<void> refresh() => _fetchPage(state.page).then((_) => _loadCounts());
}
