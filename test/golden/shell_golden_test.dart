import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:za2zo2a_admin/core/network/dio_client.dart';
import 'package:za2zo2a_admin/core/services/session_manager.dart';
import 'package:za2zo2a_admin/core/theme/app_theme.dart';
import 'package:za2zo2a_admin/core/util/ambient_motion.dart';
import 'package:za2zo2a_admin/core/theme/theme_cubit.dart';
import 'package:za2zo2a_admin/features/auth/cubit/auth_cubit.dart';
import 'package:za2zo2a_admin/features/auth/data/models/admin_model.dart';
import 'package:za2zo2a_admin/features/auth/data/repos/auth_repo.dart';
import 'package:za2zo2a_admin/features/dashboard/views/dashboard_view.dart';
import 'package:za2zo2a_admin/features/dashboard/views/widgets/dashboard_header.dart';
import 'package:za2zo2a_admin/features/shell/cubit/nav_counts_cubit.dart';
import 'package:za2zo2a_admin/features/shell/cubit/shell_cubit.dart';
import 'package:za2zo2a_admin/features/shell/data/repos/nav_counts_repo.dart';
import 'package:za2zo2a_admin/features/shell/views/admin_shell.dart';

/// Seeds an authenticated session without touching the network.
/// The admin below is the REAL record returned by the live backend's
/// GET /api/admin/auth/me — id and all.
class _SeededAuthCubit extends AuthCubit {
  _SeededAuthCubit(super.repo);

  void seed() => emit(
    const AuthState(
      status: AuthStatus.authenticated,
      admin: AdminModel(
        id: '6a5517048b362575a4309c12',
        name: 'System Admin',
        email: 'admin@za2zoo2a.com',
        role: 'admin',
      ),
    ),
  );
}

/// Seeds the sidebar badge counts without hitting the network.
/// The values mirror what the live backend actually returns today
/// (21 pending drivers, 0 pending selfies — so Selfie Review shows no badge).
class _SeededNavCountsCubit extends NavCountsCubit {
  _SeededNavCountsCubit(super.repo);

  void seed() => emit(const NavCounts(pendingDrivers: 21, pendingSelfies: 0));
}

Future<void> _loadBundledFonts() async {
  const families = {
    'Hanken Grotesk': [
      'assets/fonts/HankenGrotesk-Regular.ttf',
      'assets/fonts/HankenGrotesk-Medium.ttf',
      'assets/fonts/HankenGrotesk-SemiBold.ttf',
      'assets/fonts/HankenGrotesk-Bold.ttf',
    ],
    'JetBrains Mono': ['assets/fonts/JetBrainsMono-Regular.ttf'],
  };
  for (final entry in families.entries) {
    final loader = FontLoader(entry.key);
    for (final path in entry.value) {
      final file = File(path);
      if (file.existsSync()) {
        loader.addFont(
          Future.value(ByteData.view(file.readAsBytesSync().buffer)),
        );
      }
    }
    await loader.load();
  }
}

void main() {
  setUpAll(() async {
    AmbientMotion.enabled = false;
    await _loadBundledFonts();
    // Pin the greeting so the golden doesn't drift with the wall clock.
    DashboardHeader.clock = () => DateTime(2026, 7, 18, 14);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
          (call) async => call.method == 'readAll' ? <String, String>{} : null,
        );
  });

  tearDownAll(() => DashboardHeader.clock = DateTime.now);

  Future<void> renderShell(
    WidgetTester tester,
    Size size,
    ThemeData theme,
    String file,
  ) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final session = SessionManager();
    final client = DioClient(session);
    final auth = _SeededAuthCubit(AuthRepo(client, session))..seed();
    final counts = _SeededNavCountsCubit(NavCountsRepo(client))..seed();

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        ShellRoute(
          builder: (context, state, child) => AdminShell(child: child),
          routes: [
            GoRoute(path: '/', builder: (_, _) => const DashboardView()),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: auth),
          BlocProvider<ThemeCubit>.value(value: ThemeCubit(session)),
          BlocProvider<ShellCubit>.value(value: ShellCubit()),
          BlocProvider<NavCountsCubit>.value(value: counts),
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: theme,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(find.byType(AdminShell), matchesGoldenFile(file));
  }

  testWidgets('shell — desktop light (sidebar expanded)', (tester) async {
    await renderShell(
      tester,
      const Size(1440, 900),
      AppTheme.light(),
      'shell_desktop_light.png',
    );
  });

  testWidgets('shell — desktop dark', (tester) async {
    await renderShell(
      tester,
      const Size(1440, 900),
      AppTheme.dark(),
      'shell_desktop_dark.png',
    );
  });

  testWidgets('shell — tablet (sidebar force-collapsed to icons)', (
    tester,
  ) async {
    await renderShell(
      tester,
      const Size(1000, 800),
      AppTheme.light(),
      'shell_tablet_light.png',
    );
  });
}
