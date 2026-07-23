import '../../../../core/network/repository_base.dart';

/// A service zone, per `docs/backend-admin-api-spec.md` §4.2.
class ZoneModel {
  const ZoneModel({
    required this.id,
    required this.name,
    required this.areas,
    required this.surgeMultiplier,
    required this.isActive,
    required this.driverCount,
  });

  final String id;
  final String name;
  final List<String> areas;
  final double surgeMultiplier;
  final bool isActive;
  final int driverCount;

  factory ZoneModel.fromJson(Map<String, dynamic> json) => ZoneModel(
        id: json.str(['_id', 'id']) ?? '',
        name: json.str(['name']) ?? '—',
        areas: [
          for (final a in (json['areas'] as List? ?? const [])) a.toString(),
        ],
        surgeMultiplier: json.dbl(['surgeMultiplier']) ?? 1,
        isActive: json.boolean(['isActive']) ?? true,
        driverCount: json.integer(['driverCount']) ?? 0,
      );
}
