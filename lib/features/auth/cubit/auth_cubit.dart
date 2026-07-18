import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_error.dart';
import '../data/models/admin_model.dart';
import '../data/repos/auth_repo.dart';

part 'auth_state.dart';

/// Owns all auth state and logic. The login view holds none of it.
///
/// The router listens to this cubit and redirects on every status change, so
/// `authenticated`/`unauthenticated` are the single source of truth for access.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repo) : super(const AuthState());

  final AuthRepo _repo;

  /// Boot check, before the first frame paints.
  ///
  /// A stored token is not trusted on its own — it may be expired or revoked,
  /// so it's verified against GET /api/admin/auth/me. Anything other than a
  /// clean 200 lands the operator on the login screen.
  Future<void> bootstrap() async {
    if (!_repo.isLoggedIn) {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
      return;
    }
    try {
      final admin = await _repo.me();
      emit(state.copyWith(status: AuthStatus.authenticated, admin: admin));
    } on ApiError {
      await _repo.logout();
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> login(String email, String password) async {
    if (state.isSubmitting) return;

    if (email.trim().isEmpty || password.isEmpty) {
      emit(state.copyWith(error: 'Enter your email and password.'));
      return;
    }

    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      final admin = await _repo.login(email: email, password: password);
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        admin: admin,
        isSubmitting: false,
      ));
    } on ApiError catch (e) {
      emit(state.copyWith(isSubmitting: false, error: e.message));
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  /// Called by the dio interceptor when any request 401s.
  void onSessionExpired() {
    if (state.status == AuthStatus.unauthenticated) return;
    emit(const AuthState(
      status: AuthStatus.unauthenticated,
      error: 'Your session has expired. Please sign in again.',
    ));
  }

  void clearError() => emit(state.copyWith(clearError: true));
}
