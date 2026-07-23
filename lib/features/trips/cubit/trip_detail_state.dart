part of 'trip_detail_cubit.dart';

enum DetailStatus { loading, ready, error }

class TripDetailState extends Equatable {
  const TripDetailState({
    this.status = DetailStatus.loading,
    this.trip,
    this.error,
  });

  final DetailStatus status;
  final TripModel? trip;
  final String? error;

  TripDetailState copyWith({
    DetailStatus? status,
    TripModel? trip,
    String? error,
    bool clearError = false,
  }) =>
      TripDetailState(
        status: status ?? this.status,
        trip: trip ?? this.trip,
        error: clearError ? null : (error ?? this.error),
      );

  @override
  List<Object?> get props => [status, trip, error];
}
