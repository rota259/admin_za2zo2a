part of 'zones_cubit.dart';

enum ZonesStatus { loading, ready, error }

class ZonesState extends Equatable {
  const ZonesState({
    this.status = ZonesStatus.loading,
    this.zones = const [],
    this.busy = false,
    this.error,
  });

  final ZonesStatus status;
  final List<ZoneModel> zones;
  final bool busy;
  final String? error;

  bool get isEmpty => status == ZonesStatus.ready && zones.isEmpty;

  ZonesState copyWith({
    ZonesStatus? status,
    List<ZoneModel>? zones,
    bool? busy,
    String? error,
    bool clearError = false,
  }) =>
      ZonesState(
        status: status ?? this.status,
        zones: zones ?? this.zones,
        busy: busy ?? this.busy,
        error: clearError ? null : (error ?? this.error),
      );

  @override
  List<Object?> get props => [status, zones, busy, error];
}
