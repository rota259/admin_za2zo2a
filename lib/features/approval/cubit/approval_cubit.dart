import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_error.dart';
import '../../drivers/data/models/driver_document.dart';
import '../../drivers/data/models/driver_model.dart';
import '../../drivers/data/repos/drivers_repo.dart';

part 'approval_state.dart';

/// One-shot outcome for the view to toast.
class ApprovalResult {
  const ApprovalResult(this.message, {this.isError = false});
  final String message;
  final bool isError;
}

/// The approval queue: the drivers with at least one un-approved document.
/// Every action goes through the real review/approve endpoints; after each one
/// the queue is re-fetched so an approved driver drops out of the list.
class ApprovalCubit extends Cubit<ApprovalState> {
  ApprovalCubit(this._repo) : super(const ApprovalState());

  final DriversRepo _repo;

  final _results = StreamController<ApprovalResult>.broadcast();
  Stream<ApprovalResult> get results => _results.stream;

  Future<void> load() async {
    emit(state.copyWith(status: QueueStatus.loading, clearError: true));
    try {
      final page = await _repo.list(status: 'pending', limit: 50);
      emit(state.copyWith(
          status: QueueStatus.ready, drivers: page.drivers, total: page.total));
    } on ApiError catch (e) {
      emit(state.copyWith(status: QueueStatus.error, error: e.message));
    }
  }

  Future<void> reviewDocument(
    DriverModel driver,
    DocType type,
    bool approve, {
    String? reason,
  }) =>
      _run(
        driver.id,
        busyDoc: type,
        () => _repo.reviewDocument(
          driverId: driver.id,
          docType: type.key,
          approve: approve,
          reason: reason,
        ),
        ok: '${type.label} ${approve ? 'approved' : 'rejected'}',
      );

  Future<void> approveDriver(DriverModel driver) => _run(
        driver.id,
        () => _repo.approveDriver(driver.id),
        ok: '${driver.fullName} approved',
      );

  /// Reject the whole application — mark every not-yet-approved document
  /// rejected with one shared reason (the backend has no driver-level reject).
  Future<void> rejectApplication(DriverModel driver, String reason) => _run(
        driver.id,
        () async {
          for (final d in driver.documents.where((x) => !x.isApproved)) {
            await _repo.reviewDocument(
              driverId: driver.id,
              docType: d.type.key,
              approve: false,
              reason: reason,
            );
          }
        },
        ok: '${driver.fullName}\'s documents rejected',
      );

  Future<void> _run(
    String driverId,
    Future<void> Function() action, {
    DocType? busyDoc,
    required String ok,
  }) async {
    if (state.busyDriverId != null) return;
    emit(state.copyWith(busyDriverId: driverId, busyDoc: busyDoc));
    try {
      await action();
      _results.add(ApprovalResult(ok));
      await load(); // re-fetch so approved drivers leave the queue
    } on ApiError catch (e) {
      _results.add(ApprovalResult(e.message, isError: true));
      emit(state.copyWith(clearBusy: true));
    }
  }

  @override
  Future<void> close() {
    _results.close();
    return super.close();
  }
}
