part of 'support_tickets_cubit.dart';

enum TicketFilter {
  all('All', null),
  open('Open', 'open'),
  pending('Pending', 'pending'),
  closed('Closed', 'closed');

  const TicketFilter(this.label, this.query);
  final String label;
  final String? query;
}

enum TicketsStatus { loading, ready, error }

class SupportTicketsState extends Equatable {
  const SupportTicketsState({
    this.status = TicketsStatus.loading,
    this.filter = TicketFilter.all,
    this.tickets = const [],
    this.selected,
    this.detailStatus = TicketsStatus.ready,
    this.busy = false,
    this.error,
  });

  final TicketsStatus status;
  final TicketFilter filter;
  final List<SupportTicket> tickets;
  final SupportTicket? selected;
  final TicketsStatus detailStatus;
  final bool busy;
  final String? error;

  bool get isEmpty => status == TicketsStatus.ready && tickets.isEmpty;

  SupportTicketsState copyWith({
    TicketsStatus? status,
    TicketFilter? filter,
    List<SupportTicket>? tickets,
    SupportTicket? selected,
    bool clearSelected = false,
    TicketsStatus? detailStatus,
    bool? busy,
    String? error,
    bool clearError = false,
  }) =>
      SupportTicketsState(
        status: status ?? this.status,
        filter: filter ?? this.filter,
        tickets: tickets ?? this.tickets,
        selected: clearSelected ? null : (selected ?? this.selected),
        detailStatus: detailStatus ?? this.detailStatus,
        busy: busy ?? this.busy,
        error: clearError ? null : (error ?? this.error),
      );

  @override
  List<Object?> get props =>
      [status, filter, tickets, selected, detailStatus, busy, error];
}
