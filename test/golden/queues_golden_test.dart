import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:za2zo2a_admin/core/network/dio_client.dart';
import 'package:za2zo2a_admin/core/services/session_manager.dart';
import 'package:za2zo2a_admin/core/theme/app_theme.dart';
import 'package:za2zo2a_admin/features/approval/views/approval_queue_view.dart';
import 'package:za2zo2a_admin/features/drivers/data/models/driver_model.dart';
import 'package:za2zo2a_admin/features/drivers/data/repos/drivers_repo.dart';
import 'package:za2zo2a_admin/features/selfie/data/models/selfie_check.dart';
import 'package:za2zo2a_admin/features/selfie/data/repos/selfie_repo.dart';
import 'package:za2zo2a_admin/features/selfie/views/selfie_review_view.dart';
import 'package:za2zo2a_admin/features/shell/cubit/nav_counts_cubit.dart';
import 'package:za2zo2a_admin/features/shell/data/repos/nav_counts_repo.dart';

Map<String, dynamic> _pendingDriver(String id, String name, String phone,
        String make, String model) =>
    {
      '_id': id,
      'tier': 'standard',
      'isOnline': false,
      'vehicle': {
        'make': make,
        'model': model,
        'color': 'White',
        'plateNumber': 'AB-$id$id',
        'year': 2021,
        'seats': 4,
      },
      'documents': {
        'drivingLicense': {'status': 'pending'},
        'carLicense': {'status': 'submitted'},
        'nationalId': {'status': 'approved'},
        'criminalRecord': {'status': 'pending'},
        'profilePhoto': {'status': 'submitted'},
      },
      'earnings': {'totalLifetime': 0},
      'stats': {'totalTrips': 0, 'acceptanceRate': 0},
      'user': {
        '_id': 'u$id',
        'fullName': name,
        'email': '${name.split(' ').first.toLowerCase()}@test.com',
        'phone': phone,
        'rating': 5.0,
        'isVerified': false,
        'isActive': true,
        'createdAt': '2026-07-10T10:00:00.000Z',
      },
    };

class _FakeDriversRepo extends DriversRepo {
  _FakeDriversRepo() : super(DioClient(SessionManager()));
  @override
  Future<DriverPage> list({String? status, int page = 1, int limit = 20}) async =>
      DriverPage(
        drivers: [
          DriverModel.fromJson(
              _pendingDriver('1', 'Youssef Kamal', '01099887711', 'Kia', 'Cerato')),
          DriverModel.fromJson(
              _pendingDriver('2', 'Layla Hassan', '01233445566', 'Hyundai', 'Accent')),
        ],
        page: 1,
        pages: 1,
        total: 2,
      );
}

class _FakeSelfieRepo extends SelfieRepo {
  _FakeSelfieRepo() : super(DioClient(SessionManager()));
  @override
  Future<List<SelfieCheck>> pending() async => [
        for (var i = 0; i < 3; i++)
          SelfieCheck.fromJson({
            '_id': 's$i',
            'driver': {
              'fullName': ['Nour Adel', 'Hana Sami', 'Tarek Fouad'][i],
              'phone': '0100000000$i',
            },
            'photoUrl': '',
            'status': 'pending_review',
            'createdAt': '2026-07-18T09:0$i:00.000Z',
          }),
      ];
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
    sl.registerLazySingleton<SelfieRepo>(() => _FakeSelfieRepo());
    // The queues refresh the sidebar badge cubit after actions; provide a real
    // one backed by a repo that never gets called here.
    sl.registerLazySingleton<NavCountsRepo>(
        () => NavCountsRepo(DioClient(SessionManager())));
    sl.registerLazySingleton<NavCountsCubit>(
        () => NavCountsCubit(sl<NavCountsRepo>()));
  });

  tearDownAll(() => GetIt.instance.reset());

  Future<void> pump(WidgetTester tester, Widget child, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      BlocProvider<NavCountsCubit>.value(
        value: GetIt.instance<NavCountsCubit>(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          home: Scaffold(body: child),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('approval queue — desktop light', (tester) async {
    await pump(tester, const ApprovalQueueView(), const Size(1180, 1100));
    await expectLater(find.byType(ApprovalQueueView),
        matchesGoldenFile('approval_queue_light.png'));
  });

  testWidgets('selfie review — desktop light', (tester) async {
    await pump(tester, const SelfieReviewView(), const Size(1180, 900));
    await expectLater(find.byType(SelfieReviewView),
        matchesGoldenFile('selfie_review_light.png'));
  });
}
