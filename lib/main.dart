import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/network/dio_client.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'features/shell/cubit/nav_counts_cubit.dart';
import 'features/shell/cubit/shell_cubit.dart';
import 'injection_container.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();

  final auth = di.sl<AuthCubit>();

  // Any 401 from any request drops the session; the router's guard sees the
  // state change via refreshListenable and redirects to /login.
  DioClient.onUnauthorized = auth.onSessionExpired;

  // Resolve the stored token before the first frame, so the guard doesn't
  // flash the login screen at an already-signed-in operator.
  //
  // Never let boot work sink the app: if session restore or the theme read
  // fails (corrupt storage, offline), fall through to an unauthenticated
  // start — the operator sees the login screen, not a blank page.
  try {
    await Future.wait([auth.bootstrap(), di.sl<ThemeCubit>().load()]);
  } catch (e) {
    debugPrint('Boot failed, starting signed-out: $e');
    await auth.logout();
  }

  // A restored session is already authenticated by this point, so the in-app
  // listener would never see a transition — prime the badges here instead.
  if (auth.state.isAuthenticated) {
    unawaited(di.sl<NavCountsCubit>().load());
  }

  runApp(const Za2zo2aAdminApp());
}

class Za2zo2aAdminApp extends StatefulWidget {
  const Za2zo2aAdminApp({super.key});

  @override
  State<Za2zo2aAdminApp> createState() => _Za2zo2aAdminAppState();
}

class _Za2zo2aAdminAppState extends State<Za2zo2aAdminApp> {
  // Built once. Constructing the router inside build() would hand
  // MaterialApp.router a new GoRouter (and a new refreshListenable) on every
  // theme rebuild, losing navigation state and dropping auth redirects.
  late final AppRouter _appRouter = AppRouter(di.sl<AuthCubit>());

  @override
  Widget build(BuildContext context) {
    final auth = di.sl<AuthCubit>();

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: auth),
        BlocProvider<ThemeCubit>.value(value: di.sl<ThemeCubit>()),
        BlocProvider<ShellCubit>.value(value: di.sl<ShellCubit>()),
        BlocProvider<NavCountsCubit>.value(value: di.sl<NavCountsCubit>()),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        // The router's refreshListenable + redirect guard drives navigation on
        // every auth transition (login → dashboard, logout/401 → login) — see
        // AppRouter and the login_flow_test that pins this. This listener only
        // primes the sidebar badge counts when a session starts.
        listenWhen: (a, b) => a.status != b.status,
        listener: (context, state) {
          if (state.isAuthenticated) di.sl<NavCountsCubit>().load();
        },
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, mode) {
            return MaterialApp.router(
              title: 'Za2zo2a Operator Console',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: mode,
              routerConfig: _appRouter.router,
            );
          },
        ),
      ),
    );
  }
}
