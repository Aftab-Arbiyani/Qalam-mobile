/// Navigation observer (docs/40 §10 requirement) — logs route transitions in
/// debug for diagnostics and leaves a crash-reporter breadcrumb (route names only,
/// never PII) so a crash report shows the navigation path that led to it.
library;

import 'package:flutter/widgets.dart';

import '../../core/logging/app_logger.dart';
import '../../core/observability/crash_reporter.dart';

class AppNavigatorObserver extends NavigatorObserver {
  AppNavigatorObserver(this._logger, [this._crashReporter]);

  final AppLogger _logger;
  final CrashReporter? _crashReporter;

  void _log(String action, Route<dynamic>? route) {
    final Object? name = route?.settings.name;
    final String label = '${name ?? '(unnamed)'}';
    _logger.d('nav $action → $label');
    _crashReporter?.addBreadcrumb('$action $label', category: 'navigation');
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
