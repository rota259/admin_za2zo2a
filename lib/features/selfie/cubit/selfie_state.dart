part of 'selfie_cubit.dart';

enum SelfieStatus { loading, ready, error }

class SelfieState extends Equatable {
  const SelfieState({
    this.status = SelfieStatus.loading,
    this.checks = const [],
    this.error,
    this.busyId,
  });

  final SelfieStatus status;
  final List<SelfieCheck> checks;
  final String? error;

  /// The selfie whose review is in flight (disables that card).
  final String? busyId;

  bool get isEmpty => status == SelfieStatus.ready && checks.isEmpty;

  SelfieState copyWith({
    SelfieStatus? status,
    List<SelfieCheck>? checks,
    String? error,
    bool clearError = false,
    String? busyId,
    bool clearBusy = false,
  }) =>
      SelfieState(
        status: status ?? this.status,
        checks: checks ?? this.checks,
        error: clearError ? null : (error ?? this.error),
        busyId: clearBusy ? null : (busyId ?? this.busyId),
      );

  @override
  List<Object?> get props => [status, checks, error, busyId];
}
