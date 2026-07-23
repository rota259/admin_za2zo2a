part of 'trip_detail_cubit.dart';

enum DetailStatus { loading, ready, error }

class TripDetailState extends Equatable {
  const TripDetailState({
    this.status = DetailStatus.loading,
    this.trip,
    this.busyFare = false,
    this.error,
  });

  final DetailStatus status;
  final TripModel? trip;
  final bool busyFare;
  final String? error;

  TripDetailState copyWith({
    DetailStatus? status,
    TripModel? trip,
    bool? busyFare,
    String? error,
    bool clearError = false,
  }) =>
      TripDetailState(
        status: status ?? this.status,
        trip: trip ?? this.trip,
        busyFare: busyFare ?? this.busyFare,
        error: clearError ? null : (error ?? this.error),
      );

  @override
  List<Object?> get props => [status, trip, busyFare, error];
}
