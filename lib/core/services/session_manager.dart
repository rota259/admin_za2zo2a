import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the admin JWT and cached admin profile.
///
/// Same shape as the mobile app's `SessionManager`, minus the rider/driver
/// dual-account swapping and online-time tracking — the console has a single
/// owner account and no online state.
///
/// NOTE (web): flutter_secure_storage falls back to a JS/localStorage-backed
/// store on web, so this is not hardware-backed the way Keychain is on iOS.
/// It's an appropriate place for a short-lived JWT, not for anything else.
class SessionManager {
  static const _kToken = 'admin_token';
  static const _kAdmin = 'admin_user';
  static const _kDarkMode = 'admin_dark_mode';

  final FlutterSecureStorage _storage;

  SessionManager([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              webOptions: WebOptions(
                dbName: 'za2zo2a_admin',
                publicKey: 'za2zo2a_admin_store',
              ),
            );

  /// In-memory cache so the dio interceptor attaches the token without an
  /// async read on every request. Hydrated by [bootstrap].
  String? _cachedToken;

  String? get cachedToken => _cachedToken;
  bool get isLoggedIn => _cachedToken != null && _cachedToken!.isNotEmpty;

  /// Call once at app start, before the router evaluates its first redirect.
  ///
  /// A corrupt/undecryptable store must never be fatal: on web the values are
  /// encrypted in localStorage, and anything that mangles them (a partial
  /// clear, an extension, a key rotation) makes `read` throw. Treat that as
  /// "no session" and wipe, so the operator lands on login instead of a blank
  /// screen.
  Future<void> bootstrap() async {
    try {
      _cachedToken = await _storage.read(key: _kToken);
    } catch (_) {
      _cachedToken = null;
      await clear();
    }
  }

  Future<void> saveToken(String token) async {
    _cachedToken = token;
    await _storage.write(key: _kToken, value: token);
  }

  Future<String?> readToken() async {
    if (_cachedToken != null) return _cachedToken;
    try {
      return _cachedToken = await _storage.read(key: _kToken);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveAdmin(Map<String, dynamic> json) async =>
      _storage.write(key: _kAdmin, value: jsonEncode(json));

  Future<Map<String, dynamic>?> readAdmin() async {
    try {
      final raw = await _storage.read(key: _kAdmin);
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  // ── Theme preference (device-local; no backend field exists) ────────────
  Future<void> saveDarkMode(bool isDark) async =>
      _storage.write(key: _kDarkMode, value: isDark ? 'true' : 'false');

  Future<bool> readDarkMode() async {
    try {
      return await _storage.read(key: _kDarkMode) == 'true';
    } catch (_) {
      return false;
    }
  }

  /// Wipe the session — logout and 401.
  Future<void> clear() async {
    _cachedToken = null;
    try {
      await _storage.delete(key: _kToken);
      await _storage.delete(key: _kAdmin);
    } catch (_) {
      // Nothing more we can do; the in-memory token is already gone.
    }
  }
}
