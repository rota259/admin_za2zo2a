part of 'notif_compose_cubit.dart';

/// Who a broadcast targets. Maps 1:1 to `POST /api/admin/notifications`'s
/// `target` field.
enum NotifTarget {
  single('Single rider', 'user', Icons.person_outline),
  allRiders('All riders', 'all_riders', Icons.people_outline),
  allDrivers('All drivers', 'all_drivers', Icons.directions_car_outlined),
  everyone('Everyone', 'everyone', Icons.public);

  const NotifTarget(this.label, this.apiValue, this.icon);
  final String label;
  final String apiValue;
  final IconData icon;
}

/// Notification tone. Maps to `NotificationType` on the backend.
///
/// Both `"system"` and `"general"` were tried for a third, generic option and
/// both were rejected live ("... is not a valid enum value for path `type`")
/// — the real `NotificationType` enum is narrower than the spec doc claimed.
/// `promo` and `warning` are the only two values confirmed to work (they're
/// the exact values in the project's own Postman collection, sent
/// successfully against the live backend), so the picker is limited to those
/// until the real third value is confirmed — no more guessing.
enum NotifKind {
  promo('Promo', 'promo', Icons.local_offer_outlined),
  warning('Warning', 'warning', Icons.warning_amber_rounded);

  const NotifKind(this.label, this.apiValue, this.icon);
  final String label;
  final String apiValue;
  final IconData icon;
}

enum SendStatus { idle, sending, sent, error }

enum HistoryStatus { loading, ready, error }

class NotifComposeState extends Equatable {
  const NotifComposeState({
    this.target = NotifTarget.allRiders,
    this.type = NotifKind.promo,
    this.title = '',
    this.body = '',
    this.userId = '',
    this.sendStatus = SendStatus.idle,
    this.sendError,
    this.historyStatus = HistoryStatus.loading,
    this.history = const [],
    this.historyError,
  });

  final NotifTarget target;
  final NotifKind type;
  final String title;
  final String body;

  /// Recipient `User._id`, only meaningful when [target] is `single`.
  final String userId;

  final SendStatus sendStatus;
  final String? sendError;

  final HistoryStatus historyStatus;
  final List<NotificationCampaign> history;
  final String? historyError;

  /// Compose is complete enough to send.
  bool get isValid =>
      title.trim().isNotEmpty &&
      body.trim().isNotEmpty &&
      (target != NotifTarget.single || userId.trim().isNotEmpty);

  bool get isSending => sendStatus == SendStatus.sending;

  NotifComposeState copyWith({
    NotifTarget? target,
    NotifKind? type,
    String? title,
    String? body,
    String? userId,
    SendStatus? sendStatus,
    String? sendError,
    bool clearSendError = false,
    HistoryStatus? historyStatus,
    List<NotificationCampaign>? history,
    String? historyError,
    bool clearHistoryError = false,
  }) =>
      NotifComposeState(
        target: target ?? this.target,
        type: type ?? this.type,
        title: title ?? this.title,
        body: body ?? this.body,
        userId: userId ?? this.userId,
        sendStatus: sendStatus ?? this.sendStatus,
        sendError: clearSendError ? null : (sendError ?? this.sendError),
        historyStatus: historyStatus ?? this.historyStatus,
        history: history ?? this.history,
        historyError:
            clearHistoryError ? null : (historyError ?? this.historyError),
      );

  @override
  List<Object?> get props => [
        target,
        type,
        title,
        body,
        userId,
        sendStatus,
        sendError,
        historyStatus,
        history,
        historyError,
      ];
}
