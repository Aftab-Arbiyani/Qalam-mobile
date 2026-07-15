/// Navigation observer (docs/40 §10 requirement) — logs route transitions in
/// debug for diagnostics. Feeds nothing PII (route names only).
library;

import 'package:flutter/widgets.dart';

import '../../core/logging/app_logger.dart';

class AppNavigatorObserver extends NavigatorObserver {
  AppNavigatorObserver(this._logger);

  final AppLogger _logger;

  void _log(String action, Route<dynamic>? route) {
    final Object? name = route?.settings.name;
    _logger.d('nav $action → ${name ?? '(unnamed)'}');
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _log('push', route);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _log('pop', route);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      _log('replace', newRoute);

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _log('remove', route);
}
