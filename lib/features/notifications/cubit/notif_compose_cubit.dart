import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'notif_compose_state.dart';

/// Local compose state for the notifications screen — audience, type, title and
/// body, driving the live preview and the (send-ready) validation.
///
/// No repo yet: the backend has no admin "send notification" endpoint. The send
/// button stays disabled until that lands (see docs/integration-spec.md); this
/// cubit is pure local editing so the screen is wiring-ready.
class NotifComposeCubit extends Cubit<NotifComposeState> {
  NotifComposeCubit() : super(const NotifComposeState());

  void setTarget(NotifTarget target) => emit(state.copyWith(target: target));
  void setType(NotifKind type) => emit(state.copyWith(type: type));
  void setTitle(String title) => emit(state.copyWith(title: title));
  void setBody(String body) => emit(state.copyWith(body: body));

  void reset() => emit(const NotifComposeState());
}
