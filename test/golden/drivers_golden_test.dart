import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:za2zo2a_admin/core/network/dio_client.dart';
import 'package:za2zo2a_admin/core/services/session_manager.dart';
import 'package:za2zo2a_admin/core/theme/app_theme.dart';
import 'package:za2zo2a_admin/features/drivers/cubit/drivers_list_cubit.dart';
import 'package:za2zo2a_admin/features/drivers/data/models/driver_model.dart';
import 'package:za2zo2a_admin/features/drivers/data/repos/drivers_repo.dart';
import 'package:za2zo2a_admin/features/drivers/views/driver_detail_view.dart';
import 'package:za2zo2a_admin/features/drivers/views/drivers_list_view.dart';

Map<String, dynamic> _driver({
  required String id,
  required String name,
  required String phone,
  required String tier,
  required double rating,
  required int trips,
  required String make,
  required String model,
  bool active = true,
  String license = 'approved',
}) =>
    {
      '_id': id,
      'tier': tier,
      'isOnline': active,
      'vehicle': {
        'make': make,
        'model': model,
        'color': 'White',
        'plateNumber': 'XYZ-${trips}0',
        'year': 2021,
        'seats': 4,
      },
      'documents': {
        'drivingLicense': {'status': license},
        'carLicense': {'status': 'approved'},
        'nationalId': {'status': 'approved'},
        'criminalRecord': {'status': license == 'pending' ? 'pending' : 'approved'},
        'profilePhoto': {'status': 'approved'},
      },
      'earnings': {'totalLifetime': trips * 37.5},
      'stats': {'totalTrips': trips, 'acceptanceRate': 94},
      'user': {
        '_id': 'u$id',
        'fullName': name,
        'email': '${name.split(' ').first.toLowerCase()}@test.com',
        'phone': phone,
        'rating': rating,
        'isVerified': active && license == 'approved',
        'isActive': active,
        'createdAt': '2026-03-12T10:00:00.000Z',
      },
    };

final _drivers = [
  _driver(id: '1', name: 'Ahmed Hassan', phone: '01035599526', tier: 'gold', rating: 4.9, trips: 1284, make: 'Toyota', model: 'Corolla'),
  _driver(id: '2', name: 'Mona Salah', phone: '01122334455', tier: 'platinum', rating: 4.8, trips: 842, make: 'Hyundai', model: 'Elantra'),
  _driver(id: '3', name: 'Karim Adel', phone: '01099887766', tier: 'standard', rating: 4.5, trips: 96, make: 'Kia', model: 'Cerato', license: 'pending'),
  _driver(id: '4', name: 'Sara Nabil', phone: '01555443322', tier: 'standard', rating: 4.7, trips: 310, make: 'Nissan', model: 'Sunny'),
  _driver(id: '5', name: 'Omar Fathy', phone: '01011223344', tier: 'gold', rating: 4.2, trips: 512, make: 'Toyota', model: 'Yaris', active: false),
];

class _FakeDriversRepo extends DriversRepo {
  _FakeDriversRepo() : super(DioClient(SessionManager()));

  @override
  Future<DriverPage> list({String? status, int page = 1, int limit = 20}) async =>
      DriverPage(
        drivers: [for (final d in _drivers) DriverModel.fromJson(d)],
        page: 1,
        pages: 2,
        total: 22,
      );

  @override
  Future<DriverCounts> counts() async =>
      const DriverCounts(all: 22, pending: 21, blocked: 1);

  @override
  Future<DriverModel> detail(String id) async =>
      DriverModel.fromJson(_driver(
        id: '3',
        name: 'Karim Adel',
        phone: '01099887766',
        tier: 'standard',
        rating: 4.5,
        trips: 96,
        make: 'Kia',
        model: 'Cerato',
        license: 'pending',
      ));
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
    final sl = GetIt.instance;
    sl.registerLazySingleton<DriversRepo>(() => _FakeDriversRepo());
    sl.registerFactory<DriversListCubit>(
        () => DriversListCubit(sl<DriversRepo>()));
  });

  tearDownAll(() => GetIt.instance.reset());

  Future<void> pump(WidgetTester tester, Widget child, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: Scaffold(body: child),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('drivers list — desktop light', (tester) async {
    await pump(tester, const DriversListView(), const Size(1180, 900));
    await expectLater(find.byType(DriversListView),
        matchesGoldenFile('drivers_list_light.png'));
  });

  testWidgets('driver detail — desktop light', (tester) async {
    await pump(tester, const DriverDetailView(driverId: '3'),
        const Size(1180, 1000));
    await expectLater(find.byType(DriverDetailView),
        matchesGoldenFile('driver_detail_light.png'));
  });
}
