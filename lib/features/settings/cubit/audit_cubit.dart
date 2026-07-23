import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_error.dart';
import '../data/models/audit_entry.dart';
import '../data/repos/settings_repo.dart';

part 'audit_state.dart';

/// Read-only audit-log feed, per §4.4.
class AuditCubit extends Cubit<AuditState> {
  AuditCubit(this._repo) : super(const AuditState());

  final SettingsRepo _repo;

  Future<void> load() async {
    emit(state.copyWith(status: AuditStatus.loading, clearError: true));
    try {
      final page = await _repo.listAudit(page: 1);
      emit(state.copyWith(
        status: AuditStatus.ready,
        entries: page.entries,
        page: page.page,
        pages: page.pages,
        total: page.total,
      ));
    } on ApiError catch (e) {
      emit(state.copyWith(status: AuditStatus.error, error: e.message));
    }
  }

  Future<void> nextPage() async {
    if (state.page < state.pages) await _fetch(state.page + 1);
  }

  Future<void> prevPage() async {
    if (state.page > 1) await _fetch(state.page - 1);
  }

  Future<void> _fetch(int page) async {
    emit(state.copyWith(status: AuditStatus.loading, clearError: true));
    try {
      final result = await _repo.listAudit(page: page);
      emit(state.copyWith(
        status: AuditStatus.ready,
        entries: result.entries,
        page: result.page,
        pages: result.pages,
        total: result.total,
      ));
    } on ApiError catch (e) {
      emit(state.copyWith(status: AuditStatus.error, error: e.message));
    }
  }
}
