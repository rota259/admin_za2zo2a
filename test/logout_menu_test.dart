import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:za2zo2a_admin/core/network/dio_client.dart';
import 'package:za2zo2a_admin/core/router/app_router.dart';
import 'package:za2zo2a_admin/core/router/app_routes.dart';
import 'package:za2zo2a_admin/core/services/session_manager.dart';
import 'package:za2zo2a_admin/core/theme/app_theme.dart';
import 'package:za2zo2a_admin/core/util/ambient_motion.dart';
import 'package:za2zo2a_admin/core/theme/theme_cubit.dart';
import 'package:za2zo2a_admin/features/auth/cubit/auth_cubit.dart';
import 'package:za2zo2a_admin/features/auth/data/models/admin_model.dart';
import 'package:za2zo2a_admin/features/auth/data/repos/auth_repo.dart';
import 'package:za2zo2a_admin/features/auth/views/login_view.dart';
import 'package:za2zo2a_admin/features/shell/cubit/nav_counts_cubit.dart';
import 'package:za2zo2a_admin/features/shell/cubit/shell_cubit.dart';
import 'package:za2zo2a_admin/features/shell/data/repos/nav_counts_repo.dart';
import 'package:za2zo2a_admin/features/shell/views/admin_shell.dart';

const _admin = AdminModel(
  id: '1',
  name: 'System Admin',
  email: 'admin@za2zoo2a.com',
  role: 'admin',
);

class FakeAuthRepo extends AuthRepo {
  FakeAuthRepo(super.client, super.session);
  bool _logged = true;
  @override
  bool get isLoggedIn => _logged;
  @override
  Future<AdminModel> login({required String email, required String password}) async {
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
      const NavCounts(pendingDrivers: 0, pendingSelfies: 0);
}

Future<void> _loadFonts() async {
  const families = {
    'Hanken Grotesk': [
      'assets/fonts/HankenGrotesk-Regular.ttf',
      'assets/fonts/HankenGrotesk-Medium.ttf',
      'assets/fonts/HankenGrotesk-SemiBold.ttf',
      'assets/fonts/HankenGrotesk-Bold.ttf',
    ],
    'JetBrains Mono': ['assets/fonts/JetBrainsMono-Regular.ttf'],
  };
  for (final e in families.entries) {
    final loader = FontLoader(e.key);
    for (final p in e.value) {
      final f = File(p);
      if (f.existsSync()) {
        loader.addFont(Future.value(ByteData.view(f.readAsBytesSync().buffer)));
      }
    }
    await loader.load();
  }
}

void main() {
  setUpAll(() async {
    AmbientMotion.enabled = false;
    await _loadFonts();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (call) async => call.method == 'readAll' ? <String, String>{} : null,
    );
  });

  testWidgets('tapping Sign out from the profile menu returns to login',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final session = SessionManager();
    final client = DioClient(session);
    final auth = AuthCubit(FakeAuthRepo(client, session));
    final counts = NavCountsCubit(FakeNavCountsRepo(client));
    final router = AppRouter(auth);

    // Start signed in on the dashboard (FakeAuthRepo returns the admin).
    await auth.login('admin@za2zoo2a.com', 'x');

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: auth),
          BlocProvider<ThemeCubit>.value(value: ThemeCubit(session)),
          BlocProvider<ShellCubit>.value(value: ShellCubit()),
          BlocProvider<NavCountsCubit>.value(value: counts),
        ],
        child: BlocListener<AuthCubit, AuthState>(
          listenWhen: (a, b) => a.status != b.status,
          listener: (context, state) {
            switch (state.status) {
              case AuthStatus.authenticated:
                router.router.go(AppRoutes.dashboard);
              case AuthStatus.unauthenticated:
                router.router.go(AppRoutes.login);
              case AuthStatus.unknown:
                break;
            }
          },
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            routerConfig: router.router,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // On the shell.
    expect(find.byType(AdminShell), findsOneWidget);

    // Open the profile menu (tap the avatar/name) then tap Sign out.
    await tester.tap(find.text('System Admin'));
    await tester.pumpAndSettle();
    expect(find.text('Sign out'), findsOneWidget);

    final signOut = find.widgetWithText(MenuItemButton, 'Sign out');
    expect(signOut, findsOneWidget);
    await tester.tap(signOut);
    await tester.pump();
    await tester.pumpAndSettle();

    // Must be back on the login screen.
    expect(find.byType(AdminShell), findsNothing,
        reason: 'Sign out should leave the shell');
    expect(find.byType(LoginView), findsOneWidget,
        reason: 'Sign out should return to the login screen');
  });
}
