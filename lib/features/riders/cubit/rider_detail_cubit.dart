import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_error.dart';
import '../data/models/rider_model.dart';
import '../data/repos/riders_repo.dart';

part 'rider_detail_state.dart';

/// The outcome of an action, surfaced once as a toast by the view.
class RiderActionResult {
  const RiderActionResult(this.message, {this.isError = false});
  final String message;
  final bool isError;
}

/// Owns one rider's detail screen and its block/unblock action. After a
/// mutation it re-fetches the rider so the UI reflects real server state.
class RiderDetailCubit extends Cubit<RiderDetailState> {
  RiderDetailCubit(this._repo, this.riderId)
      : super(const RiderDetailState());

  final RidersRepo _repo;
  final String riderId;

  final _results = StreamController<RiderActionResult>.broadcast();
  Stream<RiderActionResult> get results => _results.stream;

  Future<void> load() async {
    emit(state.copyWith(status: DetailStatus.loading, clearError: true));
    try {
      final data = await _repo.detail(riderId);
      emit(state.copyWith(
        status: DetailStatus.ready,
        rider: data.rider,
        wallet: data.wallet,
        stats: data.stats,
      ));
    } on ApiError catch (e) {
      emit(state.copyWith(status: DetailStatus.error, error: e.message));
    }
  }

  Future<void> setBlocked(bool blocked, {String? reason}) async {
    if (state.busyBlock) return;
    emit(state.copyWith(busyBlock: true));
    try {
      await _repo.setBlocked(id: riderId, blocked: blocked, reason: reason);
      final fresh = await _repo.detail(riderId);
      emit(state.copyWith(
        busyBlock: false,
        status: DetailStatus.ready,
        rider: fresh.rider,
        wallet: fresh.wallet,
        stats: fresh.stats,
      ));
      _results.add(RiderActionResult(blocked ? 'Rider blocked' : 'Rider unblocked'));
    } on ApiError catch (e) {
      emit(state.copyWith(busyBlock: false));
      _results.add(RiderActionResult(e.message, isError: true));
    }
  }

  @override
  Future<void> close() {
    _results.close();
    return super.close();
  }
}
