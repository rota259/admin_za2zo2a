import '../../../../core/network/repository_base.dart';

/// A periodic driver selfie awaiting (or past) admin review.
///
/// Parsed from `GET /api/admin/selfie-checks`. [photoUrl] is the submitted
/// selfie; [profilePhoto] is the reference photo on file — the admin compares
/// the two by eye (the backend does no face-matching, so there is no score).
class SelfieCheck {
  const SelfieCheck({
    required this.id,
    required this.driverName,
    required this.driverPhone,
    required this.photoUrl,
    required this.status,
    this.profilePhoto,
    this.submittedAt,
    this.rejectionReason,
  });

  final String id;
  final String driverName;
  final String driverPhone;

  /// The submitted selfie (Cloudinary).
  final String photoUrl;

  /// "pending_review" | "approved" | "rejected".
  final String status;

  /// The reference photo on file (Cloudinary), null if the driver has none.
  final String? profilePhoto;
  final DateTime? submittedAt;
  final String? rejectionReason;

  factory SelfieCheck.fromJson(Map<String, dynamic> json) {
    final driver = json.mapField(['driver']) ?? const {};
    return SelfieCheck(
      id: json.str(['_id', 'id']) ?? '',
      driverName: driver.str(['fullName']) ?? '—',
      driverPhone: driver.str(['phone']) ?? '',
      profilePhoto: driver.str(['profilePhoto']),
      photoUrl: json.str(['photoUrl']) ?? '',
      status: json.str(['status']) ?? 'pending_review',
      submittedAt: json.date(['createdAt']),
      rejectionReason: json.str(['rejectionReason']),
    );
  }

  String get initials {
    final parts =
        driverName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
