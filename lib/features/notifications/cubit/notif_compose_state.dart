part of 'notif_compose_cubit.dart';

/// Who a broadcast targets. Maps 1:1 to the planned
/// `POST /api/admin/notifications` `target` field.
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
enum NotifKind {
  info('Info', 'system', Icons.info_outline),
  promo('Promo', 'promo', Icons.local_offer_outlined),
  warning('Warning', 'warning', Icons.warning_amber_rounded);

  const NotifKind(this.label, this.apiValue, this.icon);
  final String label;
  final String apiValue;
  final IconData icon;
}

class NotifComposeState extends Equatable {
  const NotifComposeState({
    this.target = NotifTarget.allRiders,
    this.type = NotifKind.info,
    this.title = '',
    this.body = '',
  });

  final NotifTarget target;
  final NotifKind type;
  final String title;
  final String body;

  /// Compose is complete enough to send (used when the endpoint exists).
  bool get isValid => title.trim().isNotEmpty && body.trim().isNotEmpty;

  NotifComposeState copyWith({
    NotifTarget? target,
    NotifKind? type,
    String? title,
    String? body,
  }) =>
      NotifComposeState(
        target: target ?? this.target,
        type: type ?? this.type,
        title: title ?? this.title,
        body: body ?? this.body,
      );

  @override
  List<Object?> get props => [target, type, title, body];
}
