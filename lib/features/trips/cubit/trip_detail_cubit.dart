import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_error.dart';
import '../data/models/trip_model.dart';
import '../data/repos/trips_repo.dart';

part 'trip_detail_state.dart';

class TripActionResult {
  const TripActionResult(this.message, {this.isError = false});
  final String message;
  final bool isError;
}

/// Owns one trip's detail screen and the manual fare-override action.
class TripDetailCubit extends Cubit<TripDetailState> {
  TripDetailCubit(this._repo, this.tripId) : super(const TripDetailState());

  final TripsRepo _repo;
  final String tripId;

  final _results = StreamController<TripActionResult>.broadcast();
  Stream<TripActionResult> get results => _results.stream;

  Future<void> load() async {
    emit(state.copyWith(status: DetailStatus.loading, clearError: true));
    try {
      final trip = await _repo.detail(tripId);
      emit(state.copyWith(status: DetailStatus.ready, trip: trip));
    } on ApiError catch (e) {
      emit(state.copyWith(status: DetailStatus.error, error: e.message));
    }
  }

  Future<void> overrideFare(double total, String reason) async {
    if (state.busyFare) return;
    emit(state.copyWith(busyFare: true));
    try {
      final trip =
          await _repo.overrideFare(id: tripId, total: total, reason: reason);
      emit(state.copyWith(
          busyFare: false, status: DetailStatus.ready, trip: trip));
      _results.add(const TripActionResult('Fare overridden'));
    } on ApiError catch (e) {
      emit(state.copyWith(busyFare: false));
      _results.add(TripActionResult(e.message, isError: true));
    }
  }

  @override
  Future<void> close() {
    _results.close();
    return super.close();
  }
}
