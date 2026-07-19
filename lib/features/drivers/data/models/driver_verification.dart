import '../../../../core/network/repository_base.dart';

/// The driver's most recent selfie check, from the `latestSelfie` the detail
/// endpoint returns. Used to show "last verified" on the driver detail page.
///
/// Null when the driver has never submitted a selfie (the queue is empty
/// because the driver-side submit endpoint isn't mounted yet — see the
/// integration spec).
class DriverVerification {
  const DriverVerification({
    required this.status,
    this.submittedAt,
    this.reviewedAt,
    this.rejectionReason,
  });

  /// "pending_review" | "approved" | "rejected".
  final String status;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final String? rejectionReason;

  /// The moment the driver was last verified — the review time when approved,
  /// otherwise the submission time.
  DateTime? get lastCheckedAt => reviewedAt ?? submittedAt;

  static DriverVerification? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return DriverVerification(
      status: json.str(['status']) ?? 'pending_review',
      submittedAt: json.date(['createdAt']),
      reviewedAt: json.date(['reviewedAt']),
      rejectionReason: json.str(['rejectionReason']),
    );
  }
}
