part of 'auth_cubit.dart';

enum AuthStatus {
  /// Boot: checking for a stored token before the router decides anything.
  unknown,
  authenticated,
  unauthenticated,
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.admin,
    this.isSubmitting = false,
    this.error,
  });

  final AuthStatus status;
  final AdminModel? admin;

  /// True while a login request is in flight — drives the button spinner.
  final bool isSubmitting;

  /// Last login failure, shown inline on the form.
  final String? error;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    AdminModel? admin,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
  }) =>
      AuthState(
        status: status ?? this.status,
        admin: admin ?? this.admin,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        error: clearError ? null : (error ?? this.error),
      );

  @override
  List<Object?> get props => [status, admin, isSubmitting, error];
}
