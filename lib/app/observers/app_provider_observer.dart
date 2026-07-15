/// Riverpod observer (docs/40 §8.6) — logs provider failures so an error inside
/// a provider is never silent. Wired into the root `ProviderScope`.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/logging/app_logger.dart';

final class AppProviderObserver extends ProviderObserver {
  AppProviderObserver(this._logger);

  final AppLogger _logger;

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    _logger.e(
      'provider failed: ${context.provider.name ?? context.provider.runtimeType}',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
