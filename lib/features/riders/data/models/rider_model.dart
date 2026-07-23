import '../../../../core/network/repository_base.dart';

/// A rider, parsed from `GET /api/admin/riders` / `/riders/:id`.
class RiderModel {
  const RiderModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.rating,
    required this.totalRatings,
    required this.isActive,
    required this.isVerified,
    required this.createdAt,
    this.profilePhoto,
  });

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final double rating;
  final int totalRatings;
  final bool isActive;
  final bool isVerified;
  final DateTime? createdAt;
  final String? profilePhoto;

  String get initials {
    final parts =
        fullName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  factory RiderModel.fromJson(Map<String, dynamic> json) => RiderModel(
        id: json.str(['_id', 'id']) ?? '',
        fullName: json.str(['fullName']) ?? '—',
        email: json.str(['email']) ?? '',
        phone: json.str(['phone']) ?? '',
        rating: json.dbl(['rating']) ?? 0,
        totalRatings: json.integer(['totalRatings']) ?? 0,
        isActive: json.boolean(['isActive']) ?? true,
        isVerified: json.boolean(['isVerified']) ?? false,
        profilePhoto: json.str(['profilePhoto']),
        createdAt: json.date(['createdAt']),
      );
}

/// The rider's wallet, embedded in the detail response.
class RiderWallet {
  const RiderWallet({required this.balance, required this.currency});

  final double balance;
  final String currency;

  factory RiderWallet.fromJson(Map<String, dynamic>? json) => RiderWallet(
        balance: json?.dbl(['balance']) ?? 0,
        currency: json?.str(['currency']) ?? 'EGP',
      );
}

/// The rider's trip aggregates, embedded in the detail response.
class RiderStats {
  const RiderStats({
    required this.totalTrips,
    required this.completedTrips,
    required this.cancelledTrips,
    required this.totalSpent,
  });

  final int totalTrips;
  final int completedTrips;
  final int cancelledTrips;
  final double totalSpent;

  factory RiderStats.fromJson(Map<String, dynamic>? json) => RiderStats(
        totalTrips: json?.integer(['totalTrips']) ?? 0,
        completedTrips: json?.integer(['completedTrips']) ?? 0,
        cancelledTrips: json?.integer(['cancelledTrips']) ?? 0,
        totalSpent: json?.dbl(['totalSpent']) ?? 0,
      );
}
