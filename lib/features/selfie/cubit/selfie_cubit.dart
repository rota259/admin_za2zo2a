import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_error.dart';
import '../data/models/selfie_check.dart';
import '../data/repos/selfie_repo.dart';

part 'selfie_state.dart';

class SelfieResult {
  const SelfieResult(this.message, {this.isError = false});
  final String message;
  final bool isError;
}

/// The selfie-verification queue. Loads pending checks and approves/rejects
/// each against the real review endpoint, re-fetching so a reviewed selfie
/// leaves the queue.
class SelfieCubit extends Cubit<SelfieState> {
  SelfieCubit(this._repo) : super(const SelfieState());

  final SelfieRepo _repo;

  final _results = StreamController<SelfieResult>.broadcast();
  Stream<SelfieResult> get results => _results.stream;

  Future<void> load() async {
    emit(state.copyWith(status: SelfieStatus.loading, clearError: true));
    try {
      emit(state.copyWith(
          status: SelfieStatus.ready, checks: await _repo.pending()));
    } on ApiError catch (e) {
      emit(state.copyWith(status: SelfieStatus.error, error: e.message));
    }
  }

  Future<void> review(SelfieCheck check, bool approve, {String? reason}) async {
    if (state.busyId != null) return;
    emit(state.copyWith(busyId: check.id));
    try {
      await _repo.review(id: check.id, approve: approve, reason: reason);
      _results.add(SelfieResult(
          'Selfie for ${check.driverName} ${approve ? 'approved' : 'rejected'}'));
      await load();
    } on ApiError catch (e) {
      _results.add(SelfieResult(e.message, isError: true));
      emit(state.copyWith(clearBusy: true));
    }
  }

  @override
  Future<void> close() {
    _results.close();
    return super.close();
  }
}
