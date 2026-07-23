import '../../../../core/network/repository_base.dart';

/// `GET/PATCH /api/admin/settings` — the commission/platform config.
class PlatformSettings {
  const PlatformSettings({required this.commissionRate, required this.currency});

  /// Percent the platform keeps per trip, 0–100.
  final double commissionRate;

  /// Read-only, sourced from the pricing config.
  final String currency;

  factory PlatformSettings.fromJson(Map<String, dynamic> json) =>
      PlatformSettings(
        commissionRate: json.dbl(['commissionRate']) ?? 0,
        currency: json.str(['currency']) ?? 'EGP',
      );

  PlatformSettings copyWith({double? commissionRate}) => PlatformSettings(
        commissionRate: commissionRate ?? this.commissionRate,
        currency: currency,
      );

  @override
  bool operator ==(Object other) =>
      other is PlatformSettings &&
      other.commissionRate == commissionRate &&
      other.currency == currency;

  @override
  int get hashCode => Object.hash(commissionRate, currency);
}
