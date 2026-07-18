import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:za2zo2a_admin/core/network/dio_client.dart';
import 'package:za2zo2a_admin/core/services/session_manager.dart';
import 'package:za2zo2a_admin/core/theme/app_theme.dart';
import 'package:za2zo2a_admin/features/pricing/data/models/pricing_config.dart';
import 'package:za2zo2a_admin/features/pricing/data/repos/pricing_repo.dart';
import 'package:za2zo2a_admin/features/pricing/views/pricing_view.dart';

class _FakePricingRepo extends PricingRepo {
  _FakePricingRepo() : super(DioClient(SessionManager()));

  @override
  Future<PricingConfig> get() async => PricingConfig.fromJson(const {
        'baseFare': 5,
        'pickupSurcharge': 2,
        'minFare': 15,
        'surgeMultiplier': 1.5,
        'waitingPerMin': 0.75,
        'cancellationFee': 10,
        'currency': 'EGP',
        'perKmTiers': [
          {'uptoKm': 5, 'pricePerKm': 2},
          {'uptoKm': 15, 'pricePerKm': 1.5},
          {'uptoKm': null, 'pricePerKm': 1},
        ],
      });
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
    await _loadFonts();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (call) async => call.method == 'readAll' ? <String, String>{} : null,
    );
    GetIt.instance.registerLazySingleton<PricingRepo>(() => _FakePricingRepo());
  });

  tearDownAll(() => GetIt.instance.reset());

  testWidgets('pricing control — desktop light', (tester) async {
    tester.view.physicalSize = const Size(1180, 1100);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const Scaffold(body: PricingView()),
    ));
    await tester.pumpAndSettle();

    await expectLater(
        find.byType(PricingView), matchesGoldenFile('pricing_light.png'));
  });
}
