/// Builds the single configured [Dio] instance (docs/40 §13.1).
///
/// One Dio, shared by all data sources. Interceptor order: Auth (attach + refresh)
/// → Retry (GET 5xx/transport) → Logging (redacted). The `X-Client: mobile` and
/// `Accept` headers are set globally here.
library;

import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../logging/app_logger.dart';
import 'auth_gateway.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

Dio buildDioClient({
  required AppConfig config,
  required AuthGateway gateway,
  required AppLogger logger,
}) {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: <String, Object?>{
        'Accept': 'application/json',
        // Load-bearing: makes the backend return the refresh token in the body.
        'X-Client': config.clientHeader,
      },
    ),
  );

  final AuthInterceptor auth = AuthInterceptor(gateway)..bindClient(dio);
  dio.interceptors.addAll(<Interceptor>[
    auth,
    RetryInterceptor(dio),
    LoggingInterceptor(logger),
  ]);
  return dio;
}
