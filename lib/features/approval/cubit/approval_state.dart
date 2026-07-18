part of 'approval_cubit.dart';

enum QueueStatus { loading, ready, error }

class ApprovalState extends Equatable {
  const ApprovalState({
    this.status = QueueStatus.loading,
    this.drivers = const [],
    this.total = 0,
    this.error,
    this.busyDriverId,
    this.busyDoc,
  });

  final QueueStatus status;
  final List<DriverModel> drivers;
  final int total;
  final String? error;

  /// The driver whose action is in flight — its whole card disables.
  final String? busyDriverId;

  /// The specific document being reviewed (shows that tile's spinner).
  final DocType? busyDoc;

  bool get isEmpty => status == QueueStatus.ready && drivers.isEmpty;

  ApprovalState copyWith({
    QueueStatus? status,
    List<DriverModel>? drivers,
    int? total,
    String? error,
    bool clearError = false,
    String? busyDriverId,
    DocType? busyDoc,
    bool clearBusy = false,
  }) =>
      ApprovalState(
        status: status ?? this.status,
        drivers: drivers ?? this.drivers,
        total: total ?? this.total,
        error: clearError ? null : (error ?? this.error),
        busyDriverId: clearBusy ? null : (busyDriverId ?? this.busyDriverId),
        busyDoc: clearBusy ? null : (busyDoc ?? this.busyDoc),
      );

  @override
  List<Object?> get props =>
      [status, drivers, total, error, busyDriverId, busyDoc];
}
