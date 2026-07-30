/// Per-request markers carried in `RequestOptions.extra` (docs/40 §13).
///
/// Interceptors read these to alter behavior for a single request without global
/// state: mark a replayed request so refresh doesn't loop, opt a request out of
/// retry, or attach an idempotency key.
library;

import 'package:dio/dio.dart';

abstract final class RequestKeys {
  static const String isRetry = 'qalam.is_retry';
  static const String retryCount = 'qalam.retry_count';
  static const String skipRetry = 'qalam.skip_retry';
  static const String skipAuthRefresh = 'qalam.skip_auth_refresh';
  static const String idempotencyKey = 'qalam.idempotency_key';
}

extension RequestFlags on RequestOptions {
  bool get isRetryAttempt => (extra[RequestKeys.isRetry] as bool?) ?? false;
  int get retryCount => (extra[RequestKeys.retryCount] as int?) ?? 0;
  bool get skipRetry => (extra[RequestKeys.skipRetry] as bool?) ?? false;
  bool get skipAuthRefresh =>
      (extra[RequestKeys.skipAuthRefresh] as bool?) ?? false;
  bool get isAuthCorridor => path.startsWith('/auth/');
}
