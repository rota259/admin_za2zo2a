import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:za2zo2a_admin/core/network/dio_client.dart';
import 'package:za2zo2a_admin/core/router/app_router.dart';
import 'package:za2zo2a_admin/core/services/session_manager.dart';
import 'package:za2zo2a_admin/core/theme/app_theme.dart';
import 'package:za2zo2a_admin/core/theme/theme_cubit.dart';
import 'package:za2zo2a_admin/features/auth/cubit/auth_cubit.dart';
import 'package:za2zo2a_admin/features/auth/data/models/admin_model.dart';
import 'package:za2zo2a_admin/features/auth/data/repos/auth_repo.dart';
import 'package:za2zo2a_admin/features/auth/views/login_view.dart';
import 'package:za2zo2a_admin/features/dashboard/views/dashboard_view.dart';
import 'package:za2zo2a_admin/features/shell/cubit/nav_counts_cubit.dart';
import 'package:za2zo2a_admin/features/shell/cubit/shell_cubit.dart';
import 'package:za2zo2a_admin/features/shell/data/repos/nav_counts_repo.dart';
import 'package:za2zo2a_admin/features/shell/views/admin_shell.dart';

/// Regression cover for the login → dashboard redirect.
///
/// Reported symptom: after a 200 login, the UI stays on the login screen. That
/// reproduced only in the preview pane, which keeps the document hidden so
/// Flutter web suspends frame production — navigation resolves but the rebuild
/// never runs. This test pumps real frames headless and asserts the shell
/// actually renders, mirroring main.dart's wiring exactly (refreshListenable +
/// redirect guard; no imperative navigation).

const _admin = AdminModel(
  id: '6a5517048b362575a4309c12',
  name: 'System Admin',
  email: 'admin@za2zoo2a.com',
  role: 'admin',
);

/// Authenticates without HTTP — the network path is already proven by the
/// browser tests (200 + token). This isolates the navigation glue.
class FakeAuthRepo extends AuthRepo {
  FakeAuthRepo(super.client, super.session);

  bool _logged = false;

  @override
  bool get isLoggedIn => _logged;

  @override
  Future<AdminModel> login({
    required String email,
    required String password,
  }) async {
    _logged = true;
    return _admin;
  }

  @override
  Future<AdminModel> me() async => _admin;

  @override
  Future<void> logout() async => _logged = false;
}

class FakeNavCountsRepo extends NavCountsRepo {
  FakeNavCountsRepo(super.client);
  @override
  Future<NavCounts> fetch() async =>
      const NavCounts(pendingDrivers: 21, pendingSelfies: 0);
}

/// Load the bundled TTFs so text measures at real widths (the harness's
/// fixed-width block font would otherwise overflow narrow rows and throw).
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
            Future.value(ByteData.view(file.readAsBytesSync().buffer)));
      }
    }
    await loader.load();
  }
}

void main() {
  setUpAll(() async {
    await _loadBundledFonts();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (call) async => call.method == 'readAll' ? <String, String>{} : null,
    );
  });

  /// Mirrors main.dart's widget wiring: providers + the badge-priming listener
  /// + MaterialApp.router. Navigation is driven entirely by the router's
  /// refreshListenable + redirect guard — exactly as in production.
  Widget buildApp({
    required AuthCubit auth,
    required NavCountsCubit counts,
    required AppRouter router,
  }) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: auth),
        BlocProvider<ThemeCubit>.value(value: ThemeCubit(SessionManager())),
        BlocProvider<ShellCubit>.value(value: ShellCubit()),
        BlocProvider<NavCountsCubit>.value(value: counts),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listenWhen: (a, b) => a.status != b.status,
        listener: (context, state) {
          if (state.isAuthenticated) counts.load();
        },
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          routerConfig: router.router,
        ),
      ),
    );
  }

  testWidgets('login redirects to the dashboard shell', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final session = SessionManager();
    final client = DioClient(session);
    final auth = AuthCubit(FakeAuthRepo(client, session));
    final counts = NavCountsCubit(FakeNavCountsRepo(client));
    final router = AppRouter(auth);

    // Resolve status before the guard evaluates (unauthenticated here).
    await auth.bootstrap();

    await tester.pumpWidget(buildApp(auth: auth, counts: counts, router: router));
    await tester.pumpAndSettle();

    // Starts on the login screen.
    expect(find.byType(LoginView), findsOneWidget);
    expect(find.byType(AdminShell), findsNothing);

    // Log in the way the form does.
    await auth.login('admin@za2zoo2a.com', 'Admin@123456');
    await tester.pumpAndSettle();

    // The shell must now be rendered and the login screen gone.
    expect(find.byType(LoginView), findsNothing,
        reason: 'LoginView should be removed after a successful login');
    expect(find.byType(AdminShell), findsOneWidget,
        reason: 'AdminShell should render after the login redirect');
    expect(find.byType(DashboardView), findsOneWidget);
  });

  testWidgets('logout returns to the login screen', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final session = SessionManager();
    final client = DioClient(session);
    final auth = AuthCubit(FakeAuthRepo(client, session));
    final counts = NavCountsCubit(FakeNavCountsRepo(client));
    final router = AppRouter(auth);
    await auth.bootstrap();

    await tester.pumpWidget(buildApp(auth: auth, counts: counts, router: router));
    await auth.login('admin@za2zoo2a.com', 'Admin@123456');
    await tester.pumpAndSettle();
    expect(find.byType(AdminShell), findsOneWidget);

    await auth.logout();
    await tester.pumpAndSettle();

    expect(find.byType(AdminShell), findsNothing);
    expect(find.byType(LoginView), findsOneWidget);
  });
}
