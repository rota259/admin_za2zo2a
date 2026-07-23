import '../../../../core/network/repository_base.dart';

/// One broadcast, as returned by `POST /api/admin/notifications` (the
/// `campaign` field) and listed by `GET /api/admin/notifications`.
class NotificationCampaign {
  const NotificationCampaign({
    required this.id,
    required this.title,
    required this.target,
    required this.type,
    required this.recipientCount,
    required this.createdAt,
    this.body,
    this.sentByName,
  });

  final String id;
  final String title;
  final String? body;

  /// `single` | `all_riders` | `all_drivers` | `everyone`.
  final String target;

  /// `system` | `promo` | `warning` | … (`NotificationType` on the backend).
  final String type;
  final int recipientCount;
  final String? sentByName;
  final DateTime? createdAt;

  factory NotificationCampaign.fromJson(Map<String, dynamic> json) {
    final sentBy = json.mapField(['sentBy']);
    return NotificationCampaign(
      id: json.str(['_id', 'id']) ?? '',
      title: json.str(['title']) ?? '—',
      // The backend's field is "message"; tolerate "body" too in case a
      // future response shape (or the history list) uses that name instead.
      body: json.str(['message', 'body']),
      target: json.str(['target']) ?? 'all_riders',
      type: json.str(['type']) ?? 'system',
      recipientCount: json.integer(['recipientCount']) ?? 0,
      sentByName: sentBy?.str(['name', 'fullName']),
      createdAt: json.date(['createdAt']),
    );
  }

  String get targetLabel => switch (target) {
        'user' || 'single' => 'Single user',
        'all_riders' => 'All riders',
        'all_drivers' => 'All drivers',
        'everyone' => 'Everyone',
        _ => target,
      };
}
