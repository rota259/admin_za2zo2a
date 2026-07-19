import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_error.dart';
import '../data/models/driver_document.dart';
import '../data/models/driver_model.dart';
import '../data/models/driver_verification.dart';
import '../data/repos/drivers_repo.dart';

part 'driver_detail_state.dart';

/// The outcome of an action, surfaced once as a toast by the view.
class ActionResult {
  const ActionResult(this.message, {this.isError = false});
  final String message;
  final bool isError;
}

/// Owns one driver's detail screen and its review actions. After any mutation
/// it re-fetches the driver so the UI reflects the real server state rather
/// than an optimistic guess, and reports an [ActionResult] for the toast.
class DriverDetailCubit extends Cubit<DriverDetailState> {
  DriverDetailCubit(this._repo, this.driverId)
      : super(const DriverDetailState());

  final DriversRepo _repo;
  final String driverId;

  /// Emitted once per completed action, for the view to toast. Not part of
  /// state, so it never re-fires on rebuild.
  final _results = StreamController<ActionResult>.broadcast();
  Stream<ActionResult> get results => _results.stream;

  Future<void> load() async {
    emit(state.copyWith(status: DetailStatus.loading, clearError: true));
    try {
      final data = await _repo.detail(driverId);
      emit(state.copyWith(
        status: DetailStatus.ready,
        driver: data.driver,
        verification: data.verification,
        clearVerification: data.verification == null,
      ));
    } on ApiError catch (e) {
      emit(state.copyWith(status: DetailStatus.error, error: e.message));
    }
  }

  Future<void> reviewDocument(DocType type, bool approve, {String? reason}) =>
      _run(
        () => _repo.reviewDocument(
          driverId: driverId,
          docType: type.key,
          approve: approve,
          reason: reason,
        ),
        busy: (v) => state.copyWith(busyDoc: v ? type : null, clearBusyDoc: !v),
        ok: '${type.label} ${approve ? 'approved' : 'rejected'}',
      );

  Future<void> approveAll() => _run(
        () => _repo.approveDriver(driverId),
        busy: (v) => state.copyWith(busyApproveAll: v),
        ok: 'Driver approved — all documents verified',
      );

  Future<void> setBlocked(bool blocked, {String? reason}) => _run(
        () => _repo.setBlocked(id: driverId, blocked: blocked, reason: reason),
        busy: (v) => state.copyWith(busyBlock: v),
        ok: blocked ? 'Driver blocked' : 'Driver unblocked',
      );

  /// Shared action runner: guard against concurrent actions, run the call,
  /// re-fetch the driver, toast the outcome.
  Future<void> _run(
    Future<void> Function() action, {
    required DriverDetailState Function(bool busy) busy,
    required String ok,
  }) async {
    if (state.anyActionBusy) return;
    emit(busy(true));
    try {
      await action();
      final fresh = await _repo.detail(driverId);
      emit(busy(false).copyWith(
        driver: fresh.driver,
        verification: fresh.verification,
        clearVerification: fresh.verification == null,
        status: DetailStatus.ready,
      ));
      _results.add(ActionResult(ok));
    } on ApiError catch (e) {
      emit(busy(false));
      _results.add(ActionResult(e.message, isError: true));
    }
  }

  @override
  Future<void> close() {
    _results.close();
    return super.close();
  }
}
