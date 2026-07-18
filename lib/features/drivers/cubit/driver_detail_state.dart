part of 'driver_detail_cubit.dart';

enum DetailStatus { loading, ready, error }

class DriverDetailState extends Equatable {
  const DriverDetailState({
    this.status = DetailStatus.loading,
    this.driver,
    this.error,
    this.busyDoc,
    this.busyBlock = false,
    this.busyApproveAll = false,
  });

  final DetailStatus status;
  final DriverModel? driver;
  final String? error;

  /// The document currently being approved/rejected (drives its tile spinner).
  final DocType? busyDoc;

  /// A block/unblock request is in flight.
  final bool busyBlock;

  /// An "approve all documents" request is in flight.
  final bool busyApproveAll;

  bool get anyActionBusy =>
      busyDoc != null || busyBlock || busyApproveAll;

  DriverDetailState copyWith({
    DetailStatus? status,
    DriverModel? driver,
    String? error,
    bool clearError = false,
    DocType? busyDoc,
    bool clearBusyDoc = false,
    bool? busyBlock,
    bool? busyApproveAll,
  }) =>
      DriverDetailState(
        status: status ?? this.status,
        driver: driver ?? this.driver,
        error: clearError ? null : (error ?? this.error),
        busyDoc: clearBusyDoc ? null : (busyDoc ?? this.busyDoc),
        busyBlock: busyBlock ?? this.busyBlock,
        busyApproveAll: busyApproveAll ?? this.busyApproveAll,
      );

  @override
  List<Object?> get props =>
      [status, driver, error, busyDoc, busyBlock, busyApproveAll];
}
