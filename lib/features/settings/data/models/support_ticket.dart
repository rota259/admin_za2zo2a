import '../../../../core/network/repository_base.dart';

class TicketReply {
  const TicketReply({required this.body, this.byName, this.createdAt});
  final String body;
  final String? byName;
  final DateTime? createdAt;

  factory TicketReply.fromJson(Map<String, dynamic> json) {
    final by = json.mapField(['by']);
    return TicketReply(
      body: json.str(['body']) ?? '',
      byName: by?.str(['name', 'fullName']),
      createdAt: json.date(['createdAt']),
    );
  }
}

/// A support ticket, per `docs/backend-admin-api-spec.md` §4.3.
class SupportTicket {
  const SupportTicket({
    required this.id,
    required this.subject,
    required this.userName,
    required this.userRole,
    required this.status,
    required this.priority,
    required this.createdAt,
    this.message,
    this.replies = const [],
  });

  final String id;
  final String subject;
  final String userName;
  final String userRole;

  /// `open` | `pending` | `closed`.
  final String status;

  /// `low` | `normal` | `high`.
  final String priority;
  final DateTime? createdAt;
  final String? message;
  final List<TicketReply> replies;

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    final user = json.mapField(['user']) ?? const {};
    return SupportTicket(
      id: json.str(['_id', 'id']) ?? '',
      subject: json.str(['subject']) ?? '—',
      userName: user.str(['name', 'fullName']) ?? '—',
      userRole: user.str(['role']) ?? '—',
      status: json.str(['status']) ?? 'open',
      priority: json.str(['priority']) ?? 'normal',
      createdAt: json.date(['createdAt']),
      message: json.str(['message']),
      replies: [
        for (final r in (json['replies'] as List? ?? const []))
          TicketReply.fromJson(Map<String, dynamic>.from(r as Map)),
      ],
    );
  }
}
