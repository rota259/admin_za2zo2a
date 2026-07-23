import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_error.dart';
import '../data/models/trip_model.dart';
import '../data/repos/trips_repo.dart';

part 'trip_detail_state.dart';

/// Owns one trip's detail screen. `GET /api/admin/trips/:id` is confirmed
/// live; there is no fare-override endpoint yet, so this cubit is read-only.
class TripDetailCubit extends Cubit<TripDetailState> {
  TripDetailCubit(this._repo, this.tripId) : super(const TripDetailState());

  final TripsRepo _repo;
  final String tripId;

  Future<void> load() async {
    emit(state.copyWith(status: DetailStatus.loading, clearError: true));
    try {
      final trip = await _repo.detail(tripId);
      emit(state.copyWith(status: DetailStatus.ready, trip: trip));
    } on ApiError catch (e) {
      emit(state.copyWith(status: DetailStatus.error, error: e.message));
    }
  }
}
