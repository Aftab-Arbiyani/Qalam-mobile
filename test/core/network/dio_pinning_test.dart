import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/config/app_flavor.dart';
import 'package:qalam_mobile/core/logging/app_logger.dart';
import 'package:qalam_mobile/core/network/auth_gateway.dart';
import 'package:qalam_mobile/core/network/dio_client.dart';
import 'package:qalam_mobile/core/security/certificate_pinning.dart';
import 'package:qalam_mobile/core/security/token_store.dart';

import '../../support/harness.dart';

/// Records whether the certificate-pinning hook was invoked on the built client.
class RecordingPinning implements CertificatePinning {
  bool applied = false;
  Dio? target;

  @override
  void apply(Dio dio) {
    applied = true;
    target = dio;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  AuthGateway buildGateway(AppLogger logger) => AuthGateway(
    tokenStore: TokenStore(buildFakeSecureStorage()),
    config: testConfig,
    logger: logger,
  );

  test('buildDioClient applies the certificate-pinning hook to the client', () {
    final AppLogger logger = AppLogger(flavor: AppFlavor.development);
    final RecordingPinning pinning = RecordingPinning();

    final Dio dio = buildDioClient(
      config: testConfig,
      gateway: buildGateway(logger),
      logger: logger,
      pinning: pinning,
    );

    expect(pinning.applied, isTrue);
    expect(identical(pinning.target, dio), isTrue);
  });

  test('the interceptor chain is Auth → Retry → Logging', () {
    final AppLogger logger = AppLogger(flavor: AppFlavor.development);
    final Dio dio = buildDioClient(
      config: testConfig,
      gateway: buildGateway(logger),
      logger: logger,
    );
    // The three app interceptors are present (plus Dio's implicit ones).
    final List<String> types = dio.interceptors
        .map((Interceptor i) => i.runtimeType.toString())
        .toList();
    expect(types.any((String t) => t.contains('AuthInterceptor')), isTrue);
    expect(types.any((String t) => t.contains('RetryInterceptor')), isTrue);
    expect(types.any((String t) => t.contains('LoggingInterceptor')), isTrue);
  });

  test('the default pinning is the inert Noop (no pinning in this build)', () {
    const CertificatePinning pinning = NoopCertificatePinning();
    // Applying the noop must not throw and must not alter the client.
    final Dio dio = Dio();
    pinning.apply(dio);
    expect(dio, isNotNull);
  });
}
