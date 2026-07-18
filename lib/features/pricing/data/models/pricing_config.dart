import 'package:equatable/equatable.dart';

import '../../../../core/network/repository_base.dart';

/// One per-kilometer rate step. [uptoKm] null means "everything beyond the
/// previous tier" (the open-ended final tier).
class PerKmTier extends Equatable {
  const PerKmTier({required this.uptoKm, required this.pricePerKm});

  final double? uptoKm;
  final double pricePerKm;

  bool get isOpenEnded => uptoKm == null;

  factory PerKmTier.fromJson(Map<String, dynamic> json) => PerKmTier(
        uptoKm: json.dbl(['uptoKm']),
        pricePerKm: json.dbl(['pricePerKm']) ?? 0,
      );

  Map<String, dynamic> toJson() => {'uptoKm': uptoKm, 'pricePerKm': pricePerKm};

  PerKmTier copyWith({double? uptoKm, bool clearUpto = false, double? pricePerKm}) =>
      PerKmTier(
        uptoKm: clearUpto ? null : (uptoKm ?? this.uptoKm),
        pricePerKm: pricePerKm ?? this.pricePerKm,
      );

  @override
  List<Object?> get props => [uptoKm, pricePerKm];
}

/// The platform pricing config. Editing it via PUT applies live to the rider
/// and driver apps (they read the same values from `/api/pricing/config`).
///
/// [currency] is read-only here — the backend's PUT does not accept it.
class PricingConfig extends Equatable {
  const PricingConfig({
    required this.baseFare,
    required this.pickupSurcharge,
    required this.minFare,
    required this.surgeMultiplier,
    required this.waitingPerMin,
    required this.cancellationFee,
    required this.currency,
    required this.perKmTiers,
  });

  final double baseFare;
  final double pickupSurcharge;
  final double minFare;
  final double surgeMultiplier;
  final double waitingPerMin;
  final double cancellationFee;
  final String currency;
  final List<PerKmTier> perKmTiers;

  factory PricingConfig.fromJson(Map<String, dynamic> json) => PricingConfig(
        baseFare: json.dbl(['baseFare']) ?? 0,
        pickupSurcharge: json.dbl(['pickupSurcharge']) ?? 0,
        minFare: json.dbl(['minFare']) ?? 0,
        surgeMultiplier: json.dbl(['surgeMultiplier']) ?? 1,
        waitingPerMin: json.dbl(['waitingPerMin']) ?? 0,
        cancellationFee: json.dbl(['cancellationFee']) ?? 0,
        currency: json.str(['currency']) ?? 'EGP',
        perKmTiers: [
          for (final t in (json['perKmTiers'] as List? ?? const []))
            PerKmTier.fromJson(Map<String, dynamic>.from(t as Map)),
        ],
      );

  /// The PUT body — only the mutable fields the backend accepts.
  Map<String, dynamic> toUpdateJson() => {
        'baseFare': baseFare,
        'pickupSurcharge': pickupSurcharge,
        'minFare': minFare,
        'surgeMultiplier': surgeMultiplier,
        'waitingPerMin': waitingPerMin,
        'cancellationFee': cancellationFee,
        'perKmTiers': [for (final t in perKmTiers) t.toJson()],
      };

  PricingConfig copyWith({
    double? baseFare,
    double? pickupSurcharge,
    double? minFare,
    double? surgeMultiplier,
    double? waitingPerMin,
    double? cancellationFee,
    List<PerKmTier>? perKmTiers,
  }) =>
      PricingConfig(
        baseFare: baseFare ?? this.baseFare,
        pickupSurcharge: pickupSurcharge ?? this.pickupSurcharge,
        minFare: minFare ?? this.minFare,
        surgeMultiplier: surgeMultiplier ?? this.surgeMultiplier,
        waitingPerMin: waitingPerMin ?? this.waitingPerMin,
        cancellationFee: cancellationFee ?? this.cancellationFee,
        currency: currency,
        perKmTiers: perKmTiers ?? this.perKmTiers,
      );

  /// Mirrors the backend's validation so we can block a save the server would
  /// reject (all numbers ≥ 0, surge ≥ 1, at least one tier, each price ≥ 0).
  String? validationError() {
    if (baseFare < 0 ||
        pickupSurcharge < 0 ||
        minFare < 0 ||
        waitingPerMin < 0 ||
        cancellationFee < 0) {
      return 'Fares cannot be negative.';
    }
    if (surgeMultiplier < 1) return 'Surge multiplier must be at least 1.0×.';
    if (perKmTiers.isEmpty) return 'Add at least one distance tier.';
    if (perKmTiers.any((t) => t.pricePerKm < 0)) {
      return 'Per-km rates cannot be negative.';
    }
    return null;
  }

  @override
  List<Object?> get props => [
        baseFare,
        pickupSurcharge,
        minFare,
        surgeMultiplier,
        waitingPerMin,
        cancellationFee,
        currency,
        perKmTiers,
      ];
}
