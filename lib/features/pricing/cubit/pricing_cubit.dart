import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_error.dart';
import '../data/models/pricing_config.dart';
import '../data/repos/pricing_repo.dart';

part 'pricing_state.dart';

/// One-shot save outcome for the view to toast.
class PricingResult {
  const PricingResult(this.message, {this.isError = false});
  final String message;
  final bool isError;
}

/// Owns the pricing editor: the live config, the working draft, dirty state,
/// and the save. The view confirms before calling [save] — this cubit does the
/// PUT that applies live to riders and drivers.
class PricingCubit extends Cubit<PricingState> {
  PricingCubit(this._repo) : super(const PricingState());

  final PricingRepo _repo;

  final _results = StreamController<PricingResult>.broadcast();
  Stream<PricingResult> get results => _results.stream;

  Future<void> load() async {
    emit(state.copyWith(status: PricingStatus.loading, clearError: true));
    try {
      final config = await _repo.get();
      emit(state.copyWith(
          status: PricingStatus.ready, original: config, draft: config));
    } on ApiError catch (e) {
      emit(state.copyWith(status: PricingStatus.error, error: e.message));
    }
  }

  void _edit(PricingConfig Function(PricingConfig d) change) {
    final draft = state.draft;
    if (draft == null) return;
    emit(state.copyWith(draft: change(draft)));
  }

  void setBaseFare(double v) => _edit((d) => d.copyWith(baseFare: v));
  void setPickupSurcharge(double v) =>
      _edit((d) => d.copyWith(pickupSurcharge: v));
  void setMinFare(double v) => _edit((d) => d.copyWith(minFare: v));
  void setSurge(double v) => _edit((d) => d.copyWith(surgeMultiplier: v));
  void setWaiting(double v) => _edit((d) => d.copyWith(waitingPerMin: v));
  void setCancellation(double v) =>
      _edit((d) => d.copyWith(cancellationFee: v));

  void setTierPrice(int index, double v) => _edit((d) {
        final tiers = [...d.perKmTiers];
        tiers[index] = tiers[index].copyWith(pricePerKm: v);
        return d.copyWith(perKmTiers: tiers);
      });

  void setTierUpto(int index, double? v) => _edit((d) {
        final tiers = [...d.perKmTiers];
        tiers[index] =
            v == null ? tiers[index].copyWith(clearUpto: true) : tiers[index].copyWith(uptoKm: v);
        return d.copyWith(perKmTiers: tiers);
      });

  void addTier() => _edit((d) {
        // Insert before the open-ended tier if there is one.
        final tiers = [...d.perKmTiers];
        final last = tiers.isNotEmpty ? tiers.last.pricePerKm : 1.0;
        final insertAt =
            tiers.isNotEmpty && tiers.last.isOpenEnded ? tiers.length - 1 : tiers.length;
        tiers.insert(insertAt, PerKmTier(uptoKm: 20, pricePerKm: last));
        return d.copyWith(perKmTiers: tiers);
      });

  void removeTier(int index) => _edit((d) {
        if (d.perKmTiers.length <= 1) return d; // keep at least one
        final tiers = [...d.perKmTiers]..removeAt(index);
        return d.copyWith(perKmTiers: tiers);
      });

  void reset() {
    final original = state.original;
    if (original != null) emit(state.copyWith(draft: original));
  }

  /// Persist the draft. Call only after the operator confirms.
  Future<void> save() async {
    if (!state.canSave) return;
    emit(state.copyWith(saving: true, clearError: true));
    try {
      final saved = await _repo.update(state.draft!);
      emit(state.copyWith(saving: false, original: saved, draft: saved));
      _results.add(const PricingResult('Pricing updated — live for riders and '
          'drivers'));
    } on ApiError catch (e) {
      emit(state.copyWith(saving: false));
      _results.add(PricingResult(e.message, isError: true));
    }
  }

  @override
  Future<void> close() {
    _results.close();
    return super.close();
  }
}
