import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_error.dart';
import '../data/models/platform_settings.dart';
import '../data/repos/settings_repo.dart';

part 'commission_state.dart';

class CommissionResult {
  const CommissionResult(this.message, {this.isError = false});
  final String message;
  final bool isError;
}

/// The commission editor — a single `commissionRate` percent, mirroring the
/// pricing screen's edit-draft-save shape.
class CommissionCubit extends Cubit<CommissionState> {
  CommissionCubit(this._repo) : super(const CommissionState());

  final SettingsRepo _repo;

  final _results = StreamController<CommissionResult>.broadcast();
  Stream<CommissionResult> get results => _results.stream;

  Future<void> load() async {
    emit(state.copyWith(status: CommissionStatus.loading, clearError: true));
    try {
      final settings = await _repo.getSettings();
      emit(state.copyWith(
          status: CommissionStatus.ready, original: settings, draft: settings));
    } on ApiError catch (e) {
      emit(state.copyWith(status: CommissionStatus.error, error: e.message));
    }
  }

  void setRate(double v) {
    final draft = state.draft;
    if (draft == null) return;
    emit(state.copyWith(draft: draft.copyWith(commissionRate: v)));
  }

  void reset() {
    final original = state.original;
    if (original != null) emit(state.copyWith(draft: original));
  }

  Future<void> save() async {
    if (!state.canSave) return;
    emit(state.copyWith(saving: true));
    try {
      final saved = await _repo.updateSettings(state.draft!.commissionRate);
      emit(state.copyWith(saving: false, original: saved, draft: saved));
      _results.add(const CommissionResult('Settings updated'));
    } on ApiError catch (e) {
      emit(state.copyWith(saving: false));
      _results.add(CommissionResult(e.message, isError: true));
    }
  }

  @override
  Future<void> close() {
    _results.close();
    return super.close();
  }
}
