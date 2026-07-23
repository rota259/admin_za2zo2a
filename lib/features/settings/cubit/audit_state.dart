part of 'audit_cubit.dart';

enum AuditStatus { loading, ready, error }

class AuditState extends Equatable {
  const AuditState({
    this.status = AuditStatus.loading,
    this.entries = const [],
    this.page = 1,
    this.pages = 1,
    this.total = 0,
    this.error,
  });

  final AuditStatus status;
  final List<AuditEntry> entries;
  final int page;
  final int pages;
  final int total;
  final String? error;

  bool get isEmpty => status == AuditStatus.ready && entries.isEmpty;
  bool get hasPrev => page > 1;
  bool get hasNext => page < pages;

  AuditState copyWith({
    AuditStatus? status,
    List<AuditEntry>? entries,
    int? page,
    int? pages,
    int? total,
    String? error,
    bool clearError = false,
  }) =>
      AuditState(
        status: status ?? this.status,
        entries: entries ?? this.entries,
        page: page ?? this.page,
        pages: pages ?? this.pages,
        total: total ?? this.total,
        error: clearError ? null : (error ?? this.error),
      );

  @override
  List<Object?> get props => [status, entries, page, pages, total, error];
}
