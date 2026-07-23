import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_error.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/repository_base.dart';
import '../models/audit_entry.dart';
import '../models/platform_settings.dart';
import '../models/support_ticket.dart';
import '../models/zone_model.dart';

class TicketPage {
  const TicketPage({
    required this.tickets,
    required this.page,
    required this.pages,
    required this.total,
  });
  final List<SupportTicket> tickets;
  final int page;
  final int pages;
  final int total;
}

class AuditPage {
  const AuditPage({
    required this.entries,
    required this.page,
    required this.pages,
    required this.total,
  });
  final List<AuditEntry> entries;
  final int page;
  final int pages;
  final int total;
}

/// Every Settings-screen operation, per `docs/backend-admin-api-spec.md` §4:
/// commission/platform config, service zones, support tickets, and the
/// read-only audit log.
class SettingsRepo with RepositoryBase {
  SettingsRepo(this._client);

  final DioClient _client;

  // ── 4.1 Commission / platform settings ──────────────────────────────────

  Future<PlatformSettings> getSettings() async {
    return guard(() async {
      final res = await _client.dio.get(ApiEndpoints.adminSettings);
      final settings = unwrap(res).mapField(['settings']);
      if (settings == null) {
        throw const ApiError('Settings not found.');
      }
      return PlatformSettings.fromJson(settings);
    });
  }

  Future<PlatformSettings> updateSettings(double commissionRate) async {
    return guard(() async {
      final res = await _client.dio.patch(
        ApiEndpoints.adminSettings,
        data: {'commissionRate': commissionRate},
      );
      final settings = unwrap(res).mapField(['settings']);
      return settings == null
          ? PlatformSettings(commissionRate: commissionRate, currency: 'EGP')
          : PlatformSettings.fromJson(settings);
    });
  }

  // ── 4.2 Service zones ────────────────────────────────────────────────────

  Future<List<ZoneModel>> listZones() async {
    return guard(() async {
      final res = await _client.dio.get(ApiEndpoints.adminZones);
      final list = unwrap(res)['zones'] as List? ?? const [];
      return [
        for (final z in list)
          ZoneModel.fromJson(Map<String, dynamic>.from(z as Map)),
      ];
    });
  }

  Future<ZoneModel> createZone({
    required String name,
    List<String> areas = const [],
    double surgeMultiplier = 1,
    bool isActive = true,
  }) async {
    return guard(() async {
      final res = await _client.dio.post(ApiEndpoints.adminZones, data: {
        'name': name,
        'areas': areas,
        'surgeMultiplier': surgeMultiplier,
        'isActive': isActive,
      });
      final zone = unwrap(res).mapField(['zone']);
      throwIfMissing(zone, 'Zone');
      return ZoneModel.fromJson(zone!);
    });
  }

  Future<ZoneModel> updateZone({
    required String id,
    String? name,
    List<String>? areas,
    double? surgeMultiplier,
    bool? isActive,
  }) async {
    return guard(() async {
      final res = await _client.dio.patch(ApiEndpoints.adminZone(id), data: {
        if (name != null) 'name': name,
        if (areas != null) 'areas': areas,
        if (surgeMultiplier != null) 'surgeMultiplier': surgeMultiplier,
        if (isActive != null) 'isActive': isActive,
      });
      final zone = unwrap(res).mapField(['zone']);
      throwIfMissing(zone, 'Zone');
      return ZoneModel.fromJson(zone!);
    });
  }

  Future<void> deleteZone(String id) async {
    return guard(() async {
      await _client.dio.delete(ApiEndpoints.adminZone(id));
    });
  }

  // ── 4.3 Support tickets ──────────────────────────────────────────────────

  Future<TicketPage> listTickets({
    String? status,
    String? priority,
    int page = 1,
    int limit = 20,
  }) async {
    return guard(() async {
      final res = await _client.dio.get(
        ApiEndpoints.adminSupportTickets,
        queryParameters: {
          'status': ?status,
          'priority': ?priority,
          'page': page,
          'limit': limit,
        },
      );
      final data = unwrap(res);
      final pagination = data.mapField(['pagination']) ?? const {};
      final list = (data['tickets'] as List?) ?? const [];
      return TicketPage(
        tickets: [
          for (final t in list)
            SupportTicket.fromJson(Map<String, dynamic>.from(t as Map)),
        ],
        page: pagination.integer(['page']) ?? page,
        pages: pagination.integer(['pages']) ?? 1,
        total: pagination.integer(['total']) ?? list.length,
      );
    });
  }

  Future<SupportTicket> ticketDetail(String id) async {
    return guard(() async {
      final res = await _client.dio.get(ApiEndpoints.adminSupportTicket(id));
      final ticket = unwrap(res).mapField(['ticket']);
      throwIfMissing(ticket, 'Ticket');
      return SupportTicket.fromJson(ticket!);
    });
  }

  Future<SupportTicket> updateTicketStatus(String id, String status) async {
    return guard(() async {
      final res = await _client.dio
          .patch(ApiEndpoints.adminSupportTicket(id), data: {'status': status});
      final ticket = unwrap(res).mapField(['ticket']);
      throwIfMissing(ticket, 'Ticket');
      return SupportTicket.fromJson(ticket!);
    });
  }

  Future<SupportTicket> replyToTicket(String id, String body) async {
    return guard(() async {
      final res = await _client.dio
          .post(ApiEndpoints.adminSupportTicketReplies(id), data: {'body': body});
      final ticket = unwrap(res).mapField(['ticket']);
      throwIfMissing(ticket, 'Ticket');
      return SupportTicket.fromJson(ticket!);
    });
  }

  // ── 4.4 Audit log (read-only) ────────────────────────────────────────────

  Future<AuditPage> listAudit({
    String? type,
    int page = 1,
    int limit = 20,
  }) async {
    return guard(() async {
      final res = await _client.dio.get(
        ApiEndpoints.adminAudit,
        queryParameters: {'type': ?type, 'page': page, 'limit': limit},
      );
      final data = unwrap(res);
      final pagination = data.mapField(['pagination']) ?? const {};
      final list = (data['entries'] as List?) ?? const [];
      return AuditPage(
        entries: [
          for (final e in list)
            AuditEntry.fromJson(Map<String, dynamic>.from(e as Map)),
        ],
        page: pagination.integer(['page']) ?? page,
        pages: pagination.integer(['pages']) ?? 1,
        total: pagination.integer(['total']) ?? list.length,
      );
    });
  }

  void throwIfMissing(Map<String, dynamic>? v, String what) {
    if (v == null) throw ApiError('$what not found.', statusCode: 404);
  }
}
