// lib/ui/go_router_refresh.dart
import 'dart:async';
import 'package:flutter/foundation.dart';

/// Превращает любой Stream в Listenable для refreshListenable GoRouter’а.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
