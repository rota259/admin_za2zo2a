import '../../../../core/network/repository_base.dart';

/// One admin-audit-log row, per `docs/backend-admin-api-spec.md` §4.4.
class AuditEntry {
  const AuditEntry({
    required this.id,
    required this.type,
    required this.action,
    required this.actorName,
    required this.createdAt,
  });

  final String id;
  final String type;
  final String action;
  final String actorName;
  final DateTime? createdAt;

  factory AuditEntry.fromJson(Map<String, dynamic> json) {
    final actor = json.mapField(['actor']);
    return AuditEntry(
      id: json.str(['_id', 'id']) ?? '',
      type: json.str(['type']) ?? '—',
      action: json.str(['action']) ?? '—',
      actorName: actor?.str(['name', 'fullName']) ?? 'System',
      createdAt: json.date(['createdAt']),
    );
  }
}
