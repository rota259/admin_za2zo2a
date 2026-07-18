import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_error.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/repository_base.dart';
import '../models/pricing_config.dart';

/// Pricing config read/write, wired to the real backend.
///   GET /api/admin/pricing        → { config }
///   PUT /api/admin/pricing        → { config } (applies live to riders/drivers)
class PricingRepo with RepositoryBase {
  PricingRepo(this._client);

  final DioClient _client;

  Future<PricingConfig> get() async {
    return guard(() async {
      final res = await _client.dio.get(ApiEndpoints.adminPricing);
      final config = unwrap(res).mapField(['config']);
      if (config == null) {
        throw const ApiError('Pricing config not found.');
      }
      return PricingConfig.fromJson(config);
    });
  }

  /// Persist the edited config. Returns the server's saved version so the UI
  /// reflects exactly what took effect.
  Future<PricingConfig> update(PricingConfig config) async {
    return guard(() async {
      final res = await _client.dio.put(
        ApiEndpoints.adminPricing,
        data: config.toUpdateJson(),
      );
      final saved = unwrap(res).mapField(['config']);
      return saved == null ? config : PricingConfig.fromJson(saved);
    });
  }
}
