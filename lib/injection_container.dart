import 'package:get_it/get_it.dart';

import 'core/network/dio_client.dart';
import 'core/services/session_manager.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'features/auth/data/repos/auth_repo.dart';
import 'features/drivers/cubit/drivers_list_cubit.dart';
import 'features/drivers/data/repos/drivers_repo.dart';
import 'features/notifications/cubit/notif_compose_cubit.dart';
import 'features/notifications/data/repos/notifications_repo.dart';
import 'features/pricing/data/repos/pricing_repo.dart';
import 'features/riders/cubit/riders_list_cubit.dart';
import 'features/riders/data/repos/riders_repo.dart';
import 'features/selfie/data/repos/selfie_repo.dart';
import 'features/settings/cubit/audit_cubit.dart';
import 'features/settings/cubit/commission_cubit.dart';
import 'features/settings/cubit/support_tickets_cubit.dart';
import 'features/settings/cubit/zones_cubit.dart';
import 'features/settings/data/repos/settings_repo.dart';
import 'features/shell/cubit/nav_counts_cubit.dart';
import 'features/shell/cubit/shell_cubit.dart';
import 'features/shell/data/repos/nav_counts_repo.dart';
import 'features/trips/cubit/trips_list_cubit.dart';
import 'features/trips/data/repos/trips_repo.dart';

final sl = GetIt.instance;

/// Service locator setup — same shape as the mobile app's
/// `injection_container.dart`: lazy singletons for core + repos, and the
/// long-lived cubits registered as singletons because the router and shell
/// both read them.
Future<void> init() async {
  if (sl.isRegistered<DioClient>()) return;

  // ── Core ────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<SessionManager>(() => SessionManager());
  sl.registerLazySingleton<DioClient>(() => DioClient(sl<SessionManager>()));

  // ── Repos ───────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepo>(
    () => AuthRepo(sl<DioClient>(), sl<SessionManager>()),
  );
  sl.registerLazySingleton<NavCountsRepo>(() => NavCountsRepo(sl<DioClient>()));
  sl.registerLazySingleton<DriversRepo>(() => DriversRepo(sl<DioClient>()));
  sl.registerLazySingleton<SelfieRepo>(() => SelfieRepo(sl<DioClient>()));
  sl.registerLazySingleton<PricingRepo>(() => PricingRepo(sl<DioClient>()));
  sl.registerLazySingleton<NotificationsRepo>(
      () => NotificationsRepo(sl<DioClient>()));
  sl.registerLazySingleton<RidersRepo>(() => RidersRepo(sl<DioClient>()));
  sl.registerLazySingleton<TripsRepo>(() => TripsRepo(sl<DioClient>()));
  sl.registerLazySingleton<SettingsRepo>(() => SettingsRepo(sl<DioClient>()));

  // ── Cubits ──────────────────────────────────────────────────────────────
  // AuthCubit is a singleton: the router's redirect guard reads the same
  // instance the login form writes to.
  sl.registerLazySingleton<AuthCubit>(() => AuthCubit(sl<AuthRepo>()));
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit(sl<SessionManager>()));
  sl.registerLazySingleton<ShellCubit>(() => ShellCubit());
  // Sidebar badge counts — singleton so any screen can refresh them after an
  // action that changes a queue.
  sl.registerLazySingleton<NavCountsCubit>(
    () => NavCountsCubit(sl<NavCountsRepo>()),
  );
  // Screen-scoped cubits — a fresh instance per screen mount.
  sl.registerFactory<DriversListCubit>(
    () => DriversListCubit(sl<DriversRepo>()),
  );
  sl.registerFactory<NotifComposeCubit>(
    () => NotifComposeCubit(sl<NotificationsRepo>()),
  );
  sl.registerFactory<RidersListCubit>(
    () => RidersListCubit(sl<RidersRepo>()),
  );
  sl.registerFactory<TripsListCubit>(
    () => TripsListCubit(sl<TripsRepo>()),
  );
  sl.registerFactory<CommissionCubit>(
    () => CommissionCubit(sl<SettingsRepo>()),
  );
  sl.registerFactory<ZonesCubit>(() => ZonesCubit(sl<SettingsRepo>()));
  sl.registerFactory<SupportTicketsCubit>(
    () => SupportTicketsCubit(sl<SettingsRepo>()),
  );
  sl.registerFactory<AuditCubit>(() => AuditCubit(sl<SettingsRepo>()));

  // Warm the in-memory token cache so the dio interceptor can attach it
  // before the router evaluates its first redirect.
  await sl<SessionManager>().bootstrap();
}
