import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/cubit/auth_cubit.dart';
import '../../features/auth/views/login_view.dart';
import '../../features/dashboard/views/dashboard_view.dart';
import '../../features/approval/views/approval_queue_view.dart';
import '../../features/drivers/views/driver_detail_view.dart';
import '../../features/drivers/views/drivers_list_view.dart';
import '../../features/notifications/views/notifications_view.dart';
import '../../features/pricing/views/pricing_view.dart';
import '../../features/riders/views/rider_detail_view.dart';
import '../../features/riders/views/riders_list_view.dart';
import '../../features/selfie/views/selfie_review_view.dart';
import '../../features/settings/views/settings_view.dart';
import '../../features/shell/views/admin_shell.dart';
import '../../features/trips/views/trip_detail_view.dart';
import '../../features/trips/views/trips_list_view.dart';
import '../widgets/z_empty_state.dart';
import 'app_routes.dart';
import 'page_transition.dart';
import 'router_refresh.dart';

/// App routing with an auth guard on every route except /login.
///
/// The guard is a single `redirect` — there is no per-screen check to forget.
/// It reads [AuthCubit] rather than storage directly, so a 401 from any
/// request (which flips the cubit) bounces the operator out immediately.
///
/// Every route uses [fadeSlidePage] so navigation shares one fade/slide
/// transition (login ↔ shell and between shell screens).
class AppRouter {
  AppRouter(this._auth);

  final AuthCubit _auth;

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.dashboard,
    refreshListenable: GoRouterRefreshStream(_auth.stream),
    redirect: _guard,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) =>
            fadeSlidePage(key: state.pageKey, child: const LoginView()),
      ),
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            pageBuilder: (context, state) =>
                fadeSlidePage(key: state.pageKey, child: const DashboardView()),
          ),
          GoRoute(
            path: AppRoutes.drivers,
            pageBuilder: (context, state) =>
                fadeSlidePage(key: state.pageKey, child: const DriversListView()),
          ),
          GoRoute(
            path: AppRoutes.driverDetail,
            pageBuilder: (context, state) => fadeSlidePage(
              key: state.pageKey,
              child: DriverDetailView(
                  driverId: state.pathParameters['id'] ?? ''),
            ),
          ),
          GoRoute(
            path: AppRoutes.approval,
            pageBuilder: (context, state) => fadeSlidePage(
                key: state.pageKey, child: const ApprovalQueueView()),
          ),
          GoRoute(
            path: AppRoutes.selfie,
            pageBuilder: (context, state) => fadeSlidePage(
                key: state.pageKey, child: const SelfieReviewView()),
          ),
          GoRoute(
            path: AppRoutes.pricing,
            pageBuilder: (context, state) =>
                fadeSlidePage(key: state.pageKey, child: const PricingView()),
          ),
          GoRoute(
            path: AppRoutes.notifications,
            pageBuilder: (context, state) => fadeSlidePage(
                key: state.pageKey, child: const NotificationsView()),
          ),
          GoRoute(
            path: AppRoutes.riders,
            pageBuilder: (context, state) =>
                fadeSlidePage(key: state.pageKey, child: const RidersListView()),
          ),
          GoRoute(
            path: AppRoutes.riderDetail,
            pageBuilder: (context, state) => fadeSlidePage(
              key: state.pageKey,
              child: RiderDetailView(riderId: state.pathParameters['id'] ?? ''),
            ),
          ),
          GoRoute(
            path: AppRoutes.trips,
            pageBuilder: (context, state) =>
                fadeSlidePage(key: state.pageKey, child: const TripsListView()),
          ),
          GoRoute(
            path: AppRoutes.tripDetail,
            pageBuilder: (context, state) => fadeSlidePage(
              key: state.pageKey,
              child: TripDetailView(tripId: state.pathParameters['id'] ?? ''),
            ),
          ),
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (context, state) =>
                fadeSlidePage(key: state.pageKey, child: const SettingsView()),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: ZEmptyState(
        title: 'Page not found',
        message: state.uri.path,
        icon: Icons.help_outline,
      ),
    ),
  );

  /// Returns a path to redirect to, or null to allow the navigation.
  String? _guard(BuildContext context, GoRouterState state) {
    final status = _auth.state.status;
    final goingToLogin = state.matchedLocation == AppRoutes.login;

    // Boot: hold position until bootstrap() resolves the stored token.
    if (status == AuthStatus.unknown) return null;

    final authed = status == AuthStatus.authenticated;

    // Unauthenticated anywhere but /login → /login.
    if (!authed && !goingToLogin) return AppRoutes.login;

    // Already signed in and hitting /login → dashboard.
    if (authed && goingToLogin) return AppRoutes.dashboard;

    return null;
  }
}
