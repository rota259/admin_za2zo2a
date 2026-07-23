import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/repository_base.dart';
import '../models/notification_campaign.dart';

/// One page of sent-campaign history.
class CampaignPage {
  const CampaignPage({
    required this.campaigns,
    required this.page,
    required this.pages,
    required this.total,
  });

  final List<NotificationCampaign> campaigns;
  final int page;
  final int pages;
  final int total;
}

/// Admin broadcast notifications, wired to the real backend:
///   POST /api/admin/notifications  → send/broadcast
///   GET  /api/admin/notifications  → sent history (paginated)
class NotificationsRepo with RepositoryBase {
  NotificationsRepo(this._client);

  final DioClient _client;

  /// [target] is the API value (`single` | `all_riders` | `all_drivers` |
  /// `everyone`). [userId] is required when [target] is `single`.
  Future<NotificationCampaign> send({
    required String target,
    required String title,
    required String body,
    required String type,
    String? userId,
  }) async {
    return guard(() async {
      final res = await _client.dio.post(
        ApiEndpoints.adminNotifications,
        data: {
          'target': target,
          'title': title,
          // The live backend's field is "message", not "body" (confirmed by
          // the Postman collection's saved examples and by the 400 "title
          // and message are required" response) — despite the internal spec
          // doc calling it "body".
          'message': body,
          'type': type,
          if (userId != null && userId.isNotEmpty) 'userId': userId,
        },
      );
      final data = unwrap(res);
      final campaign = data.mapField(['campaign']);
      return NotificationCampaign.fromJson(campaign ?? data);
    });
  }

  Future<CampaignPage> history({int page = 1, int limit = 20}) async {
    return guard(() async {
      final res = await _client.dio.get(
        ApiEndpoints.adminNotifications,
        queryParameters: {'page': page, 'limit': limit},
      );
      final data = unwrap(res);
      final pagination = data.mapField(['pagination']) ?? const {};
      final list = (data['campaigns'] as List?) ?? const [];
      return CampaignPage(
        campaigns: [
          for (final c in list)
            NotificationCampaign.fromJson(Map<String, dynamic>.from(c as Map)),
        ],
        page: pagination.integer(['page']) ?? page,
        pages: pagination.integer(['pages']) ?? 1,
        total: pagination.integer(['total']) ?? list.length,
      );
    });
  }
}
