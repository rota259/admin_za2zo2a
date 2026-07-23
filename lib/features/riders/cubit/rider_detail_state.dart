part of 'rider_detail_cubit.dart';

enum DetailStatus { loading, ready, error }

class RiderDetailState extends Equatable {
  const RiderDetailState({
    this.status = DetailStatus.loading,
    this.rider,
    this.wallet,
    this.stats,
    this.busyBlock = false,
    this.error,
  });

  final DetailStatus status;
  final RiderModel? rider;
  final RiderWallet? wallet;
  final RiderStats? stats;
  final bool busyBlock;
  final String? error;

  RiderDetailState copyWith({
    DetailStatus? status,
    RiderModel? rider,
    RiderWallet? wallet,
    RiderStats? stats,
    bool? busyBlock,
    String? error,
    bool clearError = false,
  }) =>
      RiderDetailState(
        status: status ?? this.status,
        rider: rider ?? this.rider,
        wallet: wallet ?? this.wallet,
        stats: stats ?? this.stats,
        busyBlock: busyBlock ?? this.busyBlock,
        error: clearError ? null : (error ?? this.error),
      );

  @override
  List<Object?> get props =>
      [status, rider, wallet, stats, busyBlock, error];
}
