import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_error.dart';
import '../data/models/zone_model.dart';
import '../data/repos/settings_repo.dart';

part 'zones_state.dart';

class ZoneResult {
  const ZoneResult(this.message, {this.isError = false});
  final String message;
  final bool isError;
}

/// Service-zones CRUD, per §4.2. Unpaginated — zones are few.
class ZonesCubit extends Cubit<ZonesState> {
  ZonesCubit(this._repo) : super(const ZonesState());

  final SettingsRepo _repo;

  final _results = StreamController<ZoneResult>.broadcast();
  Stream<ZoneResult> get results => _results.stream;

  Future<void> load() async {
    emit(state.copyWith(status: ZonesStatus.loading, clearError: true));
    try {
      final zones = await _repo.listZones();
      emit(state.copyWith(status: ZonesStatus.ready, zones: zones));
    } on ApiError catch (e) {
      emit(state.copyWith(status: ZonesStatus.error, error: e.message));
    }
  }

  Future<void> create({
    required String name,
    required List<String> areas,
    required double surgeMultiplier,
  }) async {
    if (state.busy) return;
    emit(state.copyWith(busy: true));
    try {
      final zone = await _repo.createZone(
          name: name, areas: areas, surgeMultiplier: surgeMultiplier);
      emit(state.copyWith(busy: false, zones: [...state.zones, zone]));
      _results.add(ZoneResult('Zone "${zone.name}" created'));
    } on ApiError catch (e) {
      emit(state.copyWith(busy: false));
      _results.add(ZoneResult(e.message, isError: true));
    }
  }

  Future<void> toggleActive(ZoneModel zone) async {
    if (state.busy) return;
    emit(state.copyWith(busy: true));
    try {
      final updated =
          await _repo.updateZone(id: zone.id, isActive: !zone.isActive);
      emit(state.copyWith(
        busy: false,
        zones: [for (final z in state.zones) if (z.id == zone.id) updated else z],
      ));
      _results.add(ZoneResult(
          updated.isActive ? 'Zone activated' : 'Zone deactivated'));
    } on ApiError catch (e) {
      emit(state.copyWith(busy: false));
      _results.add(ZoneResult(e.message, isError: true));
    }
  }

  Future<void> delete(ZoneModel zone) async {
    if (state.busy) return;
    emit(state.copyWith(busy: true));
    try {
      await _repo.deleteZone(zone.id);
      emit(state.copyWith(
        busy: false,
        zones: [for (final z in state.zones) if (z.id != zone.id) z],
      ));
      _results.add(ZoneResult('Zone "${zone.name}" deleted'));
    } on ApiError catch (e) {
      emit(state.copyWith(busy: false));
      _results.add(ZoneResult(e.message, isError: true));
    }
  }

  @override
  Future<void> close() {
    _results.close();
    return super.close();
  }
}
