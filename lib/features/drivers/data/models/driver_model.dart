import '../../../../core/network/repository_base.dart';
import 'driver_document.dart';

/// The reviewable status the console shows per driver, derived from the real
/// backend fields (there is no single "status" column):
///   • blocked  — the user is deactivated (isActive == false)
///   • pending  — at least one document is not yet approved
///   • approved — active and every document approved
enum DriverStatus { approved, pending, blocked }

/// A driver, parsed from `GET /api/admin/drivers` / `/drivers/:id`.
///
/// The `user` ref is populated by the backend; nested `vehicle`, `documents`,
/// `earnings` and `stats` are embedded. Parsing stays tolerant (Mongo `_id`,
/// missing optionals) via [JsonReader].
class DriverModel {
  const DriverModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.rating,
    required this.isActive,
    required this.isVerified,
    required this.tier,
    required this.totalTrips,
    required this.acceptanceRate,
    required this.earningsLifetime,
    required this.isOnline,
    required this.documents,
    required this.vehicle,
    required this.joinedAt,
    this.profilePhoto,
  });

  final String id;
  final String userId;
  final String fullName;
  final String email;
  final String phone;
  final double rating;
  final bool isActive;
  final bool isVerified;

  /// "standard" | "gold" | "platinum".
  final String tier;

  final int totalTrips;
  final int acceptanceRate;
  final double earningsLifetime;
  final bool isOnline;

  /// All five documents, always present in [DocType.values] order.
  final List<DriverDocument> documents;
  final DriverVehicle vehicle;
  final DateTime? joinedAt;
  final String? profilePhoto;

  DriverStatus get status {
    if (!isActive) return DriverStatus.blocked;
    final allApproved = documents.every((d) => d.isApproved);
    return allApproved ? DriverStatus.approved : DriverStatus.pending;
  }

  String get initials {
    final parts =
        fullName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  DriverDocument doc(DocType type) =>
      documents.firstWhere((d) => d.type == type);

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    final user = json.mapField(['user']) ?? const {};
    final docs = json.mapField(['documents']) ?? const {};
    final stats = json.mapField(['stats']) ?? const {};
    final earnings = json.mapField(['earnings']) ?? const {};

    return DriverModel(
      id: json.str(['_id', 'id']) ?? '',
      userId: user.str(['_id', 'id']) ?? '',
      fullName: user.str(['fullName']) ?? '—',
      email: user.str(['email']) ?? '',
      phone: user.str(['phone']) ?? '',
      rating: user.dbl(['rating']) ?? 0,
      isActive: user.boolean(['isActive']) ?? true,
      isVerified: user.boolean(['isVerified']) ?? false,
      profilePhoto: user.str(['profilePhoto']),
      tier: json.str(['tier']) ?? 'standard',
      totalTrips: stats.integer(['totalTrips']) ?? 0,
      acceptanceRate: stats.integer(['acceptanceRate']) ?? 0,
      earningsLifetime: earnings.dbl(['totalLifetime']) ?? 0,
      isOnline: json.boolean(['isOnline']) ?? false,
      joinedAt: user.date(['createdAt']) ?? json.date(['memberSince']),
      vehicle: DriverVehicle.fromJson(json.mapField(['vehicle']) ?? const {}),
      documents: [
        for (final type in DocType.values)
          DriverDocument.fromJson(type, docs.mapField([type.key])),
      ],
    );
  }
}

/// Embedded vehicle info.
class DriverVehicle {
  const DriverVehicle({
    required this.make,
    required this.model,
    required this.color,
    required this.plateNumber,
    required this.year,
    required this.seats,
  });

  final String make;
  final String model;
  final String color;
  final String plateNumber;
  final int year;
  final int seats;

  String get display => '$make $model'.trim();

  factory DriverVehicle.fromJson(Map<String, dynamic> json) => DriverVehicle(
        make: json.str(['make']) ?? '',
        model: json.str(['model']) ?? '',
        color: json.str(['color']) ?? '',
        plateNumber: json.str(['plateNumber']) ?? '—',
        year: json.integer(['year']) ?? 0,
        seats: json.integer(['seats']) ?? 0,
      );
}
