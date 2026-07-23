import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_error.dart';
import '../data/models/support_ticket.dart';
import '../data/repos/settings_repo.dart';

part 'support_tickets_state.dart';

class TicketResult {
  const TicketResult(this.message, {this.isError = false});
  final String message;
  final bool isError;
}

/// Support-ticket triage: list (with status filter) plus one open ticket's
/// detail/reply/status-update, per §4.3.
class SupportTicketsCubit extends Cubit<SupportTicketsState> {
  SupportTicketsCubit(this._repo) : super(const SupportTicketsState());

  final SettingsRepo _repo;

  final _results = StreamController<TicketResult>.broadcast();
  Stream<TicketResult> get results => _results.stream;

  Future<void> load() async {
    emit(state.copyWith(status: TicketsStatus.loading, clearError: true));
    try {
      final page = await _repo.listTickets(status: state.filter.query);
      emit(state.copyWith(status: TicketsStatus.ready, tickets: page.tickets));
    } on ApiError catch (e) {
      emit(state.copyWith(status: TicketsStatus.error, error: e.message));
    }
  }

  Future<void> selectFilter(TicketFilter filter) async {
    if (filter == state.filter) return;
    emit(state.copyWith(filter: filter));
    await load();
  }

  Future<void> open(SupportTicket ticket) async {
    emit(state.copyWith(selected: ticket, detailStatus: TicketsStatus.loading));
    try {
      final full = await _repo.ticketDetail(ticket.id);
      emit(state.copyWith(selected: full, detailStatus: TicketsStatus.ready));
    } on ApiError catch (e) {
      emit(state.copyWith(detailStatus: TicketsStatus.error, error: e.message));
    }
  }

  void closeDetail() => emit(state.copyWith(clearSelected: true));

  Future<void> updateStatus(String newStatus) async {
    final ticket = state.selected;
    if (ticket == null || state.busy) return;
    emit(state.copyWith(busy: true));
    try {
      final updated = await _repo.updateTicketStatus(ticket.id, newStatus);
      emit(state.copyWith(
        busy: false,
        selected: updated,
        tickets: [for (final t in state.tickets) if (t.id == updated.id) updated else t],
      ));
      _results.add(const TicketResult('Ticket updated'));
    } on ApiError catch (e) {
      emit(state.copyWith(busy: false));
      _results.add(TicketResult(e.message, isError: true));
    }
  }

  Future<void> reply(String body) async {
    final ticket = state.selected;
    if (ticket == null || body.trim().isEmpty || state.busy) return;
    emit(state.copyWith(busy: true));
    try {
      final updated = await _repo.replyToTicket(ticket.id, body.trim());
      emit(state.copyWith(
        busy: false,
        selected: updated,
        tickets: [for (final t in state.tickets) if (t.id == updated.id) updated else t],
      ));
      _results.add(const TicketResult('Reply sent'));
    } on ApiError catch (e) {
      emit(state.copyWith(busy: false));
      _results.add(TicketResult(e.message, isError: true));
    }
  }

  @override
  Future<void> close() {
    _results.close();
    return super.close();
  }
}
