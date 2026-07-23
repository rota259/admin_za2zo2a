import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_error.dart';
import '../data/models/notification_campaign.dart';
import '../data/repos/notifications_repo.dart';

part 'notif_compose_state.dart';

/// Notifications screen: compose (audience, type, title, body) plus send and
/// the sent-history feed. Both `POST` and `GET /api/admin/notifications` are
/// live on the backend.
class NotifComposeCubit extends Cubit<NotifComposeState> {
  NotifComposeCubit(this._repo) : super(const NotifComposeState());

  final NotificationsRepo _repo;

  void setTarget(NotifTarget target) => emit(state.copyWith(target: target));
  void setType(NotifKind type) => emit(state.copyWith(type: type));
  void setTitle(String title) => emit(state.copyWith(title: title));
  void setBody(String body) => emit(state.copyWith(body: body));
  void setUserId(String userId) => emit(state.copyWith(userId: userId));

  void reset() => emit(state.copyWith(
        title: '',
        body: '',
        userId: '',
        sendStatus: SendStatus.idle,
        clearSendError: true,
      ));

  Future<void> loadHistory() async {
    emit(state.copyWith(
        historyStatus: HistoryStatus.loading, clearHistoryError: true));
    try {
      final page = await _repo.history();
      emit(state.copyWith(
          historyStatus: HistoryStatus.ready, history: page.campaigns));
    } on ApiError catch (e) {
      emit(state.copyWith(
          historyStatus: HistoryStatus.error, historyError: e.message));
    }
  }

  Future<void> send() async {
    if (!state.isValid || state.isSending) return;
    emit(state.copyWith(sendStatus: SendStatus.sending, clearSendError: true));
    try {
      final campaign = await _repo.send(
        target: state.target.apiValue,
        title: state.title.trim(),
        body: state.body.trim(),
        type: state.type.apiValue,
        userId: state.target == NotifTarget.single ? state.userId.trim() : null,
      );
      emit(state.copyWith(
        sendStatus: SendStatus.sent,
        title: '',
        body: '',
        userId: '',
        history: [campaign, ...state.history],
      ));
    } on ApiError catch (e) {
      emit(state.copyWith(sendStatus: SendStatus.error, sendError: e.message));
    }
  }
}
