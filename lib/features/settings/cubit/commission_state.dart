part of 'commission_cubit.dart';

enum CommissionStatus { loading, ready, error }

class CommissionState extends Equatable {
  const CommissionState({
    this.status = CommissionStatus.loading,
    this.original,
    this.draft,
    this.error,
    this.saving = false,
  });

  final CommissionStatus status;
  final PlatformSettings? original;
  final PlatformSettings? draft;
  final String? error;
  final bool saving;

  bool get isDirty =>
      original != null && draft != null && draft != original;

  String? get validationError {
    final v = draft?.commissionRate;
    if (v == null) return null;
    if (v < 0 || v > 100) return 'Commission must be between 0 and 100.';
    return null;
  }

  bool get canSave => isDirty && validationError == null && !saving;

  CommissionState copyWith({
    CommissionStatus? status,
    PlatformSettings? original,
    PlatformSettings? draft,
    String? error,
    bool clearError = false,
    bool? saving,
  }) =>
      CommissionState(
        status: status ?? this.status,
        original: original ?? this.original,
        draft: draft ?? this.draft,
        error: clearError ? null : (error ?? this.error),
        saving: saving ?? this.saving,
      );

  @override
  List<Object?> get props => [status, original, draft, error, saving];
}
