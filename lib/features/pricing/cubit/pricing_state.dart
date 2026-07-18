part of 'pricing_cubit.dart';

enum PricingStatus { loading, ready, error }

class PricingState extends Equatable {
  const PricingState({
    this.status = PricingStatus.loading,
    this.original,
    this.draft,
    this.error,
    this.saving = false,
  });

  final PricingStatus status;

  /// The last saved config (what riders/drivers currently see).
  final PricingConfig? original;

  /// The working copy being edited.
  final PricingConfig? draft;

  final String? error;
  final bool saving;

  /// True when the draft differs from what's live.
  bool get isDirty =>
      original != null && draft != null && draft != original;

  /// A validation message that would block a save, or null when valid.
  String? get validationError => draft?.validationError();

  bool get canSave => isDirty && validationError == null && !saving;

  PricingState copyWith({
    PricingStatus? status,
    PricingConfig? original,
    PricingConfig? draft,
    String? error,
    bool clearError = false,
    bool? saving,
  }) =>
      PricingState(
        status: status ?? this.status,
        original: original ?? this.original,
        draft: draft ?? this.draft,
        error: clearError ? null : (error ?? this.error),
        saving: saving ?? this.saving,
      );

  @override
  List<Object?> get props => [status, original, draft, error, saving];
}
