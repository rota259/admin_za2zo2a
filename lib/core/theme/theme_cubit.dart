import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/session_manager.dart';

/// Light/dark toggle. The design ships both themes and the top bar exposes a
/// sun/moon switch; the choice is persisted per-device (there is no backend
/// field for it — same call the mobile app made).
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._session) : super(ThemeMode.light);

  final SessionManager _session;

  Future<void> load() async {
    final isDark = await _session.readDarkMode();
    emit(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> toggle() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    emit(next);
    await _session.saveDarkMode(next == ThemeMode.dark);
  }
}
