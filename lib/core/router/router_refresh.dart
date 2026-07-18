import 'dart:async';

import 'package:flutter/foundation.dart';

/// Bridges a bloc/cubit stream into go_router's [Listenable] so `redirect`
/// re-evaluates the moment auth state changes (login, logout, 401).
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
