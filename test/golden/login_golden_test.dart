import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:za2zo2a_admin/core/network/dio_client.dart';
import 'package:za2zo2a_admin/core/services/session_manager.dart';
import 'package:za2zo2a_admin/core/theme/app_theme.dart';
import 'package:za2zo2a_admin/core/util/ambient_motion.dart';
import 'package:za2zo2a_admin/features/auth/cubit/auth_cubit.dart';
import 'package:za2zo2a_admin/features/auth/data/repos/auth_repo.dart';
import 'package:za2zo2a_admin/features/auth/views/login_view.dart';

/// Renders the real login screen to a PNG.
///
/// The Flutter Web preview pane keeps the document hidden, so CanvasKit never
/// paints and a browser screenshot can't be captured there. These goldens
/// render the actual widget tree through Skia instead — same widgets, same
/// theme tokens, same bundled fonts as the browser build.
///
/// Regenerate with:  flutter test --update-goldens
/// The test harness doesn't load pubspec-declared asset fonts — it renders
/// every glyph as a filled box. Load the same bundled TTFs the app ships, so
/// the goldens are a true picture of the browser output.
Future<void> _loadBundledFonts() async {
  const families = {
    'Hanken Grotesk': [
      'assets/fonts/HankenGrotesk-Regular.ttf',
      'assets/fonts/HankenGrotesk-Medium.ttf',
      'assets/fonts/HankenGrotesk-SemiBold.ttf',
      'assets/fonts/HankenGrotesk-Bold.ttf',
    ],
    'JetBrains Mono': [
      'assets/fonts/JetBrainsMono-Regular.ttf',
      'assets/fonts/JetBrainsMono-Medium.ttf',
      'assets/fonts/JetBrainsMono-SemiBold.ttf',
    ],
  };

  for (final entry in families.entries) {
    final loader = FontLoader(entry.key);
    for (final path in entry.value) {
      final file = File(path);
      if (!file.existsSync()) continue;
      loader.addFont(
        Future.value(ByteData.view(file.readAsBytesSync().buffer)),
      );
    }
    await loader.load();
  }
}

void main() {
  setUpAll(() async {
    AmbientMotion.enabled = false;
    await _loadBundledFonts();

    // flutter_secure_storage talks to a platform channel that doesn't exist in
    // the test harness — stub it so SessionManager/AuthRepo can be built.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
          (call) async => call.method == 'readAll' ? <String, String>{} : null,
        );
  });

  Widget harness({required ThemeData theme}) {
    final session = SessionManager();
    final repo = AuthRepo(DioClient(session), session);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: BlocProvider<AuthCubit>(
        create: (_) => AuthCubit(repo),
        child: const LoginView(),
      ),
    );
  }

  Future<void> renderAt(
    WidgetTester tester,
    Size size,
    ThemeData theme,
    String file,
  ) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(harness(theme: theme));
    await tester.pumpAndSettle();

    await expectLater(find.byType(LoginView), matchesGoldenFile(file));
  }

  testWidgets('login — desktop light', (tester) async {
    await renderAt(
      tester,
      const Size(1440, 900),
      AppTheme.light(),
      'login_desktop_light.png',
    );
  });

  testWidgets('login — desktop dark', (tester) async {
    await renderAt(
      tester,
      const Size(1440, 900),
      AppTheme.dark(),
      'login_desktop_dark.png',
    );
  });

  testWidgets('login — tablet light (brand panel drops away)', (tester) async {
    await renderAt(
      tester,
      const Size(1000, 900),
      AppTheme.light(),
      'login_tablet_light.png',
    );
  });
}
